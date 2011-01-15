module Java2Ruby
  class TreeVisitor
    def process(element, data = {})
      last_current_element = @current_element
      @current_element = element
      result = __send__ element[:type], element, data
      @current_element = last_current_element
      result
    end
    
    def process_children(data = {})
      @current_element[:children].each do |child|
        process child, data
      end
    end
  end
end