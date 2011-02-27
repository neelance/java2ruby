module Java2Ruby
  class JavaParseTreeProcessor
    EPSILON = "<epsilon>".to_sym

    attr_reader :next_element, :next_element_index

    def process(tree)
      @current_new_element = {}
      self.elements = []

      process_children(tree) do
        match_compilationUnit
      end
      
      @current_new_element[:children].first
    end

    def process_children(element)
      if element[:children]
        parent_elements = @elements
        parent_next_element_index = @next_element_index

        self.elements = element[:children]
        result = yield
        raise ArgumentError, "Elements of #{element[:internal_name]} not processed: #{@elements[@next_element_index..-1].map{ |child| child[:internal_name] }.join(", ")}" if not @next_element_index == @elements.size
  
        self.elements = parent_elements
        self.next_element_index = parent_next_element_index
      end

      result
    end
    
    def elements=(list)
      @elements = list
      self.next_element_index = 0
      @next_element = @elements.first
    end
    
    def next_element_index=(value)
      @next_element_index = value
      @next_element = @elements[@next_element_index]
    end
    
    def next_element
    	while @next_element && @next_element[:type] == :line_comment
        add_child @next_element
        self.next_element_index += 1
      end
      
    	@next_element
    end
    
    def next_is?(*names)
      next_element && names.include?(next_element[:internal_name])
    end
    
    def consume
      current_element = next_element
      self.next_element_index += 1
      current_element
    end

    def match(*names)
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of #{names.inspect}" if not names.include? next_element[:internal_name]
      element = consume
      process_children element do
        yield if block_given?
      end
      element[:text]
    end

    def match_name
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of name string" if not next_element[:internal_name].is_a? String
      consume[:text] # string elements have no children
    end

    def try_match(*names)
      return nil if not next_is?(*names)
      element = consume
      process_children element do
        yield if block_given?
      end
      element[:text]
    end

    def loop_match(name)
      loop do
        try_match(name) do
          yield
        end or break
      end
    end

    def multi_match(*options)
      result = nil
      index = 0
      loop do
        names = options.map { |option| option[index] }
        break if not names.any?
        part = names.all? ? match(*names) : try_match(*names)
        break if part.nil?
        options.reject! { |option| option[index] != part }
        result ||= ""
        result << part
        index += 1
      end
      result
    end
    
    def create_element(type, attributes = {})
      last_new_element = @current_new_element
      @current_new_element = { :type => type }.merge(attributes)
      
      yield if block_given?
      
      (last_new_element[:children] ||= []) << @current_new_element
      @current_new_element = last_new_element
    end
    
    def collect_children
      last_new_element = @current_new_element
      list = @current_new_element = {}
      
      yield if block_given?
      
      @current_new_element = last_new_element
      list[:children]
    end
    
    def set_attribute(name, value)
      @current_new_element[name] = value
    end
    
    def add_child(child)
      (@current_new_element[:children] ||= []) << child
    end
  end
end

require "#{File.dirname(__FILE__)}/java_parse_tree_processor/core_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/class_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/statement_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/expression_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/variable_matchers"