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
      
      def initialize(converter, name, &block)
        super converter
        @current_module = converter.current_module
        @current_method = converter.current_method
        @name = name
        @block = block
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
        @block.call self
      end
      
      def enable
        @write_catch = true
      end
    end
    
    def visit_variable_declaration(element, data)
      visit_localVariableDeclaration element
    end
    
    def visit_inner_module(element, data)
      inner_module = visit element[:module], :context_module => current_module
      puts_output inner_module.java_type, " = ", inner_module
    end
    
    def visit_expression(element, data)
      expression = visit element[:value]
      expression.result_used = false
      puts_output expression
    end
    
    def visit_if(element, data)
      puts_output "if ", visit(element[:condition])
      indent_output { visit element[:true] }
      if element[:false]
        puts_output "else"
        indent_output { visit element[:false] }
      end
      puts_output "end"
    end
    
    def visit_switch(element, data)
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
                  current_case[0] << visit
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
    end
    
    def visit_while(element, data)
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
    end
    
    def visit_do_while(element, data)
      puts_output "begin"
      indent_output do
        CatchBlock.new(self, "next_#{data[:block_name]}") do |next_catch|
          switch_statement_context LoopContext.new(data[:block_name], data[:break_catch], next_catch) do
            visit element[:child]
          end
        end
      end
      puts_output "end while ", visit(element[:condition])
    end
    
    def visit_for(element, data)
      element[:inits].each do |e|
        if e[:type] == :variable_declaration
          visit_localVariableDeclaration e
        else 
          puts_output visit(e)
        end
      end
      if element[:condition]
        puts_output "while ", visit(element[:condition])
      else
        puts_output "loop do"
      end
      indent_output do
        CatchBlock.new(self, "next_#{data[:block_name]}") do |next_catch|
          switch_statement_context ForContext.new(data[:block_name], data[:break_catch], next_catch, element[:updates]) do
            visit element[:child]
          end
        end
        element[:updates].each { |e| puts_output visit(e) }
      end
      puts_output "end"
    end
    
    def visit_for_each(element, data)
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
    
    def visit_try(element, data)
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
    end
    
    def visit_break(element, data)
      if element[:name]
        name = RubyNaming.lower_name(element[:name])
        block_context = @statement_context.find_block name
        if block_context == @statement_context.current_ruby_break_context
          puts_output "break"
        else
          puts_output "throw :break_#{name}, :thrown"
          block_context.break_catch.enable
        end
      else
        break_context = @statement_context.current_java_break_context
        if break_context.is_a?(SwitchContext)
          puts_output "throw :break_case, :thrown"
          break_context.break_case_catch.enable
        else
          puts_output "break"
        end
      end
    end
    
    def visit_continue(element, data)
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
    end
    
    def visit_return(element, data)
      if element[:value]
        puts_output "return ", visit(element[:value])
      else
        puts_output "return"
      end
    end
    
    def visit_throw(element, data)
      throw_expression = visit
      match ";"
      puts_output "raise ", throw_expression
    end
    
    def visit_synchronized(element, data)
      puts_output "synchronized(", visit_parExpression, ") do"
      indent_output do
        visit_block
      end
      puts_output "end"
    end
    
    def visit_assert(element, data)
      assert_line = ["raise AssertError"]
      assert_expression = visit
      if try_match ":"
        assert_line.push ", ", visit.typecast(JavaType::STRING)
      end
      match ";"
      assert_line.push " if not (", assert_expression, ")"
      puts_output(*assert_line)
    end
    
    def visit_block(element, data)
      block_context = BlockContext.new data[:block_name], data[:break_catch]
      switch_statement_context block_context do
        visit_children element
      end
    end
    
    def visit_label(element, data)
      block_name = RubyNaming.lower_name(element[:name])
      CatchBlock.new(self, "break_#{block_name}") do |break_catch|
        visit element[:child], :block_name => block_name, :break_catch => break_catch
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
