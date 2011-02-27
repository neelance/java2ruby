module Java2Ruby
  class CommentSimplifier < TreeVisitor
    def auto_process_missing
      true
    end
    
    def visit_block_comment(element, data)
      lines = element[:text].split "\n"
      
      first = lines.index { |line| !line.strip.empty? }
      last = lines.rindex { |line| !line.strip.empty? }
      
      lines[first..last].map{ |line| { :type => :line_comment, :text => line, :same_line => false } }
    end
  end
end