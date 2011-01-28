require "yaml"

require "#{File.dirname(__FILE__)}/conversion_controller"
require "#{File.dirname(__FILE__)}/tree_visitor"

module Java2Ruby
  class Converter
    attr_accessor :converter_id, :size, :error, :log, :ruby_file
    
    def initialize(java_file, conversion_rules = {}, output_dir = nil, controller = nil, converter_id = nil, size = nil)
      @java_file = java_file
      @conversion_rules = conversion_rules
      @output_dir = output_dir || File.dirname(@java_file)
      @converter_id = converter_id
      @size = size
      @log = nil
    end
    
    def convert
      basename = File.basename @java_file, ".java"

      #code = File.read(@java_file).force_encoding("ASCII-8BIT")
      #@log["input code"] = code if @log
      
      #require "#{File.dirname(__FILE__)}/processors/java_code_parser"
      #tree = JavaCodeParser.new.parse_java code
      #@log["input tree"] = tree.to_yaml if @log
      
      #File.open("#{@output_dir}/#{basename}.step1.yaml", "w") { |file| file.write tree.to_yaml }
      tree = YAML.load File.read("#{@output_dir}/#{basename}.step1.yaml")
      
      require "#{File.dirname(__FILE__)}/processors/java_parse_tree_processor"
      tree = JavaParseTreeProcessor.new.process tree
      @log["processed tree"] = tree.to_yaml if @log
      
      require "#{File.dirname(__FILE__)}/processors/java_processor"
      java_processor = JavaProcessor.new @conversion_rules
      tree = java_processor.process tree
      
      require "#{File.dirname(__FILE__)}/processors/output_indenter"
      output = OutputIndenter.new.process tree
      @log["output code"] = output if @log
      
      @ruby_file = "#{@output_dir}/#{JavaProcessor::JavaClassType.new java_processor, nil, nil, nil, [basename]}.rb"
      
      File.open(ruby_file, "w") { |file| file.write output }
    end
  end
end
