module Java2Ruby
  class JavaParseTreeProcessor
    def match_block
      match :block do
        match "{"
        match_block_statements
        match "}"
      end
    end
    
    def match_block_statements
      loop_match :blockStatement do
        match_block_statement_children
      end
    end
    
    def match_block_statement_children
      if try_match :localVariableDeclarationStatement do
          match_localVariableDeclaration
          match ";"
        end
      elsif next_is? :classOrInterfaceDeclaration
        inner_module = match_classOrInterfaceDeclaration current_module
        puts_output inner_module.java_type, " = ", inner_module
      else
        match :statement do
          match_statement_children
        end
      end
    end
    
    def match_statement_children(block_name = nil, break_catch = nil)
      if try_match :statementExpression do
          expression = match_expression
          expression.result_used = false
          puts_output expression
        end
        match ";"
      elsif try_match "if"
        puts_output "if ", match_parExpression
        indent_output do
          match :statement do
            match_statement_children
          end
        end
        if try_match "else"
          puts_output "else"
          indent_output do
            match :statement do
              match_statement_children
            end
          end
        end
        puts_output "end"
      elsif try_match "switch"
        case_expression = match_parExpression
        match "{"
        CatchBlock.new(self, "break_case") do |break_case_catch|
          buffer_match :switchBlockStatementGroups do
            puts_output "case ", case_expression
            cases = []
            open_cases = []
            default_case = nil
            loop_match :switchBlockStatementGroup do
              current_case = [[], []]
              cases << current_case
              open_cases << current_case
              loop_match :switchLabel do
                if try_match "case"
                  match :constantExpression do
                    current_case[0] << match_expression
                  end
                else
                  match "default"
                  default_case = current_case
                end
                match ":"
              end
              last_statement = nil
              while next_is? :blockStatement
                last_statement = next_element
                statement_buffer = buffer_match(:blockStatement) do
                  match_block_statement_children
                end
                open_cases.each do |open_case|
                  open_case[1] << statement_buffer
                end
              end
              if handle_case_end last_statement
                open_cases.clear
              end
            end
            cases.each do |the_case|
              next if the_case[0].empty?
              puts_output "when ", *the_case[0].insert_seperators(", ")
              indent_output do
                switch_statement_context SwitchContext.new(block_name, break_catch, break_case_catch) do
                  the_case[1].each { |buffer| buffer.call }
                end
              end
            end
            if default_case
              puts_output "else"
              indent_output do
                switch_statement_context SwitchContext.new(block_name, break_catch, break_case_catch) do
                  default_case[1].each { |buffer| buffer.call }
                end
              end
            end
            puts_output "end"
          end
        end
        match "}"
      elsif try_match "while"
        puts_output "while ", match_parExpression
        indent_output do
          CatchBlock.new(self, "next_#{block_name}") do |next_catch|
            buffer_match :statement do
              switch_statement_context LoopContext.new(block_name, break_catch, next_catch) do
                match_statement_children
              end
            end
          end
        end
        puts_output "end"
      elsif try_match "do"
        puts_output "begin"
        indent_output do
          CatchBlock.new(self, "next_#{block_name}") do |next_catch|
            buffer_match :statement do
              switch_statement_context LoopContext.new(block_name, break_catch, next_catch) do
                match_statement_children
              end
            end
          end
        end
        match "while"
        puts_output "end while ", match_parExpression
        match ";"
      elsif try_match "for"
        for_each = false
        for_condition = for_each_variable = for_each_list = nil
        for_inits = []
        for_updates = []
        match "("
        match :forControl do
          if try_match :enhancedForControl do
              for_each = true
              match_variableModifiers
              type = match_type
              for_each_variable = [match_name, type]
              match ":"
              for_each_list = match_expression
            end
          else
            try_match :forInit do
              if next_is? :localVariableDeclaration
                match_localVariableDeclaration
              else
                for_inits = match_expression_list
              end
            end
            match ";"
            if next_is? :expression
              for_condition = match_expression
            end
            match ";"
            try_match :forUpdate do
              for_updates = match_expression_list
            end
          end
        end
        match ")"
        if not for_each
          for_inits.each { |e| puts_output e }
          if for_condition
            puts_output "while ", for_condition
          else
            puts_output "loop do"
          end
          indent_output do
            CatchBlock.new(self, "next_#{block_name}") do |next_catch|
              buffer_match :statement do
                switch_statement_context ForContext.new(block_name, break_catch, next_catch, for_updates) do
                  match_statement_children
                end
              end
            end
            for_updates.each { |e| puts_output e }
          end
          puts_output "end"
        else
          puts_output for_each_list, ".each do |#{for_each_variable[0]}|"
          indent_output do
            CatchBlock.new(self, "next_#{block_name}") do |next_catch|
              buffer_match :statement do
                switch_statement_context LoopContext.new(block_name, break_catch, next_catch) do
                  @statement_context.new_variable *for_each_variable
                  match_statement_children
                end
              end
            end
          end
          puts_output "end"
        end
      elsif try_match "try"
        puts_output "begin"
        indent_output do
          match_block
        end
        try_match :catches do
          loop_match :catchClause do
            exception_type, exception_variable = nil
            match "catch"
            match "("
            match :formalParameter do
              match_variableModifiers
              exception_type = match_type
              match :variableDeclaratorId do
                exception_variable = match_name
              end
            end
            match ")"
            switch_statement_context StatementContext.new do
              var_name = @statement_context.new_variable exception_variable, exception_type
              puts_output "rescue #{exception_type} => #{var_name}"
              indent_output do
                match_block
              end
            end
          end
        end
        if try_match "finally"
          puts_output "ensure"
          indent_output do
            match_block
          end
        end
        puts_output "end"
      elsif try_match "break"
        if try_match ";"
          break_context = @statement_context.current_java_break_context
          if break_context.is_a?(SwitchContext)
            puts_output "throw :break_case, :thrown"
            break_context.break_case_catch.enable
          else
            puts_output "break"
          end
        else
          name = RJava.lower_name(match_name)
          match ";"
          block_context = @statement_context.find_block name
          if block_context == @statement_context.current_ruby_break_context
            puts_output "break"
          else
            puts_output "throw :break_#{name}, :thrown"
            block_context.break_catch.enable
          end
        end
      elsif try_match :disabled_break
        match ";"
      elsif try_match "continue"
        if try_match ";"
          loop_context = @statement_context.current_java_next_context
          loop_context.for_updates.each { |e| puts_output e } if loop_context.is_a?(ForContext)
          puts_output "next"
        else
          name = RJava.lower_name(match_name)
          match ";"
          loop_context = @statement_context.find_block name
          if loop_context == @statement_context.current_java_next_context
            loop_context.for_updates.each { |e| puts_output e } if loop_context.is_a?(ForContext)
            puts_output "next"
          else
            puts_output "throw :next_#{name}, :thrown"
            loop_context.next_catch.enable
          end
        end
      elsif try_match "return"
        if next_is? :expression
          puts_output "return ", match_expression
        else
          puts_output "return"
        end
        match ";"
      elsif try_match "throw"
        throw_expression = match_expression
        match ";"
        puts_output "raise ", throw_expression
      elsif try_match "synchronized"
        puts_output "synchronized(", match_parExpression, ") do"
        indent_output do
          match_block
        end
        puts_output "end"
      elsif try_match "assert"
        assert_line = ["raise AssertError"]
        assert_expression = match_expression
        if try_match ":"
          assert_line.push ", ", match_expression.typecast(JavaType::STRING)
        end
        match ";"
        assert_line.push " if not (", assert_expression, ")"
        puts_output(*assert_line)
      elsif next_is? :block
        block_context = BlockContext.new block_name, break_catch
        switch_statement_context block_context do
          match_block
        end
      elsif try_match ";"
        # nothing
      else
        block_name = RJava.lower_name(match_name)
        match ":"
        CatchBlock.new(self, "break_#{block_name}") do |break_catch|
          buffer_match :statement do
            match_statement_children block_name, break_catch
          end
        end
      end
    end
    
    def handle_case_end(element)
      case element[:internal_name]
      when :block
        handle_case_end element[:children][-2]
      when :blockStatement
        handle_case_end element[:children].first
      when :statement
        case element[:children].first[:internal_name]
        when "break"
          element[:children].first[:internal_name] = :disabled_break if element[:children][1][:internal_name] == ";"
          true
        when "return", "throw"
          true
        when "if"
          handle_case_end(element[:children][2]) && (element[:children].size < 5 || handle_case_end(element[:children][4]))
        when :block
          handle_case_end element[:children].first
        else
          false
        end
      else
        false
      end
    end
    
  end
end
