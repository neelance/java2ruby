require "ruby_naming"
require "processors/tree_visitor"

module Java2Ruby
  class JavaProcessor < TreeVisitor
    EPSILON = "<epsilon>".to_sym

    attr_accessor :current_generator, :statement_context, :basename

    def initialize(conversion_rules)
      @prefix = conversion_rules["prefix"] || "Java"
      @prefix_class_names = conversion_rules["prefix_class_names"] || []
      @constants = conversion_rules["constants"] || []
      @no_constants = conversion_rules["no_constants"] || []
      @constant_name_mapping = conversion_rules["constant_name_mapping"] || {}
      @field_name_mapping = conversion_rules["field_name_mapping"] || {}
      @explicit_calls = conversion_rules["explicit_calls"] || {}
    end
    
    def process(element)
      @current_generator = nil
      @statement_context = nil
      @explicit_call_counter = -1
      
      compilation_unit = JavaCompilationUnit.new element, @basename, converter
      { type: :output_tree, children: compilation_unit.output_parts.first }
    end
    
    def converter
      self
    end
    
    def current_module
      @current_generator.current_module
    end
    
    def current_method
      @current_generator.current_method
    end
    
    def switch_statement_context(context)
      context.parent_context = @statement_context
      @statement_context = context
      yield
      @statement_context = @statement_context.parent_context
    end
    
    def puts_output(*parts)
      @current_generator.puts_output(*parts)
    end
    
    def indent_output
      @current_generator.indent_output do
        yield
      end
    end
    
    def is_constant?(name)
      @constants.include?(name) || (!@no_constants.include?(name) && name =~ /^[A-Z]/)
    end
    
    def ruby_constant_name(name)
      @constant_name_mapping[name] || RubyNaming.ruby_constant_name(name)
    end
    
    def ruby_class_name(package, names)
      if @prefix_class_names.include?(names.first)
        name_parts = []
        name_parts << package.ruby_name unless package.nil? or package.root?
        name_parts << "#{@prefix}#{names.first}"
        name_parts.concat names[1..-1]
        name_parts.join "::"
      else
        nil
      end
    end
    
    def ruby_field_name(name)
      @field_name_mapping[name] || RubyNaming.lower_name(name)
    end
    
    def ruby_method_name(name, call = true)
      if call and @explicit_calls.include? name
        @explicit_call_counter += 1
        "#{RubyNaming.ruby_method_name name}___#{@package.names.join '_'}_#{RubyNaming.lower_name @basename}_#{@explicit_call_counter}"
      else
        RubyNaming.ruby_method_name name
      end
    end
    
    def compose_arguments(arguments, force_braces = false)
      if (arguments.nil? || arguments.empty?) && !force_braces
        []
      else
        parts = ["("]
        arguments and arguments.each do |argument|
          parts << ", " if parts.size > 1
          part = visit(argument)
          # raise argument.inspect if part.nil?
          parts << part
        end
        parts << ")"
        parts
      end
    end
  end
end

require "#{File.dirname(__FILE__)}/java_processor/output_generator"
require "#{File.dirname(__FILE__)}/java_processor/expressions"

require "#{File.dirname(__FILE__)}/java_processor/java_types"
require "#{File.dirname(__FILE__)}/java_processor/java_modules"
require "#{File.dirname(__FILE__)}/java_processor/java_methods"

require "#{File.dirname(__FILE__)}/java_processor/core_visitors"
require "#{File.dirname(__FILE__)}/java_processor/class_visitors"
require "#{File.dirname(__FILE__)}/java_processor/statement_visitors"
require "#{File.dirname(__FILE__)}/java_processor/expression_visitors"
require "#{File.dirname(__FILE__)}/java_processor/variable_visitors"