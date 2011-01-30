module Java2Ruby
  class JavaParseTreeProcessor
    EPSILON = "<epsilon>".to_sym

    attr_reader :next_element
    def process(tree)
      @elements = tree[:children]
      @next_element_index = 0
      @next_element = @elements.first

      match_compilationUnit
    end

    def process_children(element)
      parent_elements = @elements
      parent_next_element_index = @next_element_index

      @elements = element[:children]
      @next_element_index = 0
      @next_element = @elements.first
      result = yield
      raise ArgumentError, "Elements of #{element[:internal_name]} not processed: #{@elements[@next_element_index..-1].map{ |child| child[:internal_name] }.join(", ")}" if not @next_element_index == @elements.size

      @elements = parent_elements
      @next_element_index = parent_next_element_index
      @next_element = @elements && @elements[@next_element_index]

      result
    end

    def next_is?(*names)
      next_element && names.include?(next_element[:internal_name])
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

    def consume
      current_element = next_element

      # handle comments
      # if current_element[:hidden_tokens]
      #   current_element[:hidden_tokens].each do |hidden_token|
      #     if hidden_token[:type] == JavaLexer::LINE_COMMENT
      #     @current_generator.single_line_comment hidden_token[:text][2..-1].strip
      #     elsif hidden_token[:type] == JavaLexer::COMMENT
      #       lines = []
      #       hidden_token[:text].split("\n").each do |line|
      #         line.strip!
      #         line.gsub! /\*\/$/, ""
      #         line.gsub! /^\/?\*+/, ""
      #         line.strip!
      #         lines << line
      #       end
      #     @current_generator.multi_line_comment lines
      #     elsif hidden_token[:text] == "\r" || hidden_token[:text] == "\n"
      #     @current_generator.new_line
      #     end
      #   end
      # end

      @next_element_index += 1
      @next_element = @elements[@next_element_index]

      current_element
    end
  end
end

require "#{File.dirname(__FILE__)}/java_parse_tree_processor/core_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/class_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/statement_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/expression_matchers"
require "#{File.dirname(__FILE__)}/java_parse_tree_processor/variable_matchers"