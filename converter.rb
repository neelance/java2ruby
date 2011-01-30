require "yaml"
require "fileutils"

require "ruby_modifications"
require "ruby_naming"
require "conversion_controller"
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
      
      def run(input_provider, input_timestamp)
        last_output_provider = lambda {
          last_output = File.read @output_file
          last_output = YAML.load last_output if yaml_output?
          last_output
        }
        
        last_output_timestamp = File.exist?(@output_file) ? File.mtime(@output_file) : Time.at(0)
        
        if input_timestamp > last_output_timestamp or includes_timestamp > last_output_timestamp
          puts "Creating #{@output_file}"
          
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
          puts "Skipping #{@output_file}"
          FileUtils.touch @output_file
          @next_step.run last_output_provider, last_output_timestamp if @next_step
        end
      end

    end
    
    attr_accessor :converter_id, :size, :error, :log, :ruby_file
    
    def initialize(java_file, conversion_rules = {}, output_dir = nil, controller = nil, converter_id = nil, size = nil)
      @java_file = java_file
      @conversion_rules = conversion_rules
      @output_dir = output_dir || File.dirname(@java_file)
      @converter_id = converter_id
      @size = size
      @log = nil
      @steps = []
    end
    
    def step(output_file, *includes, &block)
      new_step = Step.new output_file, includes, block
      @steps.last.next_step = new_step unless @steps.empty?
      @steps << new_step
    end
    
    def log(name, content)
      return if not @log
      content = content.to_yaml if not content.is_a?(String)
      @log[name] = content
    end
    
    def convert
      basename = File.basename @java_file, ".java"
      
      step "#{@output_dir}/#{basename}.step1.yaml", "java_code_parser" do |code|
        log "input code", code
        
        tree = JavaCodeParser.new.parse_java code
        log "input tree", tree
        
        tree
      end
      
      step "#{@output_dir}/#{RubyNaming.ruby_constant_name(basename)}.rb", "java_parse_tree_processor", "java_processor", "output_indenter" do |tree|
        tree = JavaParseTreeProcessor.new.process tree
        log "processed tree", tree
        
        java_processor = JavaProcessor.new @conversion_rules
        tree = java_processor.process tree
        
        output = OutputIndenter.new.process tree
        log "output code", output
        
        output
      end

      @steps.first.run lambda { File.read(@java_file).force_encoding("ASCII-8BIT").gsub("\r\n", "\n") }, File.mtime(@java_file)
    end
  end
end
