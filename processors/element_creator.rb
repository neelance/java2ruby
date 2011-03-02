module Java2Ruby
  module ElementCreator
    def create_element(type, attributes = {})
      new_element = case type
      when Symbol
        { type: type }
      when Hash
        type
      else
        raise ArgumentError
      end
      
      new_element.merge! attributes

      if block_given?
        children = collect_children do
          more_attributes = collect_attributes do
            yield
          end
          new_element.merge! more_attributes
        end
        if children.empty?
          new_element.delete :children
        else
          new_element[:children] = children
        end
      end
      
      add_child new_element
      new_element
    end
    
    def collect_children
      last_child_list = @current_child_list
      list = @current_child_list = []
      yield
      @current_child_list = last_child_list
      list
    end
    
    def add_child(child)
      @current_child_list << child
    end
    
    def add_children(children)
      @current_child_list.concat children
    end
    
    def collect_attributes
      last_attribute_hash = @current_attribute_hash
      hash = @current_attribute_hash = {}
      yield
      @current_attribute_hash = last_attribute_hash
      hash
    end
    
    def set_attribute(name, value)
      @current_attribute_hash[name] = value
    end
  end
end