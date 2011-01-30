module Java2Ruby
  class TreeVisitor
    @@visit_methods = Hash.new { |h, k| h[k] = "visit_#{k}".to_sym }
    
    def process(element)
      visit element
    end
    
    def visit(element, data = {})
      type = element[:type]
      raise ArgumentError, element.inspect if not type.is_a?(Symbol)
      result = __send__ @@visit_methods[type], element, data
      result
    end
    
    def visit_children(element, data = {})
      element[:children].each do |child|
        visit child, data
      end
    end
  end
end