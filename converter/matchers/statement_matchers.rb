module Java2Ruby
  class Converter
    class StatementContext
      def initialize(parent_context)
        @parent_context = parent_context
      end
      
      def converter
        @parent_context.converter
      end
      
      def current_block
        @parent_context.current_block
      end
      
      def find_block(block_name)
        @parent_context.find_block block_name
      end
    end
    
    class GlobalContext < StatementContext
      attr_reader :converter
      
      def initialize(converter)
        @converter = converter
      end
      
      def current_block
        nil
      end
    end
    
    class BlockContext < StatementContext
      attr_accessor :block_name, :break_block_catch, :next_block_catch, :for_updates
      
      def initialize(parent_context, block_name = nil, break_block_catch = nil)
        super parent_context
        @block_name = block_name
        @break_block_catch = break_block_catch
        @next_block_catch = nil
        @for_updates = []
      end
      
      def current_block
        self
      end
      
      def find_block(block_name)
        block_name == @block_name ? self : super
      end
    end
    
    class SwitchContext < StatementContext
      attr_reader :break_case_catch
      
      def initialize(parent_context, break_case_catch)
        super parent_context
        @break_case_catch = break_case_catch
      end
    end
    
    class CatchBlock < OutputGenerator
      attr_reader :name, :converter, :current_module, :current_method
      
      def initialize(converter, context, name)
        super converter
        @current_module = converter.current_module
        @current_method = converter.current_method
        @name = name
        @buffer = yield self
        @write_catch = false
        
        parts = self.output_parts # evaluates block and thus may modify @write_catch
        
        if @write_catch
          @converter.puts_output "catch(:#{name}) do"
          @converter.indent_output do
            @converter.puts_output(*parts)
          end
          if context.current_block
            @converter.puts_output "end == :thrown or break"
          else
            @converter.puts_output "end"
          end
        else
          @converter.puts_output(*parts)
        end
      end
      
      def write_output
        @buffer.call
      end
      
      def enable
        @write_catch = true
      end
    end
    
    def match_block(context)
      match :block do
        match "{"
        match_block_statements context
        match "}"
      end
    end
    
    def match_block_statements(context)
      loop_match :blockStatement do
        match_block_statement_children context
      end
    end
    
    def match_block_statement_children(context)
      if try_match :localVariableDeclarationStatement do
          match_localVariableDeclaration
          match ";"
        end
      elsif next_is? :classOrInterfaceDeclaration
        inner_module = match_classOrInterfaceDeclaration current_module
        puts_output inner_module.java_type, " = ", inner_module
      else
        match :statement do
          match_statement_children context, nil
        end
      end
    end
    
    def match_statement_children(context, block_context)
      if try_match :statementExpression do
          puts_output match_expression
        end
        match ";"
      elsif try_match "if"
        puts_output "if ", match_parExpression
        indent_output do
          match :statement do
            match_statement_children context, nil
          end
        end
        if try_match "else"
          puts_output "else"
          indent_output do
            match :statement do
              match_statement_children context, nil
            end
          end
        end
        puts_output "end"
      elsif try_match "switch"
        case_expression = match_parExpression
        match "{"
        CatchBlock.new(self, context, "break_case") do |break_case_catch|
          buffer_match :switchBlockStatementGroups do
            puts_output "case ", case_expression
            cases = []
            open_cases = []
            default_case = nil
            switch_context = SwitchContext.new(context, break_case_catch)
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
                  match_block_statement_children switch_context
                end
                open_cases.each do |open_case|
                  open_case[1] << statement_buffer
                end
              end
              if last_statement.handle_case_end
                open_cases.clear
              end
            end
            cases.each do |the_case|
              next if the_case[0].empty?
              puts_output "when ", *the_case[0].insert_seperators(", ")
              indent_output do
                the_case[1].each { |buffer| buffer.call }
              end
            end
            if default_case
              puts_output "else"
              indent_output do
                default_case[1].each { |buffer| buffer.call }
              end
            end
            puts_output "end"
          end
        end
        match "}"
      elsif try_match "while"
        puts_output "while ", match_parExpression
        indent_output do
          block_context ||= BlockContext.new context
          CatchBlock.new(self, context, "next_#{block_context.block_name}") do |next_block_catch|
            block_context.next_block_catch = next_block_catch
            buffer_match :statement do
              match_statement_children block_context, nil
            end
          end
        end
        puts_output "end"
      elsif try_match "do"
        puts_output "begin"
        indent_output do
          block_context ||= BlockContext.new context
          CatchBlock.new(self, context, "next_#{block_context.block_name}") do |next_block_catch|
            block_context.next_block_catch = next_block_catch
            buffer_match :statement do
              match_statement_children block_context, nil
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
            block_context ||= BlockContext.new context
            CatchBlock.new(self, context, "next_#{block_context.block_name}") do |next_block_catch|
              block_context.next_block_catch = next_block_catch
              block_context.for_updates = for_updates
              buffer_match :statement do
                match_statement_children block_context, nil
              end
            end
            for_updates.each { |e| puts_output e }
          end
          puts_output "end"
        else
          puts_output for_each_list, ".each do |#{for_each_variable[0]}|"
          indent_output do
            block_context ||= BlockContext.new context
            CatchBlock.new(self, context, "next_#{block_context.block_name}") do |next_block_catch|
              block_context.next_block_catch = next_block_catch
              buffer_match :statement do
                if current_method
                  current_method.keep_variables do
                    current_method.new_variable *for_each_variable
                    match_statement_children block_context, nil
                  end
                else
                  match_statement_children block_context, nil
                end
              end
            end
          end
          puts_output "end"
        end
      elsif try_match "try"
        puts_output "begin"
        indent_output do
          match_block context
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
            puts_output "rescue #{exception_type} => #{exception_variable}"
            indent_output do
              current_method.keep_variables do
                current_method.new_variable exception_variable, exception_type
                match_block context
              end
            end
          end
        end
        if try_match "finally"
          puts_output "ensure"
          indent_output do
            match_block context
          end
        end
        puts_output "end"
      elsif try_match "break"
        if try_match ";"
          if context.is_a? SwitchContext
            puts_output "throw :break_case, :thrown"
            context.break_case_catch.enable
          else
            puts_output "break"
          end
        else
          name = RJava.lower_name(match_name)
          match ";"
          loop_context = context.find_block name
          if loop_context == context.current_block
            puts_output "break"
          else
            puts_output "throw :break_#{name}, :thrown"
            loop_context.break_block_catch.enable
          end
        end
      elsif try_match :disabled_break
        match ";"
      elsif try_match "continue"
        if try_match ";"
          loop_context = context.current_block
          loop_context.for_updates.each { |e| puts_output e }
          puts_output "next"
        else
          name = RJava.lower_name(match_name)
          match ";"
          loop_context = context.find_block name
          if loop_context == context.current_block
            loop_context.for_updates.each { |e| puts_output e }
            puts_output "next"
          else
            puts_output "throw :next_#{name}, :thrown"
            loop_context.next_block_catch.enable
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
          match_block context
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
        match_block context
      elsif try_match ";"
        # nothing
      else
        block_name = RJava.lower_name(match_name)
        match ":"
        CatchBlock.new(self, context, "break_#{block_name}") do |break_block_catch|
          buffer_match :statement do
            this_block_context = BlockContext.new(context, block_name, break_block_catch)
            match_statement_children this_block_context, this_block_context
          end
        end
      end
    end
    
  end
end