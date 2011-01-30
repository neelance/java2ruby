module Java2Ruby
  class TreeVisitor
    @@visit_methods = Hash.new { |h, k| h[k] = "visit_#{k}".to_sym }
    
    def process(element)
      visit element
    end
    
    def visit(element, data = {})
      last_current_element = @current_element
      @current_element = element
      result = __send__ @@visit_methods[element[:type]], element, data
      @current_element = last_current_element
      result
    end
    
    def visit_children(data = {})
      @current_element[:children].each do |child|
        visit child, data
      end
    end
  end
end