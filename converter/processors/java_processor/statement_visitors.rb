module Java2Ruby
  class JavaProcessor

    class StatementContext
      attr_accessor :parent_context
      
      def initialize
        @variables = {}
        @ruby_variable_names = Set.new
      end
      
      def converter
        @parent_context.converter
      end
      
      def current_java_break_context
        @parent_context.current_java_break_context
      end
      
      def current_java_next_context
        @parent_context.current_java_next_context
      end
      
      def find_block(block_name)
        @parent_context.find_block block_name
      end
  
      def current_ruby_break_context
        @parent_context.current_ruby_break_context
      end
      
      def new_variable(name, type)
        var_name = RubyNaming.lower_name name
        while ruby_variable_name_used?(var_name) or RubyNaming::RUBY_KEYWORDS.include?(var_name)
          var_name << "_"
        end
        @variables[name] = [type, var_name]
        @ruby_variable_names << var_name
        var_name
      end
      
      def resolve(identifiers)
        if @variables.has_key?(identifiers.first)
          var = @variables[identifiers.shift]
          Expression.new var[0], var[1]
        else
          @parent_context && @parent_context.resolve(identifiers)
        end
      end
      
      def ruby_variable_name_used?(name)
        @ruby_variable_names.include?(name) || (@parent_context && @parent_context.ruby_variable_name_used?(name))
      end
    end
    
    class MethodContext < StatementContext
      def initialize(method)
        super()
        @method = method
      end
      
      def converter
        @method.converter
      end
      
      def ruby_variable_name_used?(name)
        @method.parent_module.has_ruby_method?(name) || super
      end
      
      def current_java_break_context
        nil
      end
      
      def current_java_next_context
        nil
      end
      
      def find_block(name)
        nil
      end
  
      def current_ruby_break_context
        nil
      end
    end
    
    class BlockContext < StatementContext
      attr_reader :block_name, :break_catch
      
      def initialize(block_name, break_catch)
        super()
        @block_name = block_name
        @break_catch = break_catch
      end
      
      def find_block(block_name)
        block_name == @block_name ? self : super
      end
    end
    
    class LoopContext < BlockContext
      attr_reader :next_catch
      
      def initialize(block_name, break_catch, next_catch)
        super block_name, break_catch
        @next_catch = next_catch
      end
      
      def current_java_break_context
        self
      end
      
      def current_java_next_context
        self
      end
  
      def current_ruby_break_context
        self
      end
    end
    
    class ForContext < LoopContext
      attr_reader :for_updates
      
      def initialize(block_name, break_catch, next_catch, for_updates)
        super block_name, break_catch, next_catch
        @for_updates = for_updates
      end
    end
    
    class SwitchContext < BlockContext
      attr_reader :break_case_catch
      
      def initialize(block_name, break_catch, break_case_catch)
        super block_name, break_catch
        @break_case_catch = break_case_catch
      end
      
      def current_java_break_context
        self
      end
    end
    
    class CatchBlock
      include OutputGenerator
      attr_reader :name, :current_module, :current_method
      
      def initialize(converter, name)
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
          if @converter.statement_context.current_ruby_break_context
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
  
    def visit_block
      match :block do
        match "{"
        visit_block_statements
        match "}"
      end
    end
    
    def visit_block_statements(element)
      element[:children].each do |child|
        visit_block_statement_children child
      end
    end
    
    def visit_block_statement_children(element)
      if element[:type] == :local_variable_declaration
        visit_localVariableDeclaration element
      elsif element[:type] == :class_or_interface
        inner_module = visit_classOrInterfaceDeclaration current_module
        puts_output inner_module.java_type, " = ", inner_module
      else
        visit_statement_children element
      end
    end
    
    def visit_statement_children(element, block_name = nil, break_catch = nil)
      case element[:type]
      when :expression
        expression = visit_expression element[:value]
        expression.result_used = false
        puts_output expression
      when :if
        puts_output "if ", visit_parExpression
        indent_output do
          match :statement do
            visit_statement_children
          end
        end
        if try_match "else"
          puts_output "else"
          indent_output do
            match :statement do
              visit_statement_children
            end
          end
        end
        puts_output "end"
      when :switch
        case_expression = visit_parExpression
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
                    current_case[0] << visit_expression
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
                  visit_block_statement_children
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
      when :while
        puts_output "while ", visit_parExpression
        indent_output do
          CatchBlock.new(self, "next_#{block_name}") do |next_catch|
            buffer_match :statement do
              switch_statement_context LoopContext.new(block_name, break_catch, next_catch) do
                visit_statement_children
              end
            end
          end
        end
        puts_output "end"
      when :do
        puts_output "begin"
        indent_output do
          CatchBlock.new(self, "next_#{block_name}") do |next_catch|
            buffer_match :statement do
              switch_statement_context LoopContext.new(block_name, break_catch, next_catch) do
                visit_statement_children
              end
            end
          end
        end
        match "while"
        puts_output "end while ", visit_parExpression
        match ";"
      when :for
        for_each = false
        for_condition = for_each_variable = for_each_list = nil
        for_inits = []
        for_updates = []
        match "("
        match :forControl do
          if try_match :enhancedForControl do
              for_each = true
              visit_variableModifiers
              type = visit_type
              for_each_variable = [visit_name, type]
              match ":"
              for_each_list = visit_expression
            end
          else
            try_match :forInit do
              if next_is? :localVariableDeclaration
                visit_localVariableDeclaration
              else
                for_inits = visit_expression_list
              end
            end
            match ";"
            if next_is? :expression
              for_condition = visit_expression
            end
            match ";"
            try_match :forUpdate do
              for_updates = visit_expression_list
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
                  visit_statement_children
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
                  visit_statement_children
                end
              end
            end
          end
          puts_output "end"
        end
      when :try
        puts_output "begin"
        indent_output do
          visit_block
        end
        try_match :catches do
          loop_match :catchClause do
            exception_type, exception_variable = nil
            match "catch"
            match "("
            match :formalParameter do
              visit_variableModifiers
              exception_type = visit_type
              match :variableDeclaratorId do
                exception_variable = visit_name
              end
            end
            match ")"
            switch_statement_context StatementContext.new do
              var_name = @statement_context.new_variable exception_variable, exception_type
              puts_output "rescue #{exception_type} => #{var_name}"
              indent_output do
                visit_block
              end
            end
          end
        end
        if try_match "finally"
          puts_output "ensure"
          indent_output do
            visit_block
          end
        end
        puts_output "end"
      when :break
        if try_match ";"
          break_context = @statement_context.current_java_break_context
          if break_context.is_a?(SwitchContext)
            puts_output "throw :break_case, :thrown"
            break_context.break_case_catch.enable
          else
            puts_output "break"
          end
        else
          name = RubyNaming.lower_name(visit_name)
          match ";"
          block_context = @statement_context.find_block name
          if block_context == @statement_context.current_ruby_break_context
            puts_output "break"
          else
            puts_output "throw :break_#{name}, :thrown"
            block_context.break_catch.enable
          end
        end
      when :disabled_break
        match ";"
      when :continue
        if try_match ";"
          loop_context = @statement_context.current_java_next_context
          loop_context.for_updates.each { |e| puts_output e } if loop_context.is_a?(ForContext)
          puts_output "next"
        else
          name = RubyNaming.lower_name(visit_name)
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
      when :return
        if next_is? :expression
          puts_output "return ", visit_expression
        else
          puts_output "return"
        end
        match ";"
      when :throw
        throw_expression = visit_expression
        match ";"
        puts_output "raise ", throw_expression
      when :synchronized
        puts_output "synchronized(", visit_parExpression, ") do"
        indent_output do
          visit_block
        end
        puts_output "end"
      when :assert
        assert_line = ["raise AssertError"]
        assert_expression = visit_expression
        if try_match ":"
          assert_line.push ", ", visit_expression.typecast(JavaType::STRING)
        end
        match ";"
        assert_line.push " if not (", assert_expression, ")"
        puts_output(*assert_line)
      when :block
        block_context = BlockContext.new block_name, break_catch
        switch_statement_context block_context do
          visit_block
        end
      else
        raise ArgumentError, element[:type]
      #  block_name = RubyNaming.lower_name(visit_name)
      #  match ":"
      #  CatchBlock.new(self, "break_#{block_name}") do |break_catch|
      #    buffer_match :statement do
      #      visit_statement_children nil, block_name, break_catch
      #    end
      #  end
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
