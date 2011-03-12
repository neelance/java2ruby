require "processors/tree_visitor"

module Java2Ruby
  class CommentSimplifier < TreeVisitor
    def auto_process_missing
      true
    end
    
    def visit_line_comment(element, data)
      text = element[:text].rstrip
      text = " #{text}" if text[0] != " "
      create_element :line_comment, text: text, same_line: element[:same_line]
    end
    
    def visit_block_comment(element, data)
      lines = element[:text].split "\n"
      lines[0] = (" " * element[:line_offset]) + lines[0]
      
      offsets = lines.map { |line| line.index(/[^ \t*]/) }
      first = offsets.index { |offset| offset }
      last = offsets.rindex { |offset| offset }
      
      if first
        if first == last and element[:same_line]
          create_element :line_comment, text: " #{lines[first].strip}", same_line: true
        else
          offset = offsets[first..last].compact.min
          lines[first..last].each do |line|
            text = line[offset..-1] || ""
            create_element :line_comment, text: " #{text.rstrip}", same_line: false
          end
        end
      end
    end
  end
end