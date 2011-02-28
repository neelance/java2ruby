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
      attr_reader :for_update
      
      def initialize(block_name, break_catch, next_catch, for_update)
        super block_name, break_catch, next_catch
        @for_update = for_update
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
    
    def visit_expression(element, data)
      expression = visit element[:value]
      expression.result_used = false
      puts_output expression
    end
    
    def visit_if(element, data)
      if_branches = {}
      visit_children element, if_branches: if_branches
      
      puts_output "if ", visit(element[:condition])
      indent_output { visit_children if_branches[:true] }
      if if_branches[:false]
        puts_output "else"
        indent_output { visit_children if_branches[:false] }
      end
      puts_output "end"
    end
    
    def visit_true_statement(element, data)
      data[:if_branches][:true] = element
    end
    
    def visit_false_statement(element, data)
      data[:if_branches][:false] = element
    end
    
    def visit_case(element, data)
      CatchBlock.new(self, "break_case") do |break_case_catch|
        puts_output "case ", visit(element[:value])
        visit_children element, data.merge({ :break_case_catch => break_case_catch })
        puts_output "end"
      end
    end
    
    def visit_case_branch(element, data)
      raise if not element[:closed]
      if element[:values] == :default
        puts_output "else"
      else
        puts_output "when ", *element[:values].map{ |v| visit v }.insert_seperators(", ")
      end
      indent_output do
        switch_statement_context SwitchContext.new(data[:block_name], data[:break_catch], data[:break_case_catch]) do
          visit_children element
        end
      end
    end
    
    def visit_while(element, data)
      puts_output "while ", visit(element[:condition])
      indent_output do
        CatchBlock.new(self, "next_#{data[:block_name]}") do |next_catch|
          switch_statement_context LoopContext.new(data[:block_name], data[:break_catch], next_catch) do
            visit_children element
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
            visit_children element
          end
        end
      end
      puts_output "end while ", visit(element[:condition])
    end
    
    def visit_for(element, data)
      for_branches = {}
      visit_children element, for_branches: for_branches
      
      visit_children for_branches[:init]
      if element[:condition]
        puts_output "while ", visit(element[:condition])
      else
        puts_output "loop do"
      end
      indent_output do
        CatchBlock.new(self, "next_#{data[:block_name]}") do |next_catch|
          switch_statement_context ForContext.new(data[:block_name], data[:break_catch], next_catch, for_branches[:update]) do
            visit_children for_branches[:child_statement]
          end
        end
        visit_children for_branches[:update]
      end
      puts_output "end"
    end
    
    def visit_for_init(element, data)
      data[:for_branches][:init] = element
    end

    def visit_for_update(element, data)
      data[:for_branches][:update] = element
    end
    
    def visit_for_child_statement(element, data)
      data[:for_branches][:child_statement] = element
    end
    
    def visit_for_each(element, data)
      for_branches = {}
      visit_children element, for_branches: for_branches
      
      puts_output visit(element[:iterable]), ".each do |#{element[:variable]}|"
      indent_output do
        CatchBlock.new(self, "next_#{data[:block_name]}") do |next_catch|
          switch_statement_context LoopContext.new(data[:block_name], data[:break_catch], next_catch) do
            @statement_context.new_variable element[:variable], element[:entry_type]
            visit_children for_branches[:child_statement]
          end
        end
      end
      puts_output "end"
    end
    
    def visit_try(element, data)
      puts_output "begin"
      visit_children element
      puts_output "end"
    end
    
    def visit_try_body(element, data)
      indent_output do
        visit_children element
      end
    end
    
    def visit_rescue(element, data)
      exception_type = visit element[:exception_type]
      switch_statement_context StatementContext.new do
        var_name = @statement_context.new_variable element[:exception_variable], exception_type
        puts_output "rescue #{exception_type} => #{var_name}"
        indent_output do
          visit_children element
        end
      end
    end
    
    def visit_ensure(element, data)
      puts_output "ensure"
      indent_output do
        visit_children element
      end
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
      if element[:name]
        name = RubyNaming.lower_name(element[:name])
        loop_context = @statement_context.find_block name
        if loop_context == @statement_context.current_java_next_context
          visit_children loop_context.for_update if loop_context.is_a?(ForContext)
          puts_output "next"
        else
          puts_output "throw :next_#{name}, :thrown"
          loop_context.next_catch.enable
        end
      else
        loop_context = @statement_context.current_java_next_context
        visit_children loop_context.for_update if loop_context.is_a?(ForContext)
        puts_output "next"
      end
    end
    
    def visit_return(element, data)
      if element[:value]
        puts_output "return ", visit(element[:value])
      else
        puts_output "return"
      end
    end
    
    def visit_raise(element, data)
      puts_output "raise ", visit(element[:exception])
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
        visit_children element, :block_name => block_name, :break_catch => break_catch
      end
    end
    
  end
end
