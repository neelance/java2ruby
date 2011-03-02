require "yaml"
require "zlib"
require "fileutils"

require "ruby_modifications"
require "ruby_naming"

module Java2Ruby
  class Converter
    class Step
      @@loaded_includes = []

      attr_accessor :output_file, :next_step
      
      def initialize(converter, method_name, output_file, includes)
        @converter = converter
        @method_name = method_name
        @output_file = output_file
        @includes = includes
      end
      
      def yaml_output?
        @output_file =~ /\.yaml(\.gz)?$/
      end
      
      def dump_output?
        @output_file =~ /\.dump(\.gz)?$/
      end

      def gz_output?
        @output_file =~ /\.gz$/
      end
      
      def max(a, b)
        a > b ? a : b
      end
      
      def includes_timestamp
        timestamp = Time.at(0)
        @includes.each do |include|
          path = "#{File.dirname(__FILE__)}/processors/#{include}"
          timestamp = max timestamp, File.mtime("#{path}.rb")
          if File.directory?(path)
            Dir.foreach(path) do |file|
              next if File.extname(file) != ".rb" 
              timestamp = max timestamp, File.mtime(File.join(path, file))
            end
          end
        end
        timestamp
      end
      
      def nothing_to_do?(input_timestamp)
        last_output_timestamp = File.exist?(@output_file) ? File.mtime(@output_file) : Time.at(0)
        input_timestamp <= last_output_timestamp && includes_timestamp <= last_output_timestamp && (@next_step.nil? || @next_step.nothing_to_do?(last_output_timestamp)) 
      end
      
      def run(input_provider, input_timestamp)
        last_output_provider = lambda {
          last_output = nil
          last_output = if gz_output?
            Zlib::GzipReader.open(@output_file) { |file| last_output = file.read }
          else
            File.open(@output_file, "r") { |file| last_output = file.read }
          end
          last_output = YAML.load last_output if yaml_output?
          last_output = Marshal.load last_output if dump_output?
          last_output
        }
        
        last_output_timestamp = File.exist?(@output_file) ? File.mtime(@output_file) : Time.at(0)
        
        if input_timestamp > last_output_timestamp or includes_timestamp > last_output_timestamp
          puts "Creating #{@output_file}" if $verbose
          
          @includes.each do |include|
            unless @@loaded_includes.include? include
              require "#{File.dirname(__FILE__)}/processors/#{include}"
              @@loaded_includes << include
            end
          end
          
          output = @converter.public_send @method_name, input_provider.call
          
          if not File.exist?(@output_file) or output != last_output_provider.call
            file_output = output
            file_output = file_output.to_yaml if yaml_output?
            file_output = Marshal.dump file_output if dump_output? 
            if gz_output?
              Zlib::GzipWriter.open(@output_file) { |file| file.write file_output }
            else
              File.open(@output_file, "w") { |file| file.write file_output }
            end
            @next_step.run lambda { output }, Time.new if @next_step
          else
            FileUtils.touch @output_file
            @next_step.run lambda { output }, last_output_timestamp if @next_step
          end
        else
          puts "Skipping #{@output_file}" if $verbose
          FileUtils.touch @output_file
          @next_step.run last_output_provider, last_output_timestamp if @next_step
        end
      end

    end
    
    attr_reader :java_file, :ruby_file, :converter_id, :size
    attr_accessor :log, :error
    
    def find_dir(base_dir, name)
      if base_dir.include?("src")
        new_dir = base_dir.sub "src", name
        return new_dir if Dir.exists? new_dir
      end
      base_dir
    end
    
    def initialize(java_file, output_dir = nil, temp_dir = nil, conversion_rules = {}, converter_id = nil, size = nil)
      @java_file = java_file
      @conversion_rules = conversion_rules
      @converter_id = converter_id
      @size = size
      @log = nil
      @steps = []
      
      output_dir ||= find_dir File.dirname(@java_file), "lib"
      temp_dir ||= find_dir File.dirname(@java_file), "tmp"
      
      @basename = File.basename @java_file, ".java"
      @ruby_file = "#{output_dir}/#{RubyNaming.ruby_constant_name(@basename)}.rb"
      
      register_step :step1, "#{temp_dir}/#{@basename}.step1.dump.gz", "java_code_parser", "comment_simplifier"
      register_step :step2, @ruby_file, "java_parse_tree_processor", "case_end_handler", "java_processor", "output_indenter"
     end
    
    def step1(code)
      write_log "input code", code
      
      tree = JavaCodeParser.new.parse_java code
      tree = CommentSimplifier.new.process tree
      write_log "input tree", tree
      
      tree
    end
    
    def step2(tree)
      tree = JavaParseTreeProcessor.new.process tree
      tree = CaseEndHandler.new.process tree
      write_log "processed tree", tree
      
      java_processor = JavaProcessor.new @conversion_rules
      java_processor.basename = @basename
      tree = java_processor.process tree
      
      output = OutputIndenter.new.process tree
      write_log "output code", output
      
      output
    end
    
    def register_step(method_name, output_file, *includes)
      new_step = Step.new self, method_name, output_file, includes
      @steps.last.next_step = new_step unless @steps.empty?
      @steps << new_step
    end
    
    def write_log(name, content)
      return if not @log
      content = content.to_yaml if not content.is_a?(String)
      @log[name] = content
    end
    
    def convert
      @steps.first.run lambda { File.read(@java_file).force_encoding("ASCII-8BIT").gsub("\r\n", "\n") }, File.mtime(@java_file)
    end
    
    def nothing_to_do?
      @steps.first.nothing_to_do?(File.mtime(@java_file))
    end
  end
end
