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
        match_classOrInterfaceDeclaration
      else
        match_statement
      end
    end
    
    def match_statement
      match :statement do
        if try_match :statementExpression do
            expression = match_expression
            create_element :expression, value: expression
          end
          match ";"
        elsif try_match "if"
          create_element :if do
            set_attribute :condition, match_parExpression
            create_element :true_statement do
              match_statement
            end
            if try_match "else"
              create_element :false_statement do
                match_statement
              end
            end
          end
        elsif try_match "switch"
          create_element :case do
            set_attribute :value, match_parExpression

            match "{"
            match :switchBlockStatementGroups do
              loop_match :switchBlockStatementGroup do
                create_element :case_branch, closed: false do
                  values = []
                  loop_match :switchLabel do
                    if try_match "case"
                      match :constantExpression do
                        values << match_expression
                      end
                    else
                      match "default"
                      values << :default
                    end
                    match ":"
                  end
                  set_attribute :values, values
                  
                  loop_match(:blockStatement) do
                    match_block_statement_children
                  end
                end
              end
            end
            match "}"
          end
        elsif try_match "while"
          create_element :while do
            set_attribute :condition, match_parExpression
            match_statement
          end
        elsif try_match "do"
          create_element :do_while do
            match_statement
            match "while"
            set_attribute :condition, match_parExpression
            match ";"
          end
        elsif try_match "for"
          create_element :for do
            match "("
            match :forControl do
              if try_match :enhancedForControl do
                  set_attribute :type, :for_each
                  match_variableModifiers
                  set_attribute :entry_type, match_type
                  set_attribute :variable, match_name
                  match ":"
                  set_attribute :iterable, match_expression
                end
              else
                create_element :for_init do
	                try_match :forInit do
                    if next_is? :localVariableDeclaration
                      match_localVariableDeclaration
                    else
                      match_expression_list
                    end
                  end
                end
                match ";"
                if next_is? :expression
                  set_attribute :condition, match_expression
                end
                match ";"
                create_element :for_update do
	                try_match :forUpdate do
                    match_expression_list
                  end
                end
              end
            end
            match ")"
            create_element :for_child_statement do
              match_statement
            end
          end
        elsif try_match "try"
        	create_element :try do
	          create_element :try_body do
	          	match_block
	         	end
	          try_match :catches do
	            loop_match :catchClause do
	            	create_element :rescue do
		              match "catch"
		              match "("
		              match :formalParameter do
		                match_variableModifiers
		                set_attribute :exception_type, match_type
		                match :variableDeclaratorId do
		                  set_attribute :exception_variable, match_name
		                end
		              end
		              match ")"
		              match_block
		            end
	            end
	          end
	          if try_match "finally"
	          	create_element :ensure do
	            	match_block
	           	end
	          end
	        end
        elsif try_match "break"
          create_element :break do
            if not try_match ";"
              set_attribute :name, match_name
              match ";"
            end
          end
        elsif try_match "continue"
          create_element :continue do
            if not try_match ";"
              set_attribute :name, match_name
              match ";"
            end
          end
        elsif try_match "return"
          create_element :return do
            set_attribute :value, match_expression if next_is?(:expression)
            match ";"
          end
        elsif try_match "throw"
          create_element :raise do
            set_attribute :exception, match_expression
            match ";"
          end
        elsif try_match "synchronized"
          create_element :synchronized do
            set_attribute :monitor, match_parExpression
            match_block
          end
        elsif try_match "assert"
          create_element :assertion do
            set_attribute :condition, match_expression
            if try_match ":"
              set_attribute :message, match_expression
            end
            match ";"
          end
        elsif next_is? :block
          create_element :block do
            match_block
          end
        elsif try_match ";"
          # nothing
        else
          create_element :label do
            set_attribute :name, match_name
            match ":"
            match_statement
          end
        end
      end
    end
    
  end
end
