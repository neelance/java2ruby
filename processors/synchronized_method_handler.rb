require "processors/tree_visitor"

module Java2Ruby
  class SynchronizedMethodHandler < TreeVisitor
    def auto_process_missing
      true
    end
    
    def visit_method_declaration(element, data)
      if element[:synchronized]
      	create_element element, synchronized: false do
    	    create_element :synchronized, monitor: { type: :self } do
            visit_children element
          end
        end
      else
        create_element element do
          visit_children element
        end
      end
    end
  end
end