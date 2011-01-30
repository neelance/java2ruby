module Java2Ruby
  class OutputIndenter < TreeVisitor
    def visit_output_tree(element, data)
      output = ""
      visit_children element, :indention => 0, :output => output
      output
    end
    
    def visit_output_block(element, data)
      visit_children element, :indention => data[:indention] + 1, :output => data[:output]
    end
    
    def visit_output_line(element, data)
      data[:output] << "#{'  ' * data[:indention]}#{element[:content]}\n"
    end
  end
end