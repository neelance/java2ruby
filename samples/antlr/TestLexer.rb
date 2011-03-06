require "rjava"

module TestLexerImports
  include Object::Java::Lang
  include Object::Org::Antlr::Runtime
  include_const Object::Java::Util, :Stack
  include_const Object::Java::Util, :List
  include_const Object::Java::Util, :ArrayList
end

class TestLexer < TestLexerImports.const_get :Lexer
  include TestLexerImports
  
  lazy_constants[:EOF] = lambda { EOF = -1 }
  lazy_constants[:T__6] = lambda { T__6 = 6 }
  lazy_constants[:T__5] = lambda { T__5 = 5 }
  lazy_constants[:T__4] = lambda { T__4 = 4 }
  
  Initialize_test_lexer_SIGNATURES = priorize_signatures([], [CharStream], [CharStream, RecognizerSharedState])
  def initialize_test_lexer(arg0 = NO_ARG, arg1 = NO_ARG)
    case select_signature([arg0, arg1], Initialize_test_lexer_SIGNATURES)
    when 0 # []
      initialize_lexer()
    when 1 # [CharStream]
      input = arg0
      initialize_test_lexer(input, RecognizerSharedState.new)
    when 2 # [CharStream, RecognizerSharedState]
      input = arg0
      state = arg1
      initialize_lexer(input, state)
    end
  end
  
  alias_method :initialize, :initialize_test_lexer
  
  def get_grammar_file_name
    return "Test__.g"
  end
  
  def m_t__4
    begin
      _type = T__4
      _channel = DEFAULT_TOKEN_CHANNEL
      match(Character.new(?A))
      self.state.attr_type = _type
      self.state.attr_channel = _channel
    ensure
    end
  end
  
  def m_t__5
    begin
      _type = T__5
      _channel = DEFAULT_TOKEN_CHANNEL
      match(Character.new(?B))
      self.state.attr_type = _type
      self.state.attr_channel = _channel
    ensure
    end
  end
  
  def m_t__6
    begin
      _type = T__6
      _channel = DEFAULT_TOKEN_CHANNEL
      match(Character.new(?C))
      self.state.attr_type = _type
      self.state.attr_channel = _channel
    ensure
    end
  end
  
  def m_tokens
    alt1 = 3
    case (self.input.la(1))
    when Character.new(?A)
      alt1 = 1
    when Character.new(?B)
      alt1 = 2
    when Character.new(?C)
      alt1 = 3
    else
      nvae = NoViableAltException.new("", 1, 0, self.input)
      raise nvae
    end
    case (alt1)
    when 1
      m_t__4
    when 2
      m_t__5
    when 3
      m_t__6
    end
  end
end

TestLexer.main($*) if $0 == __FILE__
