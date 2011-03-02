require "processors/element_creator"

module Java2Ruby
  class TreeVisitor
    include ElementCreator
    
    @@visit_methods = Hash.new { |h, k| h[k] = "visit_#{k}".to_sym }
    
    def auto_process_missing
      false
    end
    
    def process(tree)
      collect_children do
        visit tree
      end.first
    end
    
    def visit(element, data = {})
      type = element[:type]
      raise ArgumentError, element.inspect if not type.is_a?(Symbol)
      if auto_process_missing and not respond_to?(@@visit_methods[type])
        if element[:children]
          create_element element do
            visit_children element
          end
        else
          add_child element
        end
      else
        __send__ @@visit_methods[type], element, data
      end
    end
    
    def visit_children(element, data = {})
    	if element[:children]
        element[:children].each do |child|
          visit child, data
        end
      end
    end
  end
end