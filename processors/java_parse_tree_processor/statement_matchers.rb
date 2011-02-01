module Java2Ruby
  class JavaParseTreeProcessor
    def match_block(children)
      match :block do
        match "{"
        match_block_statements children
        match "}"
      end
    end
    
    def match_block_statements(children)
      loop_match :blockStatement do
        match_block_statement_children children
      end
    end
    
    def match_block_statement_children(children)
      if try_match :localVariableDeclarationStatement do
          children.concat match_localVariableDeclaration
          match ";"
        end
      elsif next_is? :classOrInterfaceDeclaration
        inner_module = match_classOrInterfaceDeclaration
        children << { :type => :inner_module, :module => inner_module }
      else
        match :statement do
          children << match_statement_child
        end
      end
    end
    
    def match_statement_child
      element = nil
      if try_match :statementExpression do
          expression = match_expression
          element = { :type => :expression, :value => expression }
        end
        match ";"
      elsif try_match "if"
        condition = match_parExpression
        true_statement = false_statement = nil
        match :statement do
          true_statement = match_statement_child
        end
        if try_match "else"
          match :statement do
            false_statement = match_statement_child
          end
        end
        element = { :type => :if, :condition => condition, :true => true_statement, :false => false_statement }
      elsif try_match "switch"
        case_expression = match_parExpression
        cases = []
        open_cases = []
        default_case = nil
        match "{"
        match :switchBlockStatementGroups do
          loop_match :switchBlockStatementGroup do
            current_case = { :type => :case_branch, :values => [], :children => [] }
            cases << current_case
            open_cases << current_case
            loop_match :switchLabel do
              if try_match "case"
                match :constantExpression do
                  current_case[:values] << match_expression
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
              when_children = []
              match(:blockStatement) do
                match_block_statement_children when_children
              end
              open_cases.each do |open_case|
                open_case[:children].concat when_children
              end
            end
            if handle_case_end last_statement
              open_cases.clear
            end
          end
        end
        match "}"
        element = { :type => :case, :value => case_expression, :branches => cases, :default_branch => default_case }
      elsif try_match "while"
        condition = match_parExpression
        child = nil
        match :statement do
          child = match_statement_child
        end
        element = { :type => :while, :condition => condition, :child => child }
      elsif try_match "do"
        child = nil
        match :statement do
          child = match_statement_child
        end
        match "while"
        condition = match_parExpression
        match ";"
        element = { :type => :do_while, :condition => condition, :child => child }
      elsif try_match "for"
        for_each = false
        for_condition = for_each_variable = for_each_entry_type = for_each_list = nil
        for_inits = []
        for_updates = []
        match "("
        match :forControl do
          if try_match :enhancedForControl do
              for_each = true
              match_variableModifiers
              for_each_entry_type = match_type
              for_each_variable = match_name
              match ":"
              for_each_list = match_expression
            end
          else
            try_match :forInit do
              if next_is? :localVariableDeclaration
                for_inits.concat match_localVariableDeclaration
              else
                for_inits.concat match_expression_list
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
        match :statement do
          if for_each
            element = { :type => :for_each, :iterable => for_each_list, :variable => for_each_variable, :entry_type => for_each_entry_type, :child => match_statement_child }
          else
            element = { :type => :for, :inits => for_inits, :condition => for_condition, :updates => for_updates, :child => match_statement_child }
          end
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
          element = { :type => :break }
        else
          name = match_name
          match ";"
          element = { :type => :break, :name => name }
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
        expression = next_is?(:expression) ? match_expression : nil
        element = { :type => :return, :value => expression }
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
        children = []
        match_block children
        element = { :type => :block, :children => children }
      elsif try_match ";"
        # nothing
      else
        name = match_name
        child = nil
        match ":"
        match :statement do
          child = match_statement_child
        end
        element = { :type => :label, :name => name, :child => child }
      end
      
      raise ArumentError if element.nil?
      element
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
