non_verbose {
  require "#{File.dirname(__FILE__)}/java_code_parser/JavaLexer"
  require "#{File.dirname(__FILE__)}/java_code_parser/JavaParser"
}

class JavaLexer
  M_TOKENS_LIST = [nil, :m_t__25, :m_t__26, :m_t__27, :m_t__28, :m_t__29, :m_t__30, :m_t__31, :m_t__32, :m_t__33, :m_t__34, :m_t__35, :m_t__36, :m_t__37, :m_t__38, :m_t__39, :m_t__40, :m_t__41, :m_t__42, :m_t__43, :m_t__44, :m_t__45, :m_t__46, :m_t__47, :m_t__48, :m_t__49, :m_t__50, :m_t__51, :m_t__52, :m_t__53, :m_t__54, :m_t__55, :m_t__56, :m_t__57, :m_t__58, :m_t__59, :m_t__60, :m_t__61, :m_t__62, :m_t__63, :m_t__64, :m_t__65, :m_t__66, :m_t__67, :m_t__68, :m_t__69, :m_t__70, :m_t__71, :m_t__72, :m_t__73, :m_t__74, :m_t__75, :m_t__76, :m_t__77, :m_t__78, :m_t__79, :m_t__80, :m_t__81, :m_t__82, :m_t__83, :m_t__84, :m_t__85, :m_t__86, :m_t__87, :m_t__88, :m_t__89, :m_t__90, :m_t__91, :m_t__92, :m_t__93, :m_t__94, :m_t__95, :m_t__96, :m_t__97, :m_t__98, :m_t__99, :m_t__100, :m_t__101, :m_t__102, :m_t__103, :m_t__104, :m_t__105, :m_t__106, :m_t__107, :m_t__108, :m_t__109, :m_t__110, :m_t__111, :m_t__112, :m_t__113, :m_hex_literal, :m_decimal_literal, :m_octal_literal, :m_floating_point_literal, :m_character_literal, :m_string_literal, :m_enum, :m_assert, :m_identifier, :m_ws, :m_comment, :m_line_comment]
  undef_method :m_tokens
  def m_tokens
    __send__ M_TOKENS_LIST[@dfa29.predict(self.attr_input)]
  end
end

module Java2Ruby
  class JavaCodeParser
    include Org::Antlr::Runtime
    include Org::Antlr::Runtime::Debug
    
    def parse_java(code)
      stream = ANTLRStringStream.new(code)
      lexer = JavaLexer.new stream
      tokens = CommonTokenStream.new
      tokens.set_token_source lexer
      builder = ParseTreeBuilder.new "Java"
      
      parser = JavaParser.new tokens, builder
      parser.compilation_unit
      
      process_parse_tree builder.get_tree
    end
    
    def process_parse_tree(parse_tree)
      {
        :type => :java_parse_tree,
        :internal_name => (parse_tree.attr_payload.is_a?(String) ? parse_tree.attr_payload.to_sym : parse_tree.attr_payload.get_text),
        :text => parse_tree.get_text,
        :hidden_tokens => (parse_tree.attr_hidden_tokens || []).map { |token| { :type => token.attr_type, :text => token.get_text } },
        :children => (parse_tree.attr_children || []).map { |child| process_parse_tree child }
      }
    end
  end
end