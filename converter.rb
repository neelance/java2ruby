require "yaml"
require "fileutils"

require "ruby_modifications"
require "ruby_naming"
require "processors/tree_visitor"

module Java2Ruby
  class Converter
    class Step
      attr_accessor :output_file, :next_step
      
      def initialize(output_file, includes, block)
        @output_file = output_file
        @includes = includes
        @block = block
      end
      
      def yaml_output?
        File.extname(@output_file) == ".yaml"
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
        input_timestamp < last_output_timestamp && includes_timestamp < last_output_timestamp && (@next_step.nil? || @next_step.nothing_to_do?(last_output_timestamp)) 
      end
      
      def run(input_provider, input_timestamp)
        last_output_provider = lambda {
          last_output = File.read @output_file
          last_output = YAML.load last_output if yaml_output?
          last_output
        }
        
        last_output_timestamp = File.exist?(@output_file) ? File.mtime(@output_file) : Time.at(0)
        
        if input_timestamp > last_output_timestamp or includes_timestamp > last_output_timestamp
          puts "Creating #{@output_file}" if $verbose
          
          @includes.each do |include|
            require "#{File.dirname(__FILE__)}/processors/#{include}"
          end
          
          output = @block.call input_provider.call
          
          if not File.exist?(@output_file) or output != last_output_provider.call
            File.open(@output_file, "w") { |file| file.write(yaml_output? ? output.to_yaml : output) }
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
    
    def initialize(java_file, output_dir = nil, temp_dir = nil, conversion_rules = {}, converter_id = nil, size = nil)
      @java_file = java_file
      @conversion_rules = conversion_rules
      @converter_id = converter_id
      @size = size
      @log = nil
      @steps = []
      
      output_dir ||= File.dirname @java_file
      temp_dir ||= File.dirname @java_file
      basename = File.basename @java_file, ".java"
      
      step "#{temp_dir}/#{basename}.step1.yaml", "java_code_parser", "comment_simplifier" do |code|
        write_log "input code", code
        
        tree = JavaCodeParser.new.parse_java code
        tree = CommentSimplifier.new.process tree
        write_log "input tree", tree
        
        tree
      end
      
      @ruby_file = "#{output_dir}/#{RubyNaming.ruby_constant_name(basename)}.rb"
      step @ruby_file, "java_parse_tree_processor", "java_processor", "output_indenter" do |tree|
        tree = JavaParseTreeProcessor.new.process tree
        write_log "processed tree", tree
        
        java_processor = JavaProcessor.new @conversion_rules
        tree = java_processor.process tree
        
        output = OutputIndenter.new.process tree
        write_log "output code", output
        
        output
      end
    end
    
    def step(output_file, *includes, &block)
      new_step = Step.new output_file, includes, block
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
