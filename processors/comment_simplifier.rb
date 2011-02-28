module Java2Ruby
  class CommentSimplifier < TreeVisitor
    def auto_process_missing
      true
    end
    
    def fix_blanks(text)
    	if text[0] != " "
    		" #{text.rstrip}"
    	else
    		text.rstrip
    	end
    end
    
    def visit_line_comment(element, data)
    	{ type: :line_comment, text: fix_blanks(element[:text]), same_line: element[:same_line] }
    end
    
    def visit_block_comment(element, data)
      lines = element[:text].split "\n"
      
      first = lines.index { |line| !line.strip.empty? }
      last = lines.rindex { |line| !line.strip.empty? }
      
      first && lines[first..last].map{ |line| { type: :line_comment, text: fix_blanks(line), same_line: false } }
    end
  end
end