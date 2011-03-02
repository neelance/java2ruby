require "processors/tree_visitor"

module Java2Ruby
  class CaseEndHandler < TreeVisitor
    def auto_process_missing
      true
    end
    
    def visit_children_data_only_last_child(element, data)
      if element[:children]
        element[:children][0..-2].each { |child| visit child }
        visit element[:children].last, data
      end
    end
    
    def visit_case(element, data)
    	create_element :case, value: element[:value] do
    	  visit_children element, open_branches: []
    	end
    end
    
    def visit_case_branch(element, data)
      raise if element[:closed]
      
      new_element = create_element :case_branch, closed: true, values: element[:values], children: []
      data[:open_branches] << new_element

      case_end_data = { break_found: false }
      children = collect_children do
        visit_children_data_only_last_child element, handle_case_end: case_end_data
      end
      is_closed = case_end_data[:break_found]
      
      data[:open_branches].each do |branch|
        branch[:children].concat children
      end
      
      data[:open_branches].clear if is_closed
    end
    
    def visit_break(element, data)
      if not element[:name] and data[:handle_case_end]
        data[:handle_case_end][:break_found] = true
      else
        add_child element
      end
    end
    
    def visit_return(element, data)
      data[:handle_case_end][:break_found] = true if data[:handle_case_end]
      add_child element
    end

    def visit_raise(element, data)
      data[:handle_case_end][:break_found] = true if data[:handle_case_end]
      add_child element
    end
    
    def visit_block(element, data)
      create_element :block do
        visit_children_data_only_last_child element, data
      end
    end
  end
end