require "rjava"
require "antlr4ruby"
require "yaml"

require "#{File.dirname(__FILE__)}/conversion_controller"
require "#{File.dirname(__FILE__)}/tree_visitor"
require "#{File.dirname(__FILE__)}/processors/java_code_parser"
require "#{File.dirname(__FILE__)}/processors/java_processor"
require "#{File.dirname(__FILE__)}/processors/output_indenter"

class Dir
  def self.dir_glob(dir, pattern)
    files = nil
    chdir dir do
      files = Dir.glob(pattern).sort
    end
    files
  end
end

module Java2Ruby
  class Converter
    attr_accessor :java_file, :basename, :ruby_file, :controller, :converter_id, :size, :error, :log
    
    def initialize(java_file, conversion_rules = {}, ruby_dir = nil, controller = nil, converter_id = nil, size = nil)
      @java_file = java_file
      @conversion_rules = conversion_rules
      @basename = File.basename @java_file, ".java"
      @ruby_file = "#{ruby_dir || File.dirname(@java_file)}/#{JavaProcessor::JavaClassType.new JavaProcessor.new(conversion_rules), nil, nil, nil, [@basename]}.rb"
      @converter_id = converter_id
      @size = size
      @log = nil
    end
        
    def convert
      code = File.read(java_file).force_encoding("ASCII-8BIT")
      @log["input code"] = code if @log
      
      tree = JavaCodeParser.new.parse_java code
      @log["input tree"] = tree.to_yaml if @log
      
      tree = JavaProcessor.new(@conversion_rules).process tree
      
      output = OutputIndenter.new.process tree
      @log["output code"] = output if @log
      
      File.open(ruby_file, "w") { |file| file.write output }
    end
  end
end
