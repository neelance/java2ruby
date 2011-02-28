module Java2Ruby
  class TreeVisitor
    @@visit_methods = Hash.new { |h, k| h[k] = "visit_#{k}".to_sym }
    
    def auto_process_missing
      false
    end
    
    def process(element)
      visit element
    end
    
    def visit(element, data = {})
      type = element[:type]
      raise ArgumentError, element.inspect if not type.is_a?(Symbol)
      if auto_process_missing and not respond_to?(@@visit_methods[type])
        if element[:children]
          element.merge({ :children => visit_children(element) })
        else
          element
        end
      else
        __send__ @@visit_methods[type], element, data
      end
    end
    
    def visit_children(element, data = {})
    	return [] if element[:children].nil?
      element[:children].map do |child|
        visit child, data
      end.flatten.compact
    end
  end
end