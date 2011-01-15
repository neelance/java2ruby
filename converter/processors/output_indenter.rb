module Java2Ruby
  class OutputIndenter < TreeVisitor
    def output_tree(element, data)
      output = ""
      process_children :indention => 0, :output => output
      output
    end
    
    def output_block(element, data)
      process_children :indention => data[:indention] + 1, :output => data[:output]
    end
    
    def output_line(element, data)
      data[:output] << "#{'  ' * data[:indention]}#{element[:content]}\n"
    end
  end
end