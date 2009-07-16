require "rjava"
 # $ANTLR 3.1.1 Java.g 2008-10-11 00:39:45
module JavaLexerImports
  class_module.module_eval {
    include ::Java::Lang
    include ::Org::Antlr::Runtime
    include_const ::Java::Util, :Stack
    include_const ::Java::Util, :JavaList
    include_const ::Java::Util, :ArrayList
  }
end

class JavaLexer < JavaLexerImports.const_get :Lexer
  include_class_members JavaLexerImports
  
  class_module.module_eval {
    const_set_lazy(:T__29) { 29 }
    const_attr_reader  :T__29
    
    const_set_lazy(:T__28) { 28 }
    const_attr_reader  :T__28
    
    const_set_lazy(:T__27) { 27 }
    const_attr_reader  :T__27
    
    const_set_lazy(:T__26) { 26 }
    const_attr_reader  :T__26
    
    const_set_lazy(:FloatTypeSuffix) { 16 }
    const_attr_reader  :FloatTypeSuffix
    
    const_set_lazy(:T__25) { 25 }
    const_attr_reader  :T__25
    
    const_set_lazy(:OctalLiteral) { 10 }
    const_attr_reader  :OctalLiteral
    
    const_set_lazy(:EOF) { -1 }
    const_attr_reader  :EOF
    
    const_set_lazy(:Identifier) { 4 }
    const_attr_reader  :Identifier
    
    const_set_lazy(:T__93) { 93 }
    const_attr_reader  :T__93
    
    const_set_lazy(:T__94) { 94 }
    const_attr_reader  :T__94
    
    const_set_lazy(:T__91) { 91 }
    const_attr_reader  :T__91
    
    const_set_lazy(:T__92) { 92 }
    const_attr_reader  :T__92
    
    const_set_lazy(:T__90) { 90 }
    const_attr_reader  :T__90
    
    const_set_lazy(:COMMENT) { 23 }
    const_attr_reader  :COMMENT
    
    const_set_lazy(:T__99) { 99 }
    const_attr_reader  :T__99
    
    const_set_lazy(:T__98) { 98 }
    const_attr_reader  :T__98
    
    const_set_lazy(:T__97) { 97 }
    const_attr_reader  :T__97
    
    const_set_lazy(:T__96) { 96 }
    const_attr_reader  :T__96
    
    const_set_lazy(:T__95) { 95 }
    const_attr_reader  :T__95
    
    const_set_lazy(:T__80) { 80 }
    const_attr_reader  :T__80
    
    const_set_lazy(:T__81) { 81 }
    const_attr_reader  :T__81
    
    const_set_lazy(:T__82) { 82 }
    const_attr_reader  :T__82
    
    const_set_lazy(:T__83) { 83 }
    const_attr_reader  :T__83
    
    const_set_lazy(:LINE_COMMENT) { 24 }
    const_attr_reader  :LINE_COMMENT
    
    const_set_lazy(:IntegerTypeSuffix) { 14 }
    const_attr_reader  :IntegerTypeSuffix
    
    const_set_lazy(:T__85) { 85 }
    const_attr_reader  :T__85
    
    const_set_lazy(:T__84) { 84 }
    const_attr_reader  :T__84
    
    const_set_lazy(:T__87) { 87 }
    const_attr_reader  :T__87
    
    const_set_lazy(:ASSERT) { 12 }
    const_attr_reader  :ASSERT
    
    const_set_lazy(:T__86) { 86 }
    const_attr_reader  :T__86
    
    const_set_lazy(:T__89) { 89 }
    const_attr_reader  :T__89
    
    const_set_lazy(:T__88) { 88 }
    const_attr_reader  :T__88
    
    const_set_lazy(:T__71) { 71 }
    const_attr_reader  :T__71
    
    const_set_lazy(:WS) { 22 }
    const_attr_reader  :WS
    
    const_set_lazy(:T__72) { 72 }
    const_attr_reader  :T__72
    
    const_set_lazy(:T__70) { 70 }
    const_attr_reader  :T__70
    
    const_set_lazy(:FloatingPointLiteral) { 6 }
    const_attr_reader  :FloatingPointLiteral
    
    const_set_lazy(:JavaIDDigit) { 21 }
    const_attr_reader  :JavaIDDigit
    
    const_set_lazy(:T__76) { 76 }
    const_attr_reader  :T__76
    
    const_set_lazy(:T__75) { 75 }
    const_attr_reader  :T__75
    
    const_set_lazy(:T__74) { 74 }
    const_attr_reader  :T__74
    
    const_set_lazy(:Letter) { 20 }
    const_attr_reader  :Letter
    
    const_set_lazy(:EscapeSequence) { 17 }
    const_attr_reader  :EscapeSequence
    
    const_set_lazy(:T__73) { 73 }
    const_attr_reader  :T__73
    
    const_set_lazy(:T__79) { 79 }
    const_attr_reader  :T__79
    
    const_set_lazy(:T__78) { 78 }
    const_attr_reader  :T__78
    
    const_set_lazy(:T__77) { 77 }
    const_attr_reader  :T__77
    
    const_set_lazy(:T__68) { 68 }
    const_attr_reader  :T__68
    
    const_set_lazy(:T__69) { 69 }
    const_attr_reader  :T__69
    
    const_set_lazy(:T__66) { 66 }
    const_attr_reader  :T__66
    
    const_set_lazy(:T__67) { 67 }
    const_attr_reader  :T__67
    
    const_set_lazy(:T__64) { 64 }
    const_attr_reader  :T__64
    
    const_set_lazy(:T__65) { 65 }
    const_attr_reader  :T__65
    
    const_set_lazy(:T__62) { 62 }
    const_attr_reader  :T__62
    
    const_set_lazy(:T__63) { 63 }
    const_attr_reader  :T__63
    
    const_set_lazy(:CharacterLiteral) { 7 }
    const_attr_reader  :CharacterLiteral
    
    const_set_lazy(:Exponent) { 15 }
    const_attr_reader  :Exponent
    
    const_set_lazy(:T__61) { 61 }
    const_attr_reader  :T__61
    
    const_set_lazy(:T__60) { 60 }
    const_attr_reader  :T__60
    
    const_set_lazy(:HexDigit) { 13 }
    const_attr_reader  :HexDigit
    
    const_set_lazy(:T__55) { 55 }
    const_attr_reader  :T__55
    
    const_set_lazy(:T__56) { 56 }
    const_attr_reader  :T__56
    
    const_set_lazy(:T__57) { 57 }
    const_attr_reader  :T__57
    
    const_set_lazy(:T__58) { 58 }
    const_attr_reader  :T__58
    
    const_set_lazy(:T__51) { 51 }
    const_attr_reader  :T__51
    
    const_set_lazy(:T__52) { 52 }
    const_attr_reader  :T__52
    
    const_set_lazy(:T__53) { 53 }
    const_attr_reader  :T__53
    
    const_set_lazy(:T__54) { 54 }
    const_attr_reader  :T__54
    
    const_set_lazy(:T__107) { 107 }
    const_attr_reader  :T__107
    
    const_set_lazy(:T__108) { 108 }
    const_attr_reader  :T__108
    
    const_set_lazy(:T__109) { 109 }
    const_attr_reader  :T__109
    
    const_set_lazy(:T__59) { 59 }
    const_attr_reader  :T__59
    
    const_set_lazy(:T__103) { 103 }
    const_attr_reader  :T__103
    
    const_set_lazy(:T__104) { 104 }
    const_attr_reader  :T__104
    
    const_set_lazy(:T__105) { 105 }
    const_attr_reader  :T__105
    
    const_set_lazy(:T__106) { 106 }
    const_attr_reader  :T__106
    
    const_set_lazy(:T__111) { 111 }
    const_attr_reader  :T__111
    
    const_set_lazy(:T__110) { 110 }
    const_attr_reader  :T__110
    
    const_set_lazy(:T__113) { 113 }
    const_attr_reader  :T__113
    
    const_set_lazy(:T__112) { 112 }
    const_attr_reader  :T__112
    
    const_set_lazy(:T__50) { 50 }
    const_attr_reader  :T__50
    
    const_set_lazy(:T__42) { 42 }
    const_attr_reader  :T__42
    
    const_set_lazy(:HexLiteral) { 9 }
    const_attr_reader  :HexLiteral
    
    const_set_lazy(:T__43) { 43 }
    const_attr_reader  :T__43
    
    const_set_lazy(:T__40) { 40 }
    const_attr_reader  :T__40
    
    const_set_lazy(:T__41) { 41 }
    const_attr_reader  :T__41
    
    const_set_lazy(:T__46) { 46 }
    const_attr_reader  :T__46
    
    const_set_lazy(:T__47) { 47 }
    const_attr_reader  :T__47
    
    const_set_lazy(:T__44) { 44 }
    const_attr_reader  :T__44
    
    const_set_lazy(:T__45) { 45 }
    const_attr_reader  :T__45
    
    const_set_lazy(:T__48) { 48 }
    const_attr_reader  :T__48
    
    const_set_lazy(:T__49) { 49 }
    const_attr_reader  :T__49
    
    const_set_lazy(:T__102) { 102 }
    const_attr_reader  :T__102
    
    const_set_lazy(:T__101) { 101 }
    const_attr_reader  :T__101
    
    const_set_lazy(:T__100) { 100 }
    const_attr_reader  :T__100
    
    const_set_lazy(:DecimalLiteral) { 11 }
    const_attr_reader  :DecimalLiteral
    
    const_set_lazy(:StringLiteral) { 8 }
    const_attr_reader  :StringLiteral
    
    const_set_lazy(:T__30) { 30 }
    const_attr_reader  :T__30
    
    const_set_lazy(:T__31) { 31 }
    const_attr_reader  :T__31
    
    const_set_lazy(:T__32) { 32 }
    const_attr_reader  :T__32
    
    const_set_lazy(:T__33) { 33 }
    const_attr_reader  :T__33
    
    const_set_lazy(:T__34) { 34 }
    const_attr_reader  :T__34
    
    const_set_lazy(:ENUM) { 5 }
    const_attr_reader  :ENUM
    
    const_set_lazy(:T__35) { 35 }
    const_attr_reader  :T__35
    
    const_set_lazy(:T__36) { 36 }
    const_attr_reader  :T__36
    
    const_set_lazy(:T__37) { 37 }
    const_attr_reader  :T__37
    
    const_set_lazy(:T__38) { 38 }
    const_attr_reader  :T__38
    
    const_set_lazy(:T__39) { 39 }
    const_attr_reader  :T__39
    
    const_set_lazy(:UnicodeEscape) { 18 }
    const_attr_reader  :UnicodeEscape
    
    const_set_lazy(:OctalEscape) { 19 }
    const_attr_reader  :OctalEscape
  }
  
  attr_accessor :enum_is_keyword
  alias_method :attr_enum_is_keyword, :enum_is_keyword
  undef_method :enum_is_keyword
  alias_method :attr_enum_is_keyword=, :enum_is_keyword=
  undef_method :enum_is_keyword=
  
  attr_accessor :assert_is_keyword
  alias_method :attr_assert_is_keyword, :assert_is_keyword
  undef_method :assert_is_keyword
  alias_method :attr_assert_is_keyword=, :assert_is_keyword=
  undef_method :assert_is_keyword=
  
  typesig { [] }
  # delegates
  # delegators
  def initialize
    @enum_is_keyword = false
    @assert_is_keyword = false
    @dfa18 = nil
    @dfa29 = nil
    super()
    @enum_is_keyword = true
    @assert_is_keyword = true
    @dfa18 = DFA18.new_local(self, self)
    @dfa29 = DFA29.new_local(self, self)
  end
  
  typesig { [CharStream] }
  def initialize(input)
    initialize__java_lexer(input, RecognizerSharedState.new)
  end
  
  typesig { [CharStream, RecognizerSharedState] }
  def initialize(input, state)
    @enum_is_keyword = false
    @assert_is_keyword = false
    @dfa18 = nil
    @dfa29 = nil
    super(input, state)
    @enum_is_keyword = true
    @assert_is_keyword = true
    @dfa18 = DFA18.new_local(self, self)
    @dfa29 = DFA29.new_local(self, self)
  end
  
  typesig { [] }
  def get_grammar_file_name
    return "Java.g"
  end
  
  typesig { [] }
  # $ANTLR start "T__25"
  def m_t__25
    begin
      _type = T__25
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:8:7: ( 'package' )
      # Java.g:8:9: 'package'
      match("package")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__25"
  # $ANTLR start "T__26"
  def m_t__26
    begin
      _type = T__26
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:9:7: ( ';' )
      # Java.g:9:9: ';'
      match(Character.new(?;.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__26"
  # $ANTLR start "T__27"
  def m_t__27
    begin
      _type = T__27
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:10:7: ( 'import' )
      # Java.g:10:9: 'import'
      match("import")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__27"
  # $ANTLR start "T__28"
  def m_t__28
    begin
      _type = T__28
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:11:7: ( 'static' )
      # Java.g:11:9: 'static'
      match("static")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__28"
  # $ANTLR start "T__29"
  def m_t__29
    begin
      _type = T__29
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:12:7: ( '.' )
      # Java.g:12:9: '.'
      match(Character.new(?..ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__29"
  # $ANTLR start "T__30"
  def m_t__30
    begin
      _type = T__30
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:13:7: ( '*' )
      # Java.g:13:9: '*'
      match(Character.new(?*.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__30"
  # $ANTLR start "T__31"
  def m_t__31
    begin
      _type = T__31
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:14:7: ( 'public' )
      # Java.g:14:9: 'public'
      match("public")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__31"
  # $ANTLR start "T__32"
  def m_t__32
    begin
      _type = T__32
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:15:7: ( 'protected' )
      # Java.g:15:9: 'protected'
      match("protected")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__32"
  # $ANTLR start "T__33"
  def m_t__33
    begin
      _type = T__33
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:16:7: ( 'private' )
      # Java.g:16:9: 'private'
      match("private")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__33"
  # $ANTLR start "T__34"
  def m_t__34
    begin
      _type = T__34
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:17:7: ( 'abstract' )
      # Java.g:17:9: 'abstract'
      match("abstract")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__34"
  # $ANTLR start "T__35"
  def m_t__35
    begin
      _type = T__35
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:18:7: ( 'final' )
      # Java.g:18:9: 'final'
      match("final")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__35"
  # $ANTLR start "T__36"
  def m_t__36
    begin
      _type = T__36
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:19:7: ( 'strictfp' )
      # Java.g:19:9: 'strictfp'
      match("strictfp")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__36"
  # $ANTLR start "T__37"
  def m_t__37
    begin
      _type = T__37
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:20:7: ( 'class' )
      # Java.g:20:9: 'class'
      match("class")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__37"
  # $ANTLR start "T__38"
  def m_t__38
    begin
      _type = T__38
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:21:7: ( 'extends' )
      # Java.g:21:9: 'extends'
      match("extends")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__38"
  # $ANTLR start "T__39"
  def m_t__39
    begin
      _type = T__39
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:22:7: ( 'implements' )
      # Java.g:22:9: 'implements'
      match("implements")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__39"
  # $ANTLR start "T__40"
  def m_t__40
    begin
      _type = T__40
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:23:7: ( '<' )
      # Java.g:23:9: '<'
      match(Character.new(?<.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__40"
  # $ANTLR start "T__41"
  def m_t__41
    begin
      _type = T__41
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:24:7: ( ',' )
      # Java.g:24:9: ','
      match(Character.new(?,.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__41"
  # $ANTLR start "T__42"
  def m_t__42
    begin
      _type = T__42
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:25:7: ( '>' )
      # Java.g:25:9: '>'
      match(Character.new(?>.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__42"
  # $ANTLR start "T__43"
  def m_t__43
    begin
      _type = T__43
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:26:7: ( '&' )
      # Java.g:26:9: '&'
      match(Character.new(?&.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__43"
  # $ANTLR start "T__44"
  def m_t__44
    begin
      _type = T__44
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:27:7: ( '{' )
      # Java.g:27:9: '{'
      match(Character.new(?{.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__44"
  # $ANTLR start "T__45"
  def m_t__45
    begin
      _type = T__45
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:28:7: ( '}' )
      # Java.g:28:9: '}'
      match(Character.new(?}.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__45"
  # $ANTLR start "T__46"
  def m_t__46
    begin
      _type = T__46
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:29:7: ( 'interface' )
      # Java.g:29:9: 'interface'
      match("interface")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__46"
  # $ANTLR start "T__47"
  def m_t__47
    begin
      _type = T__47
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:30:7: ( 'void' )
      # Java.g:30:9: 'void'
      match("void")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__47"
  # $ANTLR start "T__48"
  def m_t__48
    begin
      _type = T__48
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:31:7: ( '[' )
      # Java.g:31:9: '['
      match(Character.new(?[.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__48"
  # $ANTLR start "T__49"
  def m_t__49
    begin
      _type = T__49
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:32:7: ( ']' )
      # Java.g:32:9: ']'
      match(Character.new(?].ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__49"
  # $ANTLR start "T__50"
  def m_t__50
    begin
      _type = T__50
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:33:7: ( 'throws' )
      # Java.g:33:9: 'throws'
      match("throws")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__50"
  # $ANTLR start "T__51"
  def m_t__51
    begin
      _type = T__51
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:34:7: ( '=' )
      # Java.g:34:9: '='
      match(Character.new(?=.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__51"
  # $ANTLR start "T__52"
  def m_t__52
    begin
      _type = T__52
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:35:7: ( 'native' )
      # Java.g:35:9: 'native'
      match("native")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__52"
  # $ANTLR start "T__53"
  def m_t__53
    begin
      _type = T__53
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:36:7: ( 'synchronized' )
      # Java.g:36:9: 'synchronized'
      match("synchronized")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__53"
  # $ANTLR start "T__54"
  def m_t__54
    begin
      _type = T__54
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:37:7: ( 'transient' )
      # Java.g:37:9: 'transient'
      match("transient")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__54"
  # $ANTLR start "T__55"
  def m_t__55
    begin
      _type = T__55
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:38:7: ( 'volatile' )
      # Java.g:38:9: 'volatile'
      match("volatile")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__55"
  # $ANTLR start "T__56"
  def m_t__56
    begin
      _type = T__56
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:39:7: ( 'boolean' )
      # Java.g:39:9: 'boolean'
      match("boolean")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__56"
  # $ANTLR start "T__57"
  def m_t__57
    begin
      _type = T__57
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:40:7: ( 'char' )
      # Java.g:40:9: 'char'
      match("char")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__57"
  # $ANTLR start "T__58"
  def m_t__58
    begin
      _type = T__58
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:41:7: ( 'byte' )
      # Java.g:41:9: 'byte'
      match("byte")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__58"
  # $ANTLR start "T__59"
  def m_t__59
    begin
      _type = T__59
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:42:7: ( 'short' )
      # Java.g:42:9: 'short'
      match("short")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__59"
  # $ANTLR start "T__60"
  def m_t__60
    begin
      _type = T__60
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:43:7: ( 'int' )
      # Java.g:43:9: 'int'
      match("int")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__60"
  # $ANTLR start "T__61"
  def m_t__61
    begin
      _type = T__61
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:44:7: ( 'long' )
      # Java.g:44:9: 'long'
      match("long")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__61"
  # $ANTLR start "T__62"
  def m_t__62
    begin
      _type = T__62
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:45:7: ( 'float' )
      # Java.g:45:9: 'float'
      match("float")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__62"
  # $ANTLR start "T__63"
  def m_t__63
    begin
      _type = T__63
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:46:7: ( 'double' )
      # Java.g:46:9: 'double'
      match("double")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__63"
  # $ANTLR start "T__64"
  def m_t__64
    begin
      _type = T__64
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:47:7: ( '?' )
      # Java.g:47:9: '?'
      match(Character.new(??.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__64"
  # $ANTLR start "T__65"
  def m_t__65
    begin
      _type = T__65
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:48:7: ( 'super' )
      # Java.g:48:9: 'super'
      match("super")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__65"
  # $ANTLR start "T__66"
  def m_t__66
    begin
      _type = T__66
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:49:7: ( '(' )
      # Java.g:49:9: '('
      match(Character.new(?(.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__66"
  # $ANTLR start "T__67"
  def m_t__67
    begin
      _type = T__67
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:50:7: ( ')' )
      # Java.g:50:9: ')'
      match(Character.new(?).ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__67"
  # $ANTLR start "T__68"
  def m_t__68
    begin
      _type = T__68
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:51:7: ( '...' )
      # Java.g:51:9: '...'
      match("...")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__68"
  # $ANTLR start "T__69"
  def m_t__69
    begin
      _type = T__69
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:52:7: ( 'this' )
      # Java.g:52:9: 'this'
      match("this")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__69"
  # $ANTLR start "T__70"
  def m_t__70
    begin
      _type = T__70
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:53:7: ( 'null' )
      # Java.g:53:9: 'null'
      match("null")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__70"
  # $ANTLR start "T__71"
  def m_t__71
    begin
      _type = T__71
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:54:7: ( 'true' )
      # Java.g:54:9: 'true'
      match("true")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__71"
  # $ANTLR start "T__72"
  def m_t__72
    begin
      _type = T__72
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:55:7: ( 'false' )
      # Java.g:55:9: 'false'
      match("false")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__72"
  # $ANTLR start "T__73"
  def m_t__73
    begin
      _type = T__73
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:56:7: ( '@' )
      # Java.g:56:9: '@'
      match(Character.new(?@.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__73"
  # $ANTLR start "T__74"
  def m_t__74
    begin
      _type = T__74
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:57:7: ( 'default' )
      # Java.g:57:9: 'default'
      match("default")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__74"
  # $ANTLR start "T__75"
  def m_t__75
    begin
      _type = T__75
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:58:7: ( ':' )
      # Java.g:58:9: ':'
      match(Character.new(?:.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__75"
  # $ANTLR start "T__76"
  def m_t__76
    begin
      _type = T__76
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:59:7: ( 'if' )
      # Java.g:59:9: 'if'
      match("if")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__76"
  # $ANTLR start "T__77"
  def m_t__77
    begin
      _type = T__77
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:60:7: ( 'else' )
      # Java.g:60:9: 'else'
      match("else")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__77"
  # $ANTLR start "T__78"
  def m_t__78
    begin
      _type = T__78
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:61:7: ( 'for' )
      # Java.g:61:9: 'for'
      match("for")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__78"
  # $ANTLR start "T__79"
  def m_t__79
    begin
      _type = T__79
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:62:7: ( 'while' )
      # Java.g:62:9: 'while'
      match("while")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__79"
  # $ANTLR start "T__80"
  def m_t__80
    begin
      _type = T__80
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:63:7: ( 'do' )
      # Java.g:63:9: 'do'
      match("do")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__80"
  # $ANTLR start "T__81"
  def m_t__81
    begin
      _type = T__81
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:64:7: ( 'try' )
      # Java.g:64:9: 'try'
      match("try")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__81"
  # $ANTLR start "T__82"
  def m_t__82
    begin
      _type = T__82
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:65:7: ( 'finally' )
      # Java.g:65:9: 'finally'
      match("finally")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__82"
  # $ANTLR start "T__83"
  def m_t__83
    begin
      _type = T__83
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:66:7: ( 'switch' )
      # Java.g:66:9: 'switch'
      match("switch")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__83"
  # $ANTLR start "T__84"
  def m_t__84
    begin
      _type = T__84
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:67:7: ( 'return' )
      # Java.g:67:9: 'return'
      match("return")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__84"
  # $ANTLR start "T__85"
  def m_t__85
    begin
      _type = T__85
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:68:7: ( 'throw' )
      # Java.g:68:9: 'throw'
      match("throw")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__85"
  # $ANTLR start "T__86"
  def m_t__86
    begin
      _type = T__86
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:69:7: ( 'break' )
      # Java.g:69:9: 'break'
      match("break")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__86"
  # $ANTLR start "T__87"
  def m_t__87
    begin
      _type = T__87
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:70:7: ( 'continue' )
      # Java.g:70:9: 'continue'
      match("continue")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__87"
  # $ANTLR start "T__88"
  def m_t__88
    begin
      _type = T__88
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:71:7: ( 'catch' )
      # Java.g:71:9: 'catch'
      match("catch")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__88"
  # $ANTLR start "T__89"
  def m_t__89
    begin
      _type = T__89
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:72:7: ( 'case' )
      # Java.g:72:9: 'case'
      match("case")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__89"
  # $ANTLR start "T__90"
  def m_t__90
    begin
      _type = T__90
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:73:7: ( '+=' )
      # Java.g:73:9: '+='
      match("+=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__90"
  # $ANTLR start "T__91"
  def m_t__91
    begin
      _type = T__91
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:74:7: ( '-=' )
      # Java.g:74:9: '-='
      match("-=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__91"
  # $ANTLR start "T__92"
  def m_t__92
    begin
      _type = T__92
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:75:7: ( '*=' )
      # Java.g:75:9: '*='
      match("*=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__92"
  # $ANTLR start "T__93"
  def m_t__93
    begin
      _type = T__93
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:76:7: ( '/=' )
      # Java.g:76:9: '/='
      match("/=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__93"
  # $ANTLR start "T__94"
  def m_t__94
    begin
      _type = T__94
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:77:7: ( '&=' )
      # Java.g:77:9: '&='
      match("&=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__94"
  # $ANTLR start "T__95"
  def m_t__95
    begin
      _type = T__95
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:78:7: ( '|=' )
      # Java.g:78:9: '|='
      match("|=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__95"
  # $ANTLR start "T__96"
  def m_t__96
    begin
      _type = T__96
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:79:7: ( '^=' )
      # Java.g:79:9: '^='
      match("^=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__96"
  # $ANTLR start "T__97"
  def m_t__97
    begin
      _type = T__97
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:80:7: ( '%=' )
      # Java.g:80:9: '%='
      match("%=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__97"
  # $ANTLR start "T__98"
  def m_t__98
    begin
      _type = T__98
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:81:7: ( '||' )
      # Java.g:81:9: '||'
      match("||")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__98"
  # $ANTLR start "T__99"
  def m_t__99
    begin
      _type = T__99
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:82:7: ( '&&' )
      # Java.g:82:9: '&&'
      match("&&")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__99"
  # $ANTLR start "T__100"
  def m_t__100
    begin
      _type = T__100
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:83:8: ( '|' )
      # Java.g:83:10: '|'
      match(Character.new(?|.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__100"
  # $ANTLR start "T__101"
  def m_t__101
    begin
      _type = T__101
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:84:8: ( '^' )
      # Java.g:84:10: '^'
      match(Character.new(?^.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__101"
  # $ANTLR start "T__102"
  def m_t__102
    begin
      _type = T__102
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:85:8: ( '==' )
      # Java.g:85:10: '=='
      match("==")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__102"
  # $ANTLR start "T__103"
  def m_t__103
    begin
      _type = T__103
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:86:8: ( '!=' )
      # Java.g:86:10: '!='
      match("!=")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__103"
  # $ANTLR start "T__104"
  def m_t__104
    begin
      _type = T__104
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:87:8: ( 'instanceof' )
      # Java.g:87:10: 'instanceof'
      match("instanceof")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__104"
  # $ANTLR start "T__105"
  def m_t__105
    begin
      _type = T__105
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:88:8: ( '+' )
      # Java.g:88:10: '+'
      match(Character.new(?+.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__105"
  # $ANTLR start "T__106"
  def m_t__106
    begin
      _type = T__106
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:89:8: ( '-' )
      # Java.g:89:10: '-'
      match(Character.new(?-.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__106"
  # $ANTLR start "T__107"
  def m_t__107
    begin
      _type = T__107
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:90:8: ( '/' )
      # Java.g:90:10: '/'
      match(Character.new(?/.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__107"
  # $ANTLR start "T__108"
  def m_t__108
    begin
      _type = T__108
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:91:8: ( '%' )
      # Java.g:91:10: '%'
      match(Character.new(?%.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__108"
  # $ANTLR start "T__109"
  def m_t__109
    begin
      _type = T__109
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:92:8: ( '++' )
      # Java.g:92:10: '++'
      match("++")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__109"
  # $ANTLR start "T__110"
  def m_t__110
    begin
      _type = T__110
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:93:8: ( '--' )
      # Java.g:93:10: '--'
      match("--")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__110"
  # $ANTLR start "T__111"
  def m_t__111
    begin
      _type = T__111
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:94:8: ( '~' )
      # Java.g:94:10: '~'
      match(Character.new(?~.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__111"
  # $ANTLR start "T__112"
  def m_t__112
    begin
      _type = T__112
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:95:8: ( '!' )
      # Java.g:95:10: '!'
      match(Character.new(?!.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__112"
  # $ANTLR start "T__113"
  def m_t__113
    begin
      _type = T__113
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:96:8: ( 'new' )
      # Java.g:96:10: 'new'
      match("new")
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "T__113"
  # $ANTLR start "HexLiteral"
  def m_hex_literal
    begin
      _type = HexLiteral
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:909:12: ( '0' ( 'x' | 'X' ) ( HexDigit )+ ( IntegerTypeSuffix )? )
      # Java.g:909:14: '0' ( 'x' | 'X' ) ( HexDigit )+ ( IntegerTypeSuffix )?
      match(Character.new(?0.ord))
      if ((self.attr_input._la(1)).equal?(Character.new(?X.ord)) || (self.attr_input._la(1)).equal?(Character.new(?x.ord)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
      # Java.g:909:28: ( HexDigit )+
      cnt1 = 0
      begin
        alt1 = 2
        la1_0 = self.attr_input._la(1)
        if (((la1_0 >= Character.new(?0.ord) && la1_0 <= Character.new(?9.ord)) || (la1_0 >= Character.new(?A.ord) && la1_0 <= Character.new(?F.ord)) || (la1_0 >= Character.new(?a.ord) && la1_0 <= Character.new(?f.ord))))
          alt1 = 1
        end
        case (alt1)
        when 1
          # Java.g:909:28: HexDigit
          m_hex_digit
        else
          if (cnt1 >= 1)
            break
          end
          eee = EarlyExitException.new(1, self.attr_input)
          raise eee
        end
        ((cnt1 += 1) - 1)
      end while (true)
      # Java.g:909:38: ( IntegerTypeSuffix )?
      alt2 = 2
      la2_0 = self.attr_input._la(1)
      if (((la2_0).equal?(Character.new(?L.ord)) || (la2_0).equal?(Character.new(?l.ord))))
        alt2 = 1
      end
      case (alt2)
      when 1
        # Java.g:909:38: IntegerTypeSuffix
        m_integer_type_suffix
      end
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "HexLiteral"
  # $ANTLR start "DecimalLiteral"
  def m_decimal_literal
    begin
      _type = DecimalLiteral
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:911:16: ( ( '0' | '1' .. '9' ( '0' .. '9' )* ) ( IntegerTypeSuffix )? )
      # Java.g:911:18: ( '0' | '1' .. '9' ( '0' .. '9' )* ) ( IntegerTypeSuffix )?
      # Java.g:911:18: ( '0' | '1' .. '9' ( '0' .. '9' )* )
      alt4 = 2
      la4_0 = self.attr_input._la(1)
      if (((la4_0).equal?(Character.new(?0.ord))))
        alt4 = 1
      else
        if (((la4_0 >= Character.new(?1.ord) && la4_0 <= Character.new(?9.ord))))
          alt4 = 2
        else
          nvae = NoViableAltException.new("", 4, 0, self.attr_input)
          raise nvae
        end
      end
      case (alt4)
      when 1
        # Java.g:911:19: '0'
        match(Character.new(?0.ord))
      when 2
        # Java.g:911:25: '1' .. '9' ( '0' .. '9' )*
        match_range(Character.new(?1.ord), Character.new(?9.ord))
        # Java.g:911:34: ( '0' .. '9' )*
        begin
          alt3 = 2
          la3_0 = self.attr_input._la(1)
          if (((la3_0 >= Character.new(?0.ord) && la3_0 <= Character.new(?9.ord))))
            alt3 = 1
          end
          case (alt3)
          when 1
            # Java.g:911:34: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            break
          end
        end while (true)
      end
      # Java.g:911:45: ( IntegerTypeSuffix )?
      alt5 = 2
      la5_0 = self.attr_input._la(1)
      if (((la5_0).equal?(Character.new(?L.ord)) || (la5_0).equal?(Character.new(?l.ord))))
        alt5 = 1
      end
      case (alt5)
      when 1
        # Java.g:911:45: IntegerTypeSuffix
        m_integer_type_suffix
      end
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "DecimalLiteral"
  # $ANTLR start "OctalLiteral"
  def m_octal_literal
    begin
      _type = OctalLiteral
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:913:14: ( '0' ( '0' .. '7' )+ ( IntegerTypeSuffix )? )
      # Java.g:913:16: '0' ( '0' .. '7' )+ ( IntegerTypeSuffix )?
      match(Character.new(?0.ord))
      # Java.g:913:20: ( '0' .. '7' )+
      cnt6 = 0
      begin
        alt6 = 2
        la6_0 = self.attr_input._la(1)
        if (((la6_0 >= Character.new(?0.ord) && la6_0 <= Character.new(?7.ord))))
          alt6 = 1
        end
        case (alt6)
        when 1
          # Java.g:913:21: '0' .. '7'
          match_range(Character.new(?0.ord), Character.new(?7.ord))
        else
          if (cnt6 >= 1)
            break
          end
          eee = EarlyExitException.new(6, self.attr_input)
          raise eee
        end
        ((cnt6 += 1) - 1)
      end while (true)
      # Java.g:913:32: ( IntegerTypeSuffix )?
      alt7 = 2
      la7_0 = self.attr_input._la(1)
      if (((la7_0).equal?(Character.new(?L.ord)) || (la7_0).equal?(Character.new(?l.ord))))
        alt7 = 1
      end
      case (alt7)
      when 1
        # Java.g:913:32: IntegerTypeSuffix
        m_integer_type_suffix
      end
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "OctalLiteral"
  # $ANTLR start "HexDigit"
  def m_hex_digit
    begin
      # Java.g:916:10: ( ( '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' ) )
      # Java.g:916:12: ( '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' )
      if ((self.attr_input._la(1) >= Character.new(?0.ord) && self.attr_input._la(1) <= Character.new(?9.ord)) || (self.attr_input._la(1) >= Character.new(?A.ord) && self.attr_input._la(1) <= Character.new(?F.ord)) || (self.attr_input._la(1) >= Character.new(?a.ord) && self.attr_input._la(1) <= Character.new(?f.ord)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "HexDigit"
  # $ANTLR start "IntegerTypeSuffix"
  def m_integer_type_suffix
    begin
      # Java.g:919:19: ( ( 'l' | 'L' ) )
      # Java.g:919:21: ( 'l' | 'L' )
      if ((self.attr_input._la(1)).equal?(Character.new(?L.ord)) || (self.attr_input._la(1)).equal?(Character.new(?l.ord)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "IntegerTypeSuffix"
  # $ANTLR start "FloatingPointLiteral"
  def m_floating_point_literal
    begin
      _type = FloatingPointLiteral
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:922:5: ( ( '0' .. '9' )+ '.' ( '0' .. '9' )* ( Exponent )? ( FloatTypeSuffix )? | '.' ( '0' .. '9' )+ ( Exponent )? ( FloatTypeSuffix )? | ( '0' .. '9' )+ Exponent ( FloatTypeSuffix )? | ( '0' .. '9' )+ FloatTypeSuffix )
      alt18 = 4
      alt18 = @dfa18.predict(self.attr_input)
      case (alt18)
      when 1
        # Java.g:922:9: ( '0' .. '9' )+ '.' ( '0' .. '9' )* ( Exponent )? ( FloatTypeSuffix )?
        # Java.g:922:9: ( '0' .. '9' )+
        cnt8 = 0
        begin
          alt8 = 2
          la8_0 = self.attr_input._la(1)
          if (((la8_0 >= Character.new(?0.ord) && la8_0 <= Character.new(?9.ord))))
            alt8 = 1
          end
          case (alt8)
          when 1
            # Java.g:922:10: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            if (cnt8 >= 1)
              break
            end
            eee = EarlyExitException.new(8, self.attr_input)
            raise eee
          end
          ((cnt8 += 1) - 1)
        end while (true)
        match(Character.new(?..ord))
        # Java.g:922:25: ( '0' .. '9' )*
        begin
          alt9 = 2
          la9_0 = self.attr_input._la(1)
          if (((la9_0 >= Character.new(?0.ord) && la9_0 <= Character.new(?9.ord))))
            alt9 = 1
          end
          case (alt9)
          when 1
            # Java.g:922:26: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            break
          end
        end while (true)
        # Java.g:922:37: ( Exponent )?
        alt10 = 2
        la10_0 = self.attr_input._la(1)
        if (((la10_0).equal?(Character.new(?E.ord)) || (la10_0).equal?(Character.new(?e.ord))))
          alt10 = 1
        end
        case (alt10)
        when 1
          # Java.g:922:37: Exponent
          m_exponent
        end
        # Java.g:922:47: ( FloatTypeSuffix )?
        alt11 = 2
        la11_0 = self.attr_input._la(1)
        if (((la11_0).equal?(Character.new(?D.ord)) || (la11_0).equal?(Character.new(?F.ord)) || (la11_0).equal?(Character.new(?d.ord)) || (la11_0).equal?(Character.new(?f.ord))))
          alt11 = 1
        end
        case (alt11)
        when 1
          # Java.g:922:47: FloatTypeSuffix
          m_float_type_suffix
        end
      when 2
        # Java.g:923:9: '.' ( '0' .. '9' )+ ( Exponent )? ( FloatTypeSuffix )?
        match(Character.new(?..ord))
        # Java.g:923:13: ( '0' .. '9' )+
        cnt12 = 0
        begin
          alt12 = 2
          la12_0 = self.attr_input._la(1)
          if (((la12_0 >= Character.new(?0.ord) && la12_0 <= Character.new(?9.ord))))
            alt12 = 1
          end
          case (alt12)
          when 1
            # Java.g:923:14: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            if (cnt12 >= 1)
              break
            end
            eee_ = EarlyExitException.new(12, self.attr_input)
            raise eee_
          end
          ((cnt12 += 1) - 1)
        end while (true)
        # Java.g:923:25: ( Exponent )?
        alt13 = 2
        la13_0 = self.attr_input._la(1)
        if (((la13_0).equal?(Character.new(?E.ord)) || (la13_0).equal?(Character.new(?e.ord))))
          alt13 = 1
        end
        case (alt13)
        when 1
          # Java.g:923:25: Exponent
          m_exponent
        end
        # Java.g:923:35: ( FloatTypeSuffix )?
        alt14 = 2
        la14_0 = self.attr_input._la(1)
        if (((la14_0).equal?(Character.new(?D.ord)) || (la14_0).equal?(Character.new(?F.ord)) || (la14_0).equal?(Character.new(?d.ord)) || (la14_0).equal?(Character.new(?f.ord))))
          alt14 = 1
        end
        case (alt14)
        when 1
          # Java.g:923:35: FloatTypeSuffix
          m_float_type_suffix
        end
      when 3
        # Java.g:924:9: ( '0' .. '9' )+ Exponent ( FloatTypeSuffix )?
        # Java.g:924:9: ( '0' .. '9' )+
        cnt15 = 0
        begin
          alt15 = 2
          la15_0 = self.attr_input._la(1)
          if (((la15_0 >= Character.new(?0.ord) && la15_0 <= Character.new(?9.ord))))
            alt15 = 1
          end
          case (alt15)
          when 1
            # Java.g:924:10: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            if (cnt15 >= 1)
              break
            end
            eee__ = EarlyExitException.new(15, self.attr_input)
            raise eee__
          end
          ((cnt15 += 1) - 1)
        end while (true)
        m_exponent
        # Java.g:924:30: ( FloatTypeSuffix )?
        alt16 = 2
        la16_0 = self.attr_input._la(1)
        if (((la16_0).equal?(Character.new(?D.ord)) || (la16_0).equal?(Character.new(?F.ord)) || (la16_0).equal?(Character.new(?d.ord)) || (la16_0).equal?(Character.new(?f.ord))))
          alt16 = 1
        end
        case (alt16)
        when 1
          # Java.g:924:30: FloatTypeSuffix
          m_float_type_suffix
        end
      when 4
        # Java.g:925:9: ( '0' .. '9' )+ FloatTypeSuffix
        # Java.g:925:9: ( '0' .. '9' )+
        cnt17 = 0
        begin
          alt17 = 2
          la17_0 = self.attr_input._la(1)
          if (((la17_0 >= Character.new(?0.ord) && la17_0 <= Character.new(?9.ord))))
            alt17 = 1
          end
          case (alt17)
          when 1
            # Java.g:925:10: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            if (cnt17 >= 1)
              break
            end
            eee___ = EarlyExitException.new(17, self.attr_input)
            raise eee___
          end
          ((cnt17 += 1) - 1)
        end while (true)
        m_float_type_suffix
      end
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "FloatingPointLiteral"
  # $ANTLR start "Exponent"
  def m_exponent
    begin
      # Java.g:929:10: ( ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+ )
      # Java.g:929:12: ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+
      if ((self.attr_input._la(1)).equal?(Character.new(?E.ord)) || (self.attr_input._la(1)).equal?(Character.new(?e.ord)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
      # Java.g:929:22: ( '+' | '-' )?
      alt19 = 2
      la19_0 = self.attr_input._la(1)
      if (((la19_0).equal?(Character.new(?+.ord)) || (la19_0).equal?(Character.new(?-.ord))))
        alt19 = 1
      end
      case (alt19)
      when 1
        # Java.g:
        if ((self.attr_input._la(1)).equal?(Character.new(?+.ord)) || (self.attr_input._la(1)).equal?(Character.new(?-.ord)))
          self.attr_input.consume
        else
          mse_ = MismatchedSetException.new(nil, self.attr_input)
          recover(mse_)
          raise mse_
        end
      end
      # Java.g:929:33: ( '0' .. '9' )+
      cnt20 = 0
      begin
        alt20 = 2
        la20_0 = self.attr_input._la(1)
        if (((la20_0 >= Character.new(?0.ord) && la20_0 <= Character.new(?9.ord))))
          alt20 = 1
        end
        case (alt20)
        when 1
          # Java.g:929:34: '0' .. '9'
          match_range(Character.new(?0.ord), Character.new(?9.ord))
        else
          if (cnt20 >= 1)
            break
          end
          eee = EarlyExitException.new(20, self.attr_input)
          raise eee
        end
        ((cnt20 += 1) - 1)
      end while (true)
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "Exponent"
  # $ANTLR start "FloatTypeSuffix"
  def m_float_type_suffix
    begin
      # Java.g:932:17: ( ( 'f' | 'F' | 'd' | 'D' ) )
      # Java.g:932:19: ( 'f' | 'F' | 'd' | 'D' )
      if ((self.attr_input._la(1)).equal?(Character.new(?D.ord)) || (self.attr_input._la(1)).equal?(Character.new(?F.ord)) || (self.attr_input._la(1)).equal?(Character.new(?d.ord)) || (self.attr_input._la(1)).equal?(Character.new(?f.ord)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "FloatTypeSuffix"
  # $ANTLR start "CharacterLiteral"
  def m_character_literal
    begin
      _type = CharacterLiteral
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:935:5: ( '\\'' ( EscapeSequence | ~ ( '\\'' | '\\\\' ) ) '\\'' )
      # Java.g:935:9: '\\'' ( EscapeSequence | ~ ( '\\'' | '\\\\' ) ) '\\''
      match(Character.new(?\'.ord))
      # Java.g:935:14: ( EscapeSequence | ~ ( '\\'' | '\\\\' ) )
      alt21 = 2
      la21_0 = self.attr_input._la(1)
      if (((la21_0).equal?(Character.new(?\\.ord))))
        alt21 = 1
      else
        if (((la21_0 >= Character.new(0x0000) && la21_0 <= Character.new(?&.ord)) || (la21_0 >= Character.new(?(.ord) && la21_0 <= Character.new(?[.ord)) || (la21_0 >= Character.new(?].ord) && la21_0 <= Character.new(0xFFFF))))
          alt21 = 2
        else
          nvae = NoViableAltException.new("", 21, 0, self.attr_input)
          raise nvae
        end
      end
      case (alt21)
      when 1
        # Java.g:935:16: EscapeSequence
        m_escape_sequence
      when 2
        # Java.g:935:33: ~ ( '\\'' | '\\\\' )
        if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?&.ord)) || (self.attr_input._la(1) >= Character.new(?(.ord) && self.attr_input._la(1) <= Character.new(?[.ord)) || (self.attr_input._la(1) >= Character.new(?].ord) && self.attr_input._la(1) <= Character.new(0xFFFF)))
          self.attr_input.consume
        else
          mse = MismatchedSetException.new(nil, self.attr_input)
          recover(mse)
          raise mse
        end
      end
      match(Character.new(?\'.ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "CharacterLiteral"
  # $ANTLR start "StringLiteral"
  def m_string_literal
    begin
      _type = StringLiteral
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:939:5: ( '\"' ( EscapeSequence | ~ ( '\\\\' | '\"' ) )* '\"' )
      # Java.g:939:8: '\"' ( EscapeSequence | ~ ( '\\\\' | '\"' ) )* '\"'
      match(Character.new(?\".ord))
      # Java.g:939:12: ( EscapeSequence | ~ ( '\\\\' | '\"' ) )*
      begin
        alt22 = 3
        la22_0 = self.attr_input._la(1)
        if (((la22_0).equal?(Character.new(?\\.ord))))
          alt22 = 1
        else
          if (((la22_0 >= Character.new(0x0000) && la22_0 <= Character.new(?!.ord)) || (la22_0 >= Character.new(?#.ord) && la22_0 <= Character.new(?[.ord)) || (la22_0 >= Character.new(?].ord) && la22_0 <= Character.new(0xFFFF))))
            alt22 = 2
          end
        end
        case (alt22)
        when 1
          # Java.g:939:14: EscapeSequence
          m_escape_sequence
        when 2
          # Java.g:939:31: ~ ( '\\\\' | '\"' )
          if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?!.ord)) || (self.attr_input._la(1) >= Character.new(?#.ord) && self.attr_input._la(1) <= Character.new(?[.ord)) || (self.attr_input._la(1) >= Character.new(?].ord) && self.attr_input._la(1) <= Character.new(0xFFFF)))
            self.attr_input.consume
          else
            mse = MismatchedSetException.new(nil, self.attr_input)
            recover(mse)
            raise mse
          end
        else
          break
        end
      end while (true)
      match(Character.new(?\".ord))
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "StringLiteral"
  # $ANTLR start "EscapeSequence"
  def m_escape_sequence
    begin
      # Java.g:944:5: ( '\\\\' ( 'b' | 't' | 'n' | 'f' | 'r' | '\\\"' | '\\'' | '\\\\' ) | UnicodeEscape | OctalEscape )
      alt23 = 3
      la23_0 = self.attr_input._la(1)
      if (((la23_0).equal?(Character.new(?\\.ord))))
        case (self.attr_input._la(2))
        when Character.new(?\".ord), Character.new(?\'.ord), Character.new(?\\.ord), Character.new(?b.ord), Character.new(?f.ord), Character.new(?n.ord), Character.new(?r.ord), Character.new(?t.ord)
          alt23 = 1
        when Character.new(?u.ord)
          alt23 = 2
        when Character.new(?0.ord), Character.new(?1.ord), Character.new(?2.ord), Character.new(?3.ord), Character.new(?4.ord), Character.new(?5.ord), Character.new(?6.ord), Character.new(?7.ord)
          alt23 = 3
        else
          nvae = NoViableAltException.new("", 23, 1, self.attr_input)
          raise nvae
        end
      else
        nvae_ = NoViableAltException.new("", 23, 0, self.attr_input)
        raise nvae_
      end
      case (alt23)
      when 1
        # Java.g:944:9: '\\\\' ( 'b' | 't' | 'n' | 'f' | 'r' | '\\\"' | '\\'' | '\\\\' )
        match(Character.new(?\\.ord))
        if ((self.attr_input._la(1)).equal?(Character.new(?\".ord)) || (self.attr_input._la(1)).equal?(Character.new(?\'.ord)) || (self.attr_input._la(1)).equal?(Character.new(?\\.ord)) || (self.attr_input._la(1)).equal?(Character.new(?b.ord)) || (self.attr_input._la(1)).equal?(Character.new(?f.ord)) || (self.attr_input._la(1)).equal?(Character.new(?n.ord)) || (self.attr_input._la(1)).equal?(Character.new(?r.ord)) || (self.attr_input._la(1)).equal?(Character.new(?t.ord)))
          self.attr_input.consume
        else
          mse = MismatchedSetException.new(nil, self.attr_input)
          recover(mse)
          raise mse
        end
      when 2
        # Java.g:945:9: UnicodeEscape
        m_unicode_escape
      when 3
        # Java.g:946:9: OctalEscape
        m_octal_escape
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "EscapeSequence"
  # $ANTLR start "OctalEscape"
  def m_octal_escape
    begin
      # Java.g:951:5: ( '\\\\' ( '0' .. '3' ) ( '0' .. '7' ) ( '0' .. '7' ) | '\\\\' ( '0' .. '7' ) ( '0' .. '7' ) | '\\\\' ( '0' .. '7' ) )
      alt24 = 3
      la24_0 = self.attr_input._la(1)
      if (((la24_0).equal?(Character.new(?\\.ord))))
        la24_1 = self.attr_input._la(2)
        if (((la24_1 >= Character.new(?0.ord) && la24_1 <= Character.new(?3.ord))))
          la24_2 = self.attr_input._la(3)
          if (((la24_2 >= Character.new(?0.ord) && la24_2 <= Character.new(?7.ord))))
            la24_5 = self.attr_input._la(4)
            if (((la24_5 >= Character.new(?0.ord) && la24_5 <= Character.new(?7.ord))))
              alt24 = 1
            else
              alt24 = 2
            end
          else
            alt24 = 3
          end
        else
          if (((la24_1 >= Character.new(?4.ord) && la24_1 <= Character.new(?7.ord))))
            la24_3 = self.attr_input._la(3)
            if (((la24_3 >= Character.new(?0.ord) && la24_3 <= Character.new(?7.ord))))
              alt24 = 2
            else
              alt24 = 3
            end
          else
            nvae = NoViableAltException.new("", 24, 1, self.attr_input)
            raise nvae
          end
        end
      else
        nvae_ = NoViableAltException.new("", 24, 0, self.attr_input)
        raise nvae_
      end
      case (alt24)
      when 1
        # Java.g:951:9: '\\\\' ( '0' .. '3' ) ( '0' .. '7' ) ( '0' .. '7' )
        match(Character.new(?\\.ord))
        # Java.g:951:14: ( '0' .. '3' )
        # Java.g:951:15: '0' .. '3'
        match_range(Character.new(?0.ord), Character.new(?3.ord))
        # Java.g:951:25: ( '0' .. '7' )
        # Java.g:951:26: '0' .. '7'
        match_range(Character.new(?0.ord), Character.new(?7.ord))
        # Java.g:951:36: ( '0' .. '7' )
        # Java.g:951:37: '0' .. '7'
        match_range(Character.new(?0.ord), Character.new(?7.ord))
      when 2
        # Java.g:952:9: '\\\\' ( '0' .. '7' ) ( '0' .. '7' )
        match(Character.new(?\\.ord))
        # Java.g:952:14: ( '0' .. '7' )
        # Java.g:952:15: '0' .. '7'
        match_range(Character.new(?0.ord), Character.new(?7.ord))
        # Java.g:952:25: ( '0' .. '7' )
        # Java.g:952:26: '0' .. '7'
        match_range(Character.new(?0.ord), Character.new(?7.ord))
      when 3
        # Java.g:953:9: '\\\\' ( '0' .. '7' )
        match(Character.new(?\\.ord))
        # Java.g:953:14: ( '0' .. '7' )
        # Java.g:953:15: '0' .. '7'
        match_range(Character.new(?0.ord), Character.new(?7.ord))
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "OctalEscape"
  # $ANTLR start "UnicodeEscape"
  def m_unicode_escape
    begin
      # Java.g:958:5: ( '\\\\' 'u' HexDigit HexDigit HexDigit HexDigit )
      # Java.g:958:9: '\\\\' 'u' HexDigit HexDigit HexDigit HexDigit
      match(Character.new(?\\.ord))
      match(Character.new(?u.ord))
      m_hex_digit
      m_hex_digit
      m_hex_digit
      m_hex_digit
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "UnicodeEscape"
  # $ANTLR start "ENUM"
  def m_enum
    begin
      _type = ENUM
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:961:5: ( 'enum' )
      # Java.g:961:9: 'enum'
      match("enum")
      if (!@enum_is_keyword)
        _type = Identifier
      end
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "ENUM"
  # $ANTLR start "ASSERT"
  def m_assert
    begin
      _type = ASSERT
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:965:5: ( 'assert' )
      # Java.g:965:9: 'assert'
      match("assert")
      if (!@assert_is_keyword)
        _type = Identifier
      end
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "ASSERT"
  # $ANTLR start "Identifier"
  def m_identifier
    begin
      _type = Identifier
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:969:5: ( Letter ( Letter | JavaIDDigit )* )
      # Java.g:969:9: Letter ( Letter | JavaIDDigit )*
      m_letter
      # Java.g:969:16: ( Letter | JavaIDDigit )*
      begin
        alt25 = 2
        la25_0 = self.attr_input._la(1)
        if (((la25_0).equal?(Character.new(?$.ord)) || (la25_0 >= Character.new(?0.ord) && la25_0 <= Character.new(?9.ord)) || (la25_0 >= Character.new(?A.ord) && la25_0 <= Character.new(?Z.ord)) || (la25_0).equal?(Character.new(?_.ord)) || (la25_0 >= Character.new(?a.ord) && la25_0 <= Character.new(?z.ord)) || (la25_0 >= Character.new(0x00C0) && la25_0 <= Character.new(0x00D6)) || (la25_0 >= Character.new(0x00D8) && la25_0 <= Character.new(0x00F6)) || (la25_0 >= Character.new(0x00F8) && la25_0 <= Character.new(0x1FFF)) || (la25_0 >= Character.new(0x3040) && la25_0 <= Character.new(0x318F)) || (la25_0 >= Character.new(0x3300) && la25_0 <= Character.new(0x337F)) || (la25_0 >= Character.new(0x3400) && la25_0 <= Character.new(0x3D2D)) || (la25_0 >= Character.new(0x4E00) && la25_0 <= Character.new(0x9FFF)) || (la25_0 >= Character.new(0xF900) && la25_0 <= Character.new(0xFAFF))))
          alt25 = 1
        end
        case (alt25)
        when 1
          # Java.g:
          if ((self.attr_input._la(1)).equal?(Character.new(?$.ord)) || (self.attr_input._la(1) >= Character.new(?0.ord) && self.attr_input._la(1) <= Character.new(?9.ord)) || (self.attr_input._la(1) >= Character.new(?A.ord) && self.attr_input._la(1) <= Character.new(?Z.ord)) || (self.attr_input._la(1)).equal?(Character.new(?_.ord)) || (self.attr_input._la(1) >= Character.new(?a.ord) && self.attr_input._la(1) <= Character.new(?z.ord)) || (self.attr_input._la(1) >= Character.new(0x00C0) && self.attr_input._la(1) <= Character.new(0x00D6)) || (self.attr_input._la(1) >= Character.new(0x00D8) && self.attr_input._la(1) <= Character.new(0x00F6)) || (self.attr_input._la(1) >= Character.new(0x00F8) && self.attr_input._la(1) <= Character.new(0x1FFF)) || (self.attr_input._la(1) >= Character.new(0x3040) && self.attr_input._la(1) <= Character.new(0x318F)) || (self.attr_input._la(1) >= Character.new(0x3300) && self.attr_input._la(1) <= Character.new(0x337F)) || (self.attr_input._la(1) >= Character.new(0x3400) && self.attr_input._la(1) <= Character.new(0x3D2D)) || (self.attr_input._la(1) >= Character.new(0x4E00) && self.attr_input._la(1) <= Character.new(0x9FFF)) || (self.attr_input._la(1) >= Character.new(0xF900) && self.attr_input._la(1) <= Character.new(0xFAFF)))
            self.attr_input.consume
          else
            mse = MismatchedSetException.new(nil, self.attr_input)
            recover(mse)
            raise mse
          end
        else
          break
        end
      end while (true)
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "Identifier"
  # $ANTLR start "Letter"
  def m_letter
    begin
      # Java.g:977:5: ( '\\u0024' | '\\u0041' .. '\\u005a' | '\\u005f' | '\\u0061' .. '\\u007a' | '\\u00c0' .. '\\u00d6' | '\\u00d8' .. '\\u00f6' | '\\u00f8' .. '\\u00ff' | '\\u0100' .. '\\u1fff' | '\\u3040' .. '\\u318f' | '\\u3300' .. '\\u337f' | '\\u3400' .. '\\u3d2d' | '\\u4e00' .. '\\u9fff' | '\\uf900' .. '\\ufaff' )
      # Java.g:
      if ((self.attr_input._la(1)).equal?(Character.new(?$.ord)) || (self.attr_input._la(1) >= Character.new(?A.ord) && self.attr_input._la(1) <= Character.new(?Z.ord)) || (self.attr_input._la(1)).equal?(Character.new(?_.ord)) || (self.attr_input._la(1) >= Character.new(?a.ord) && self.attr_input._la(1) <= Character.new(?z.ord)) || (self.attr_input._la(1) >= Character.new(0x00C0) && self.attr_input._la(1) <= Character.new(0x00D6)) || (self.attr_input._la(1) >= Character.new(0x00D8) && self.attr_input._la(1) <= Character.new(0x00F6)) || (self.attr_input._la(1) >= Character.new(0x00F8) && self.attr_input._la(1) <= Character.new(0x1FFF)) || (self.attr_input._la(1) >= Character.new(0x3040) && self.attr_input._la(1) <= Character.new(0x318F)) || (self.attr_input._la(1) >= Character.new(0x3300) && self.attr_input._la(1) <= Character.new(0x337F)) || (self.attr_input._la(1) >= Character.new(0x3400) && self.attr_input._la(1) <= Character.new(0x3D2D)) || (self.attr_input._la(1) >= Character.new(0x4E00) && self.attr_input._la(1) <= Character.new(0x9FFF)) || (self.attr_input._la(1) >= Character.new(0xF900) && self.attr_input._la(1) <= Character.new(0xFAFF)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "Letter"
  # $ANTLR start "JavaIDDigit"
  def m_java_iddigit
    begin
      # Java.g:994:5: ( '\\u0030' .. '\\u0039' | '\\u0660' .. '\\u0669' | '\\u06f0' .. '\\u06f9' | '\\u0966' .. '\\u096f' | '\\u09e6' .. '\\u09ef' | '\\u0a66' .. '\\u0a6f' | '\\u0ae6' .. '\\u0aef' | '\\u0b66' .. '\\u0b6f' | '\\u0be7' .. '\\u0bef' | '\\u0c66' .. '\\u0c6f' | '\\u0ce6' .. '\\u0cef' | '\\u0d66' .. '\\u0d6f' | '\\u0e50' .. '\\u0e59' | '\\u0ed0' .. '\\u0ed9' | '\\u1040' .. '\\u1049' )
      # Java.g:
      if ((self.attr_input._la(1) >= Character.new(?0.ord) && self.attr_input._la(1) <= Character.new(?9.ord)) || (self.attr_input._la(1) >= Character.new(0x0660) && self.attr_input._la(1) <= Character.new(0x0669)) || (self.attr_input._la(1) >= Character.new(0x06F0) && self.attr_input._la(1) <= Character.new(0x06F9)) || (self.attr_input._la(1) >= Character.new(0x0966) && self.attr_input._la(1) <= Character.new(0x096F)) || (self.attr_input._la(1) >= Character.new(0x09E6) && self.attr_input._la(1) <= Character.new(0x09EF)) || (self.attr_input._la(1) >= Character.new(0x0A66) && self.attr_input._la(1) <= Character.new(0x0A6F)) || (self.attr_input._la(1) >= Character.new(0x0AE6) && self.attr_input._la(1) <= Character.new(0x0AEF)) || (self.attr_input._la(1) >= Character.new(0x0B66) && self.attr_input._la(1) <= Character.new(0x0B6F)) || (self.attr_input._la(1) >= Character.new(0x0BE7) && self.attr_input._la(1) <= Character.new(0x0BEF)) || (self.attr_input._la(1) >= Character.new(0x0C66) && self.attr_input._la(1) <= Character.new(0x0C6F)) || (self.attr_input._la(1) >= Character.new(0x0CE6) && self.attr_input._la(1) <= Character.new(0x0CEF)) || (self.attr_input._la(1) >= Character.new(0x0D66) && self.attr_input._la(1) <= Character.new(0x0D6F)) || (self.attr_input._la(1) >= Character.new(0x0E50) && self.attr_input._la(1) <= Character.new(0x0E59)) || (self.attr_input._la(1) >= Character.new(0x0ED0) && self.attr_input._la(1) <= Character.new(0x0ED9)) || (self.attr_input._la(1) >= Character.new(0x1040) && self.attr_input._la(1) <= Character.new(0x1049)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "JavaIDDigit"
  # $ANTLR start "WS"
  def m_ws
    begin
      _type = WS
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:1011:5: ( ( ' ' | '\\r' | '\\t' | '\\u000C' | '\\n' ) )
      # Java.g:1011:8: ( ' ' | '\\r' | '\\t' | '\\u000C' | '\\n' )
      if ((self.attr_input._la(1) >= Character.new(?\t.ord) && self.attr_input._la(1) <= Character.new(?\n.ord)) || (self.attr_input._la(1) >= Character.new(?\f.ord) && self.attr_input._la(1) <= Character.new(?\r.ord)) || (self.attr_input._la(1)).equal?(Character.new(?\s.ord)))
        self.attr_input.consume
      else
        mse = MismatchedSetException.new(nil, self.attr_input)
        recover(mse)
        raise mse
      end
      _channel = HIDDEN
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "WS"
  # $ANTLR start "COMMENT"
  def m_comment
    begin
      _type = COMMENT
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:1015:5: ( '/*' ( options {greedy=false; } : . )* '*/' )
      # Java.g:1015:9: '/*' ( options {greedy=false; } : . )* '*/'
      match("/*")
      # Java.g:1015:14: ( options {greedy=false; } : . )*
      begin
        alt26 = 2
        la26_0 = self.attr_input._la(1)
        if (((la26_0).equal?(Character.new(?*.ord))))
          la26_1 = self.attr_input._la(2)
          if (((la26_1).equal?(Character.new(?/.ord))))
            alt26 = 2
          else
            if (((la26_1 >= Character.new(0x0000) && la26_1 <= Character.new(?..ord)) || (la26_1 >= Character.new(?0.ord) && la26_1 <= Character.new(0xFFFF))))
              alt26 = 1
            end
          end
        else
          if (((la26_0 >= Character.new(0x0000) && la26_0 <= Character.new(?).ord)) || (la26_0 >= Character.new(?+.ord) && la26_0 <= Character.new(0xFFFF))))
            alt26 = 1
          end
        end
        case (alt26)
        when 1
          # Java.g:1015:42: .
          match_any
        else
          break
        end
      end while (true)
      match("*/")
      _channel = HIDDEN
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "COMMENT"
  # $ANTLR start "LINE_COMMENT"
  def m_line_comment
    begin
      _type = LINE_COMMENT
      _channel = DEFAULT_TOKEN_CHANNEL
      # Java.g:1019:5: ( '//' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n' )
      # Java.g:1019:7: '//' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n'
      match("//")
      # Java.g:1019:12: (~ ( '\\n' | '\\r' ) )*
      begin
        alt27 = 2
        la27_0 = self.attr_input._la(1)
        if (((la27_0 >= Character.new(0x0000) && la27_0 <= Character.new(?\t.ord)) || (la27_0 >= Character.new(0x000B) && la27_0 <= Character.new(?\f.ord)) || (la27_0 >= Character.new(0x000E) && la27_0 <= Character.new(0xFFFF))))
          alt27 = 1
        end
        case (alt27)
        when 1
          # Java.g:1019:12: ~ ( '\\n' | '\\r' )
          if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?\t.ord)) || (self.attr_input._la(1) >= Character.new(0x000B) && self.attr_input._la(1) <= Character.new(?\f.ord)) || (self.attr_input._la(1) >= Character.new(0x000E) && self.attr_input._la(1) <= Character.new(0xFFFF)))
            self.attr_input.consume
          else
            mse = MismatchedSetException.new(nil, self.attr_input)
            recover(mse)
            raise mse
          end
        else
          break
        end
      end while (true)
      # Java.g:1019:26: ( '\\r' )?
      alt28 = 2
      la28_0 = self.attr_input._la(1)
      if (((la28_0).equal?(Character.new(?\r.ord))))
        alt28 = 1
      end
      case (alt28)
      when 1
        # Java.g:1019:26: '\\r'
        match(Character.new(?\r.ord))
      end
      match(Character.new(?\n.ord))
      _channel = HIDDEN
      self.attr_state.attr_type = _type
      self.attr_state.attr_channel = _channel
    ensure
    end
  end
  
  typesig { [] }
  # $ANTLR end "LINE_COMMENT"
  def m_tokens
    # Java.g:1:8: ( T__25 | T__26 | T__27 | T__28 | T__29 | T__30 | T__31 | T__32 | T__33 | T__34 | T__35 | T__36 | T__37 | T__38 | T__39 | T__40 | T__41 | T__42 | T__43 | T__44 | T__45 | T__46 | T__47 | T__48 | T__49 | T__50 | T__51 | T__52 | T__53 | T__54 | T__55 | T__56 | T__57 | T__58 | T__59 | T__60 | T__61 | T__62 | T__63 | T__64 | T__65 | T__66 | T__67 | T__68 | T__69 | T__70 | T__71 | T__72 | T__73 | T__74 | T__75 | T__76 | T__77 | T__78 | T__79 | T__80 | T__81 | T__82 | T__83 | T__84 | T__85 | T__86 | T__87 | T__88 | T__89 | T__90 | T__91 | T__92 | T__93 | T__94 | T__95 | T__96 | T__97 | T__98 | T__99 | T__100 | T__101 | T__102 | T__103 | T__104 | T__105 | T__106 | T__107 | T__108 | T__109 | T__110 | T__111 | T__112 | T__113 | HexLiteral | DecimalLiteral | OctalLiteral | FloatingPointLiteral | CharacterLiteral | StringLiteral | ENUM | ASSERT | Identifier | WS | COMMENT | LINE_COMMENT )
    alt29 = 101
    alt29 = @dfa29.predict(self.attr_input)
    case (alt29)
    when 1
      # Java.g:1:10: T__25
      m_t__25
    when 2
      # Java.g:1:16: T__26
      m_t__26
    when 3
      # Java.g:1:22: T__27
      m_t__27
    when 4
      # Java.g:1:28: T__28
      m_t__28
    when 5
      # Java.g:1:34: T__29
      m_t__29
    when 6
      # Java.g:1:40: T__30
      m_t__30
    when 7
      # Java.g:1:46: T__31
      m_t__31
    when 8
      # Java.g:1:52: T__32
      m_t__32
    when 9
      # Java.g:1:58: T__33
      m_t__33
    when 10
      # Java.g:1:64: T__34
      m_t__34
    when 11
      # Java.g:1:70: T__35
      m_t__35
    when 12
      # Java.g:1:76: T__36
      m_t__36
    when 13
      # Java.g:1:82: T__37
      m_t__37
    when 14
      # Java.g:1:88: T__38
      m_t__38
    when 15
      # Java.g:1:94: T__39
      m_t__39
    when 16
      # Java.g:1:100: T__40
      m_t__40
    when 17
      # Java.g:1:106: T__41
      m_t__41
    when 18
      # Java.g:1:112: T__42
      m_t__42
    when 19
      # Java.g:1:118: T__43
      m_t__43
    when 20
      # Java.g:1:124: T__44
      m_t__44
    when 21
      # Java.g:1:130: T__45
      m_t__45
    when 22
      # Java.g:1:136: T__46
      m_t__46
    when 23
      # Java.g:1:142: T__47
      m_t__47
    when 24
      # Java.g:1:148: T__48
      m_t__48
    when 25
      # Java.g:1:154: T__49
      m_t__49
    when 26
      # Java.g:1:160: T__50
      m_t__50
    when 27
      # Java.g:1:166: T__51
      m_t__51
    when 28
      # Java.g:1:172: T__52
      m_t__52
    when 29
      # Java.g:1:178: T__53
      m_t__53
    when 30
      # Java.g:1:184: T__54
      m_t__54
    when 31
      # Java.g:1:190: T__55
      m_t__55
    when 32
      # Java.g:1:196: T__56
      m_t__56
    when 33
      # Java.g:1:202: T__57
      m_t__57
    when 34
      # Java.g:1:208: T__58
      m_t__58
    when 35
      # Java.g:1:214: T__59
      m_t__59
    when 36
      # Java.g:1:220: T__60
      m_t__60
    when 37
      # Java.g:1:226: T__61
      m_t__61
    when 38
      # Java.g:1:232: T__62
      m_t__62
    when 39
      # Java.g:1:238: T__63
      m_t__63
    when 40
      # Java.g:1:244: T__64
      m_t__64
    when 41
      # Java.g:1:250: T__65
      m_t__65
    when 42
      # Java.g:1:256: T__66
      m_t__66
    when 43
      # Java.g:1:262: T__67
      m_t__67
    when 44
      # Java.g:1:268: T__68
      m_t__68
    when 45
      # Java.g:1:274: T__69
      m_t__69
    when 46
      # Java.g:1:280: T__70
      m_t__70
    when 47
      # Java.g:1:286: T__71
      m_t__71
    when 48
      # Java.g:1:292: T__72
      m_t__72
    when 49
      # Java.g:1:298: T__73
      m_t__73
    when 50
      # Java.g:1:304: T__74
      m_t__74
    when 51
      # Java.g:1:310: T__75
      m_t__75
    when 52
      # Java.g:1:316: T__76
      m_t__76
    when 53
      # Java.g:1:322: T__77
      m_t__77
    when 54
      # Java.g:1:328: T__78
      m_t__78
    when 55
      # Java.g:1:334: T__79
      m_t__79
    when 56
      # Java.g:1:340: T__80
      m_t__80
    when 57
      # Java.g:1:346: T__81
      m_t__81
    when 58
      # Java.g:1:352: T__82
      m_t__82
    when 59
      # Java.g:1:358: T__83
      m_t__83
    when 60
      # Java.g:1:364: T__84
      m_t__84
    when 61
      # Java.g:1:370: T__85
      m_t__85
    when 62
      # Java.g:1:376: T__86
      m_t__86
    when 63
      # Java.g:1:382: T__87
      m_t__87
    when 64
      # Java.g:1:388: T__88
      m_t__88
    when 65
      # Java.g:1:394: T__89
      m_t__89
    when 66
      # Java.g:1:400: T__90
      m_t__90
    when 67
      # Java.g:1:406: T__91
      m_t__91
    when 68
      # Java.g:1:412: T__92
      m_t__92
    when 69
      # Java.g:1:418: T__93
      m_t__93
    when 70
      # Java.g:1:424: T__94
      m_t__94
    when 71
      # Java.g:1:430: T__95
      m_t__95
    when 72
      # Java.g:1:436: T__96
      m_t__96
    when 73
      # Java.g:1:442: T__97
      m_t__97
    when 74
      # Java.g:1:448: T__98
      m_t__98
    when 75
      # Java.g:1:454: T__99
      m_t__99
    when 76
      # Java.g:1:460: T__100
      m_t__100
    when 77
      # Java.g:1:467: T__101
      m_t__101
    when 78
      # Java.g:1:474: T__102
      m_t__102
    when 79
      # Java.g:1:481: T__103
      m_t__103
    when 80
      # Java.g:1:488: T__104
      m_t__104
    when 81
      # Java.g:1:495: T__105
      m_t__105
    when 82
      # Java.g:1:502: T__106
      m_t__106
    when 83
      # Java.g:1:509: T__107
      m_t__107
    when 84
      # Java.g:1:516: T__108
      m_t__108
    when 85
      # Java.g:1:523: T__109
      m_t__109
    when 86
      # Java.g:1:530: T__110
      m_t__110
    when 87
      # Java.g:1:537: T__111
      m_t__111
    when 88
      # Java.g:1:544: T__112
      m_t__112
    when 89
      # Java.g:1:551: T__113
      m_t__113
    when 90
      # Java.g:1:558: HexLiteral
      m_hex_literal
    when 91
      # Java.g:1:569: DecimalLiteral
      m_decimal_literal
    when 92
      # Java.g:1:584: OctalLiteral
      m_octal_literal
    when 93
      # Java.g:1:597: FloatingPointLiteral
      m_floating_point_literal
    when 94
      # Java.g:1:618: CharacterLiteral
      m_character_literal
    when 95
      # Java.g:1:635: StringLiteral
      m_string_literal
    when 96
      # Java.g:1:649: ENUM
      m_enum
    when 97
      # Java.g:1:654: ASSERT
      m_assert
    when 98
      # Java.g:1:661: Identifier
      m_identifier
    when 99
      # Java.g:1:672: WS
      m_ws
    when 100
      # Java.g:1:675: COMMENT
      m_comment
    when 101
      # Java.g:1:683: LINE_COMMENT
      m_line_comment
    end
  end
  
  attr_accessor :dfa18
  alias_method :attr_dfa18, :dfa18
  undef_method :dfa18
  alias_method :attr_dfa18=, :dfa18=
  undef_method :dfa18=
  
  attr_accessor :dfa29
  alias_method :attr_dfa29, :dfa29
  undef_method :dfa29
  alias_method :attr_dfa29=, :dfa29=
  undef_method :dfa29=
  
  class_module.module_eval {
    const_set_lazy(:DFA18_eotS) { ("\6".to_u << 0xffff << "") }
    const_attr_reader  :DFA18_eotS
    
    const_set_lazy(:DFA18_eofS) { ("\6".to_u << 0xffff << "") }
    const_attr_reader  :DFA18_eofS
    
    const_set_lazy(:DFA18_minS) { ("\2\56\4".to_u << 0xffff << "") }
    const_attr_reader  :DFA18_minS
    
    const_set_lazy(:DFA18_maxS) { ("\1\71\1\146\4".to_u << 0xffff << "") }
    const_attr_reader  :DFA18_maxS
    
    const_set_lazy(:DFA18_acceptS) { ("\2".to_u << 0xffff << "\1\2\1\4\1\3\1\1") }
    const_attr_reader  :DFA18_acceptS
    
    const_set_lazy(:DFA18_specialS) { ("\6".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA18_specialS
    
    const_set_lazy(:DFA18_transitionS) { Array.typed(String).new([("\1\2\1".to_u << 0xffff << "\12\1"), ("\1\5\1".to_u << 0xffff << "\12\1\12".to_u << 0xffff << "\1\3\1\4\1\3\35".to_u << 0xffff << "\1\3\1\4\1\3"), "", "", "", ""]) }
    const_attr_reader  :DFA18_transitionS
    
    const_set_lazy(:DFA18_eot) { DFA.unpack_encoded_string(DFA18_eotS) }
    const_attr_reader  :DFA18_eot
    
    const_set_lazy(:DFA18_eof) { DFA.unpack_encoded_string(DFA18_eofS) }
    const_attr_reader  :DFA18_eof
    
    const_set_lazy(:DFA18_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA18_minS) }
    const_attr_reader  :DFA18_min
    
    const_set_lazy(:DFA18_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA18_maxS) }
    const_attr_reader  :DFA18_max
    
    const_set_lazy(:DFA18_accept) { DFA.unpack_encoded_string(DFA18_acceptS) }
    const_attr_reader  :DFA18_accept
    
    const_set_lazy(:DFA18_special) { DFA.unpack_encoded_string(DFA18_specialS) }
    const_attr_reader  :DFA18_special
    
    when_class_loaded do
      num_states = DFA18_transitionS.attr_length
      const_set :DFA18_transition, Array.typed(::Java::Short).new(num_states) { 0 }
      i = 0
      while i < num_states
        DFA18_transition[i] = DFA.unpack_encoded_string(DFA18_transitionS[i])
        ((i += 1) - 1)
      end
    end
    
    const_set_lazy(:DFA18) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaLexer
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 18
        self.attr_eot = DFA18_eot
        self.attr_eof = DFA18_eof
        self.attr_min = DFA18_min
        self.attr_max = DFA18_max
        self.attr_accept = DFA18_accept
        self.attr_special = DFA18_special
        self.attr_transition = DFA18_transition
      end
      
      typesig { [] }
      def get_description
        return "921:1: FloatingPointLiteral : ( ( '0' .. '9' )+ '.' ( '0' .. '9' )* ( Exponent )? ( FloatTypeSuffix )? | '.' ( '0' .. '9' )+ ( Exponent )? ( FloatTypeSuffix )? | ( '0' .. '9' )+ Exponent ( FloatTypeSuffix )? | ( '0' .. '9' )+ FloatTypeSuffix );"
      end
      
      private
      alias_method :initialize__dfa18, :initialize
    end }
    
    const_set_lazy(:DFA29_eotS) { ("\1".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\2\55\1\73\1\76\4\55\3".to_u << 0xffff << "\1\116\2".to_u << 0xffff << "") + ("\1\55\2".to_u << 0xffff << "\1\55\1\123\4\55\5".to_u << 0xffff << "\2\55\1\141\1\144\1\150\1\153") + ("\1\155\1\157\1\161\1".to_u << 0xffff << "\2\164\4".to_u << 0xffff << "\5\55\1\175\5\55\5".to_u << 0xffff << "") + ("\15\55\3".to_u << 0xffff << "\3\55\2".to_u << 0xffff << "\7\55\1".to_u << 0x00a1 << "\3\55\24".to_u << 0xffff << "\1".to_u << 0x00a5 << "\1") + ("".to_u << 0xffff << "\1\164\5\55\1".to_u << 0x00ad << "\1\55\1".to_u << 0xffff << "\13\55\1".to_u << 0x00ba << "\16\55\1".to_u << 0x00c9 << "") + ("\2\55\1".to_u << 0x00cc << "\5\55\1".to_u << 0xffff << "\3\55\1".to_u << 0xffff << "\7\55\1".to_u << 0xffff << "\14\55\1".to_u << 0xffff << "") + ("\1\55\1".to_u << 0x00e9 << "\2\55\1".to_u << 0x00ec << "\1\55\1".to_u << 0x00ee << "\1".to_u << 0x00ef << "\1".to_u << 0x00f0 << "\2\55\1".to_u << 0x00f3 << "") + ("\1\55\1".to_u << 0x00f5 << "\1".to_u << 0xffff << "\1\55\1".to_u << 0x00f7 << "\1".to_u << 0xffff << "\1\55\1".to_u << 0x00f9 << "\1\55\1".to_u << 0x00fb << "") + ("\17\55\1".to_u << 0x010b << "\1".to_u << 0x010c << "\3\55\1".to_u << 0x0111 << "\1".to_u << 0x0112 << "\1".to_u << 0x0113 << "\1".to_u << 0x0114 << "\1".to_u << 0xffff << "") + ("\1\55\1".to_u << 0x0116 << "\1".to_u << 0xffff << "\1\55\3".to_u << 0xffff << "\1\55\1".to_u << 0x011a << "\1".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "") + ("\1\55\1".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\1".to_u << 0x011e << "\1".to_u << 0xffff << "\2\55\1".to_u << 0x0121 << "\2\55\1".to_u << 0x0124 << "") + ("\2\55\1".to_u << 0x0127 << "\3\55\1".to_u << 0x012b << "\2\55\2".to_u << 0xffff << "\1".to_u << 0x012e << "\1\55\1".to_u << 0x0130 << "\1\55") + ("\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\2\55\1".to_u << 0x0135 << "\1".to_u << 0xffff << "\1\55\1".to_u << 0x0137 << "\1\55\1".to_u << 0xffff << "") + ("\1".to_u << 0x0139 << "\1\55\1".to_u << 0xffff << "\1".to_u << 0x013b << "\1".to_u << 0x013c << "\1".to_u << 0xffff << "\1\55\1".to_u << 0x013e << "\1".to_u << 0xffff << "") + ("\3\55\1".to_u << 0xffff << "\2\55\1".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\1".to_u << 0x0145 << "\1\55\1".to_u << 0x0147 << "\1\55") + ("\1".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\1".to_u << 0x014a << "\1".to_u << 0xffff << "\1".to_u << 0x014b << "\2".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "") + ("\3\55\1".to_u << 0x0150 << "\1\55\1".to_u << 0x0152 << "\1".to_u << 0xffff << "\1".to_u << 0x0153 << "\1".to_u << 0xffff << "\1".to_u << 0x0154 << "\1\55") + ("\2".to_u << 0xffff << "\1".to_u << 0x0156 << "\1\55\1".to_u << 0x0158 << "\1\55\1".to_u << 0xffff << "\1\55\3".to_u << 0xffff << "\1".to_u << 0x015b << "") + ("\1".to_u << 0xffff << "\1".to_u << 0x015c << "\1".to_u << 0xffff << "\1".to_u << 0x015d << "\1\55\3".to_u << 0xffff << "\1\55\1".to_u << 0x0160 << "\1".to_u << 0xffff << "") }
    const_attr_reader  :DFA29_eotS
    
    const_set_lazy(:DFA29_eofS) { ("".to_u << 0x0161 << "".to_u << 0xffff << "") }
    const_attr_reader  :DFA29_eofS
    
    const_set_lazy(:DFA29_minS) { ("\1\11\1\141\1".to_u << 0xffff << "\1\146\1\150\1\56\1\75\1\142\2\141\1\154\3".to_u << 0xffff << "") + ("\1\46\2".to_u << 0xffff << "\1\157\2".to_u << 0xffff << "\1\150\1\75\1\141\2\157\1\145\5".to_u << 0xffff << "") + ("\1\150\1\145\1\53\1\55\1\52\4\75\1".to_u << 0xffff << "\2\56\4".to_u << 0xffff << "\1\143\1\142") + ("\1\151\1\160\1\163\1\44\1\141\1\156\1\157\1\160\1\151\5".to_u << 0xffff << "\2") + "\163\1\156\1\157\1\154\1\162\2\141\1\156\1\163\1\164\1\163\1\165" + ("\3".to_u << 0xffff << "\2\151\1\141\2".to_u << 0xffff << "\1\164\1\154\1\167\1\157\1\164\1\145") + ("\1\156\1\44\1\146\1\151\1\164\24".to_u << 0xffff << "\1\56\1".to_u << 0xffff << "\1\56\1\153\1") + ("\154\1\164\1\166\1\154\1\44\1\164\1".to_u << 0xffff << "\1\164\1\151\1\143\1\162") + "\1\145\2\164\1\145\2\141\1\163\1\44\1\163\1\162\1\164\1\143\3\145" + "\1\155\1\144\1\141\1\157\1\163\1\156\1\145\1\44\1\151\1\154\1\44" + ("\1\154\1\145\1\141\1\147\1\142\1".to_u << 0xffff << "\1\141\1\154\1\165\1".to_u << 0xffff << "") + ("\1\141\1\151\1\145\1\141\1\162\1\145\1\162\1".to_u << 0xffff << "\1\141\1\151\1") + ("\143\1\150\1\164\1\162\1\143\2\162\1\154\1\164\1\145\1".to_u << 0xffff << "\1\163") + "\1\44\1\151\1\150\1\44\1\156\3\44\1\164\1\167\1\44\1\163\1\44\1" + ("".to_u << 0xffff << "\1\166\1\44\1".to_u << 0xffff << "\1\145\1\44\1\153\1\44\1\154\1\165\1\145") + "\1\162\1\147\2\143\2\164\1\155\1\146\1\156\1\143\1\164\1\162\2\44" + ("\1\150\1\141\1\164\4\44\1".to_u << 0xffff << "\1\156\1\44\1".to_u << 0xffff << "\1\144\3".to_u << 0xffff << "") + ("\1\151\1\44\1".to_u << 0xffff << "\1\151\1".to_u << 0xffff << "\1\145\1".to_u << 0xffff << "\1\141\1".to_u << 0xffff << "\1") + ("\44\1".to_u << 0xffff << "\1\145\1\154\1\44\1\156\1\145\1\44\1\164\1\145\1\44\1") + ("\145\1\141\1\143\1\44\1\146\1\157\2".to_u << 0xffff << "\1\44\1\143\1\44\1\171") + ("\4".to_u << 0xffff << "\1\165\1".to_u << 0xffff << "\1\163\1\154\1\44\1".to_u << 0xffff << "\1\145\1\44\1\156") + ("\1".to_u << 0xffff << "\1\44\1\164\1".to_u << 0xffff << "\2\44\1".to_u << 0xffff << "\1\145\1\44\1".to_u << 0xffff << "\1\156") + ("\1\143\1\145\1".to_u << 0xffff << "\1\160\1\156\1".to_u << 0xffff << "\1\164\1".to_u << 0xffff << "\1\44\1\145") + ("\1\44\1\145\1".to_u << 0xffff << "\1\156\1".to_u << 0xffff << "\1\44\1".to_u << 0xffff << "\1\44\2".to_u << 0xffff << "\1\144") + ("\1".to_u << 0xffff << "\1\164\1\145\1\157\1\44\1\151\1\44\1".to_u << 0xffff << "\1\44\1".to_u << 0xffff << "") + ("\1\44\1\164\2".to_u << 0xffff << "\1\44\1\163\1\44\1\146\1".to_u << 0xffff << "\1\172\3".to_u << 0xffff << "") + ("\1\44\1".to_u << 0xffff << "\1\44\1".to_u << 0xffff << "\1\44\1\145\3".to_u << 0xffff << "\1\144\1\44\1".to_u << 0xffff << "") }
    const_attr_reader  :DFA29_minS
    
    const_set_lazy(:DFA29_maxS) { ("\1".to_u << 0xfaff << "\1\165\1".to_u << 0xffff << "\1\156\1\171\1\71\1\75\1\163\2\157\1\170\3") + ("".to_u << 0xffff << "\1\75\2".to_u << 0xffff << "\1\157\2".to_u << 0xffff << "\1\162\1\75\1\165\1\171\2\157\5") + ("".to_u << 0xffff << "\1\150\1\145\3\75\1\174\3\75\1".to_u << 0xffff << "\1\170\1\146\4".to_u << 0xffff << "\1") + ("\143\1\142\1\157\1\160\1\164\1".to_u << 0xfaff << "\1\162\1\156\1\157\1\160\1\151") + ("\5".to_u << 0xffff << "\2\163\1\156\1\157\1\154\1\162\2\141\1\156\2\164\1\163\1") + ("\165\3".to_u << 0xffff << "\1\154\1\162\1\171\2".to_u << 0xffff << "\1\164\1\154\1\167\1\157\1") + ("\164\1\145\1\156\1".to_u << 0xfaff << "\1\146\1\151\1\164\24".to_u << 0xffff << "\1\146\1".to_u << 0xffff << "") + ("\1\146\1\153\1\154\1\164\1\166\1\157\1".to_u << 0xfaff << "\1\164\1".to_u << 0xffff << "\1\164") + ("\1\151\1\143\1\162\1\145\2\164\1\145\2\141\1\163\1".to_u << 0xfaff << "\1\163\1") + "\162\1\164\1\143\3\145\1\155\1\144\1\141\1\157\1\163\1\156\1\145" + ("\1".to_u << 0xfaff << "\1\151\1\154\1".to_u << 0xfaff << "\1\154\1\145\1\141\1\147\1\142\1".to_u << 0xffff << "") + ("\1\141\1\154\1\165\1".to_u << 0xffff << "\1\141\1\151\1\145\1\141\1\162\1\145\1") + ("\162\1".to_u << 0xffff << "\1\141\1\151\1\143\1\150\1\164\1\162\1\143\2\162\1\154") + ("\1\164\1\145\1".to_u << 0xffff << "\1\163\1".to_u << 0xfaff << "\1\151\1\150\1".to_u << 0xfaff << "\1\156\3".to_u << 0xfaff << "") + ("\1\164\1\167\1".to_u << 0xfaff << "\1\163\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\166\1".to_u << 0xfaff << "\1".to_u << 0xffff << "") + ("\1\145\1".to_u << 0xfaff << "\1\153\1".to_u << 0xfaff << "\1\154\1\165\1\145\1\162\1\147\2\143") + ("\2\164\1\155\1\146\1\156\1\143\1\164\1\162\2".to_u << 0xfaff << "\1\150\1\141\1") + ("\164\4".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\156\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\144\3".to_u << 0xffff << "\1\151\1") + ("".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\151\1".to_u << 0xffff << "\1\145\1".to_u << 0xffff << "\1\141\1".to_u << 0xffff << "\1".to_u << 0xfaff << "") + ("\1".to_u << 0xffff << "\1\145\1\154\1".to_u << 0xfaff << "\1\156\1\145\1".to_u << 0xfaff << "\1\164\1\145\1".to_u << 0xfaff << "") + ("\1\145\1\141\1\143\1".to_u << 0xfaff << "\1\146\1\157\2".to_u << 0xffff << "\1".to_u << 0xfaff << "\1\143\1".to_u << 0xfaff << "") + ("\1\171\4".to_u << 0xffff << "\1\165\1".to_u << 0xffff << "\1\163\1\154\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\145\1") + ("".to_u << 0xfaff << "\1\156\1".to_u << 0xffff << "\1".to_u << 0xfaff << "\1\164\1".to_u << 0xffff << "\2".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\145") + ("\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1\156\1\143\1\145\1".to_u << 0xffff << "\1\160\1\156\1".to_u << 0xffff << "\1") + ("\164\1".to_u << 0xffff << "\1".to_u << 0xfaff << "\1\145\1".to_u << 0xfaff << "\1\145\1".to_u << 0xffff << "\1\156\1".to_u << 0xffff << "\1") + ("".to_u << 0xfaff << "\1".to_u << 0xffff << "\1".to_u << 0xfaff << "\2".to_u << 0xffff << "\1\144\1".to_u << 0xffff << "\1\164\1\145\1\157\1") + ("".to_u << 0xfaff << "\1\151\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1".to_u << 0xfaff << "\1\164\2".to_u << 0xffff << "") + ("\1".to_u << 0xfaff << "\1\163\1".to_u << 0xfaff << "\1\146\1".to_u << 0xffff << "\1\172\3".to_u << 0xffff << "\1".to_u << 0xfaff << "\1".to_u << 0xffff << "") + ("\1".to_u << 0xfaff << "\1".to_u << 0xffff << "\1".to_u << 0xfaff << "\1\145\3".to_u << 0xffff << "\1\144\1".to_u << 0xfaff << "\1".to_u << 0xffff << "") }
    const_attr_reader  :DFA29_maxS
    
    const_set_lazy(:DFA29_acceptS) { ("\2".to_u << 0xffff << "\1\2\10".to_u << 0xffff << "\1\20\1\21\1\22\1".to_u << 0xffff << "\1\24\1\25\1".to_u << 0xffff << "\1") + ("\30\1\31\6".to_u << 0xffff << "\1\50\1\52\1\53\1\61\1\63\11".to_u << 0xffff << "\1\127\2".to_u << 0xffff << "") + ("\1\136\1\137\1\142\1\143\13".to_u << 0xffff << "\1\54\1\5\1\135\1\104\1\6\15".to_u << 0xffff << "") + ("\1\106\1\113\1\23\3".to_u << 0xffff << "\1\116\1\33\13".to_u << 0xffff << "\1\102\1\125\1\121") + "\1\103\1\126\1\122\1\105\1\144\1\145\1\123\1\107\1\112\1\114\1\110" + ("\1\115\1\111\1\124\1\117\1\130\1\132\1".to_u << 0xffff << "\1\133\10".to_u << 0xffff << "\1\64") + ("\43".to_u << 0xffff << "\1\70\3".to_u << 0xffff << "\1\134\7".to_u << 0xffff << "\1\44\14".to_u << 0xffff << "\1\66\16".to_u << 0xffff << "") + ("\1\71\2".to_u << 0xffff << "\1\131\34".to_u << 0xffff << "\1\41\2".to_u << 0xffff << "\1\101\1".to_u << 0xffff << "\1\65\1\140") + ("\1\27\2".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\1\57\1".to_u << 0xffff << "\1\56\1".to_u << 0xffff << "\1\42\1".to_u << 0xffff << "") + ("\1\45\17".to_u << 0xffff << "\1\43\1\51\4".to_u << 0xffff << "\1\13\1\46\1\60\1\15\1".to_u << 0xffff << "\1\100") + ("\3".to_u << 0xffff << "\1\75\3".to_u << 0xffff << "\1\76\2".to_u << 0xffff << "\1\67\2".to_u << 0xffff << "\1\7\2".to_u << 0xffff << "\1\3") + ("\3".to_u << 0xffff << "\1\4\2".to_u << 0xffff << "\1\73\1".to_u << 0xffff << "\1\141\4".to_u << 0xffff << "\1\32\1".to_u << 0xffff << "\1\34") + ("\1".to_u << 0xffff << "\1\47\1".to_u << 0xffff << "\1\74\1\1\1".to_u << 0xffff << "\1\11\6".to_u << 0xffff << "\1\72\1".to_u << 0xffff << "") + ("\1\16\2".to_u << 0xffff << "\1\40\1\62\4".to_u << 0xffff << "\1\14\1".to_u << 0xffff << "\1\12\1\77\1\37\1".to_u << 0xffff << "") + ("\1\10\1".to_u << 0xffff << "\1\26\2".to_u << 0xffff << "\1\36\1\17\1\120\2".to_u << 0xffff << "\1\35") }
    const_attr_reader  :DFA29_acceptS
    
    const_set_lazy(:DFA29_specialS) { ("".to_u << 0x0161 << "".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA29_specialS
    
    const_set_lazy(:DFA29_transitionS) { Array.typed(String).new([("\2\56\1".to_u << 0xffff << "\2\56\22".to_u << 0xffff << "\1\56\1\47\1\54\1".to_u << 0xffff << "\1\55\1\46") + "\1\16\1\53\1\33\1\34\1\6\1\41\1\14\1\42\1\5\1\43\1\51\11\52" + ("\1\36\1\2\1\13\1\25\1\15\1\32\1\35\32\55\1\22\1".to_u << 0xffff << "\1\23\1") + ("\45\1\55\1".to_u << 0xffff << "\1\7\1\27\1\11\1\31\1\12\1\10\2\55\1\3\2\55") + "\1\30\1\55\1\26\1\55\1\1\1\55\1\40\1\4\1\24\1\55\1\21\1\37\3" + ("\55\1\17\1\44\1\20\1\50\101".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "") + ("".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "") + ("".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\57\20".to_u << 0xffff << "\1\61\2".to_u << 0xffff << "\1\60"), "", ("\1\64\6".to_u << 0xffff << "\1\62\1\63"), ("\1\67\13".to_u << 0xffff << "\1\65\1\70\1".to_u << 0xffff << "\1\71\1".to_u << 0xffff << "\1\66"), ("\1\72\1".to_u << 0xffff << "\12\74"), "\1\75", ("\1\77\20".to_u << 0xffff << "\1\100"), ("\1\103\7".to_u << 0xffff << "\1\101\2".to_u << 0xffff << "\1\102\2".to_u << 0xffff << "\1\104"), ("\1\110\6".to_u << 0xffff << "\1\106\3".to_u << 0xffff << "\1\105\2".to_u << 0xffff << "\1\107"), ("\1\112\1".to_u << 0xffff << "\1\113\11".to_u << 0xffff << "\1\111"), "", "", "", ("\1\115\26".to_u << 0xffff << "\1\114"), "", "", "\1\117", "", "", ("\1\120\11".to_u << 0xffff << "\1\121"), "\1\122", ("\1\124\3".to_u << 0xffff << "\1\126\17".to_u << 0xffff << "\1\125"), ("\1\127\2".to_u << 0xffff << "\1\131\6".to_u << 0xffff << "\1\130"), "\1\132", ("\1\134\11".to_u << 0xffff << "\1\133"), "", "", "", "", "", "\1\135", "\1\136", ("\1\140\21".to_u << 0xffff << "\1\137"), ("\1\143\17".to_u << 0xffff << "\1\142"), ("\1\146\4".to_u << 0xffff << "\1\147\15".to_u << 0xffff << "\1\145"), ("\1\151\76".to_u << 0xffff << "\1\152"), "\1\154", "\1\156", "\1\160", "", ("\1\74\1".to_u << 0xffff << "\10\163\2\74\12".to_u << 0xffff << "\3\74\21".to_u << 0xffff << "\1\162\13".to_u << 0xffff << "") + ("\3\74\21".to_u << 0xffff << "\1\162"), ("\1\74\1".to_u << 0xffff << "\12\165\12".to_u << 0xffff << "\3\74\35".to_u << 0xffff << "\3\74"), "", "", "", "", "\1\166", "\1\167", ("\1\171\5".to_u << 0xffff << "\1\170"), "\1\172", "\1\174\1\173", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\176\20".to_u << 0xffff << "\1\177"), ("\1".to_u << 0x0080 << ""), ("\1".to_u << 0x0081 << ""), ("\1".to_u << 0x0082 << ""), ("\1".to_u << 0x0083 << ""), "", "", "", "", "", ("\1".to_u << 0x0084 << ""), ("\1".to_u << 0x0085 << ""), ("\1".to_u << 0x0086 << ""), ("\1".to_u << 0x0087 << ""), ("\1".to_u << 0x0088 << ""), ("\1".to_u << 0x0089 << ""), ("\1".to_u << 0x008a << ""), ("\1".to_u << 0x008b << ""), ("\1".to_u << 0x008c << ""), ("\1".to_u << 0x008e << "\1".to_u << 0x008d << ""), ("\1".to_u << 0x008f << ""), ("\1".to_u << 0x0090 << ""), ("\1".to_u << 0x0091 << ""), "", "", "", ("\1".to_u << 0x0092 << "\2".to_u << 0xffff << "\1".to_u << 0x0093 << ""), ("\1".to_u << 0x0095 << "\10".to_u << 0xffff << "\1".to_u << 0x0094 << ""), ("\1".to_u << 0x0096 << "\23".to_u << 0xffff << "\1".to_u << 0x0097 << "\3".to_u << 0xffff << "\1".to_u << 0x0098 << ""), "", "", ("\1".to_u << 0x0099 << ""), ("\1".to_u << 0x009a << ""), ("\1".to_u << 0x009b << ""), ("\1".to_u << 0x009c << ""), ("\1".to_u << 0x009d << ""), ("\1".to_u << 0x009e << ""), ("\1".to_u << 0x009f << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\24") + ("\55\1".to_u << 0x00a0 << "\5\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "") + ("\55".to_u << 0x1040 << "".to_u << 0xffff << "".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "") + ("\55".to_u << 0x10d2 << "".to_u << 0xffff << "".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00a2 << ""), ("\1".to_u << 0x00a3 << ""), ("\1".to_u << 0x00a4 << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ("\1\74\1".to_u << 0xffff << "\10\163\2\74\12".to_u << 0xffff << "\3\74\35".to_u << 0xffff << "\3\74"), "", ("\1\74\1".to_u << 0xffff << "\12\165\12".to_u << 0xffff << "\3\74\35".to_u << 0xffff << "\3\74"), ("\1".to_u << 0x00a6 << ""), ("\1".to_u << 0x00a7 << ""), ("\1".to_u << 0x00a8 << ""), ("\1".to_u << 0x00a9 << ""), ("\1".to_u << 0x00ab << "\2".to_u << 0xffff << "\1".to_u << 0x00aa << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\4\55") + ("\1".to_u << 0x00ac << "\25\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55") + ("".to_u << 0x1040 << "".to_u << 0xffff << "".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "") + ("\55".to_u << 0x10d2 << "".to_u << 0xffff << "".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00ae << ""), "", ("\1".to_u << 0x00af << ""), ("\1".to_u << 0x00b0 << ""), ("\1".to_u << 0x00b1 << ""), ("\1".to_u << 0x00b2 << ""), ("\1".to_u << 0x00b3 << ""), ("\1".to_u << 0x00b4 << ""), ("\1".to_u << 0x00b5 << ""), ("\1".to_u << 0x00b6 << ""), ("\1".to_u << 0x00b7 << ""), ("\1".to_u << 0x00b8 << ""), ("\1".to_u << 0x00b9 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00bb << ""), ("\1".to_u << 0x00bc << ""), ("\1".to_u << 0x00bd << ""), ("\1".to_u << 0x00be << ""), ("\1".to_u << 0x00bf << ""), ("\1".to_u << 0x00c0 << ""), ("\1".to_u << 0x00c1 << ""), ("\1".to_u << 0x00c2 << ""), ("\1".to_u << 0x00c3 << ""), ("\1".to_u << 0x00c4 << ""), ("\1".to_u << 0x00c5 << ""), ("\1".to_u << 0x00c6 << ""), ("\1".to_u << 0x00c7 << ""), ("\1".to_u << 0x00c8 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00ca << ""), ("\1".to_u << 0x00cb << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00cd << ""), ("\1".to_u << 0x00ce << ""), ("\1".to_u << 0x00cf << ""), ("\1".to_u << 0x00d0 << ""), ("\1".to_u << 0x00d1 << ""), "", ("\1".to_u << 0x00d2 << ""), ("\1".to_u << 0x00d3 << ""), ("\1".to_u << 0x00d4 << ""), "", ("\1".to_u << 0x00d5 << ""), ("\1".to_u << 0x00d6 << ""), ("\1".to_u << 0x00d7 << ""), ("\1".to_u << 0x00d8 << ""), ("\1".to_u << 0x00d9 << ""), ("\1".to_u << 0x00da << ""), ("\1".to_u << 0x00db << ""), "", ("\1".to_u << 0x00dc << ""), ("\1".to_u << 0x00dd << ""), ("\1".to_u << 0x00de << ""), ("\1".to_u << 0x00df << ""), ("\1".to_u << 0x00e0 << ""), ("\1".to_u << 0x00e1 << ""), ("\1".to_u << 0x00e2 << ""), ("\1".to_u << 0x00e3 << ""), ("\1".to_u << 0x00e4 << ""), ("\1".to_u << 0x00e5 << ""), ("\1".to_u << 0x00e6 << ""), ("\1".to_u << 0x00e7 << ""), "", ("\1".to_u << 0x00e8 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00ea << ""), ("\1".to_u << 0x00eb << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00ed << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00f1 << ""), ("\1".to_u << 0x00f2 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00f4 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x00f6 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x00f8 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00fa << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x00fc << ""), ("\1".to_u << 0x00fd << ""), ("\1".to_u << 0x00fe << ""), ("\1".to_u << 0x00ff << ""), ("\1".to_u << 0x0100 << ""), ("\1".to_u << 0x0101 << ""), ("\1".to_u << 0x0102 << ""), ("\1".to_u << 0x0103 << ""), ("\1".to_u << 0x0104 << ""), ("\1".to_u << 0x0105 << ""), ("\1".to_u << 0x0106 << ""), ("\1".to_u << 0x0107 << ""), ("\1".to_u << 0x0108 << ""), ("\1".to_u << 0x0109 << ""), ("\1".to_u << 0x010a << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x010d << ""), ("\1".to_u << 0x010e << ""), ("\1".to_u << 0x010f << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\13") + ("\55\1".to_u << 0x0110 << "\16\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "") + ("\55".to_u << 0x1040 << "".to_u << 0xffff << "".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "") + ("\55".to_u << 0x10d2 << "".to_u << 0xffff << "".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x0115 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x0117 << ""), "", "", "", ("\1".to_u << 0x0118 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\22") + ("\55\1".to_u << 0x0119 << "\7\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "") + ("\55".to_u << 0x1040 << "".to_u << 0xffff << "".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "") + ("\55".to_u << 0x10d2 << "".to_u << 0xffff << "".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x011b << ""), "", ("\1".to_u << 0x011c << ""), "", ("\1".to_u << 0x011d << ""), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x011f << ""), ("\1".to_u << 0x0120 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0122 << ""), ("\1".to_u << 0x0123 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0125 << ""), ("\1".to_u << 0x0126 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0128 << ""), ("\1".to_u << 0x0129 << ""), ("\1".to_u << 0x012a << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x012c << ""), ("\1".to_u << 0x012d << ""), "", "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x012f << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0131 << ""), "", "", "", "", ("\1".to_u << 0x0132 << ""), "", ("\1".to_u << 0x0133 << ""), ("\1".to_u << 0x0134 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x0136 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0138 << ""), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x013a << ""), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x013d << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1".to_u << 0x013f << ""), ("\1".to_u << 0x0140 << ""), ("\1".to_u << 0x0141 << ""), "", ("\1".to_u << 0x0142 << ""), ("\1".to_u << 0x0143 << ""), "", ("\1".to_u << 0x0144 << ""), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0146 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0148 << ""), "", ("\1".to_u << 0x0149 << ""), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", "", ("\1".to_u << 0x014c << ""), "", ("\1".to_u << 0x014d << ""), ("\1".to_u << 0x014e << ""), ("\1".to_u << 0x014f << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0151 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0155 << ""), "", "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0157 << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x0159 << ""), "", ("\1".to_u << 0x015a << ""), "", "", "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), "", ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ("\1".to_u << 0x015e << ""), "", "", "", ("\1".to_u << 0x015f << ""), ("\1\55\13".to_u << 0xffff << "\12\55\7".to_u << 0xffff << "\32\55\4".to_u << 0xffff << "\1\55\1".to_u << 0xffff << "\32") + ("\55\105".to_u << 0xffff << "\27\55\1".to_u << 0xffff << "\37\55\1".to_u << 0xffff << "".to_u << 0x1f08 << "\55".to_u << 0x1040 << "".to_u << 0xffff << "") + ("".to_u << 0x0150 << "\55".to_u << 0x0170 << "".to_u << 0xffff << "".to_u << 0x0080 << "\55".to_u << 0x0080 << "".to_u << 0xffff << "".to_u << 0x092e << "\55".to_u << 0x10d2 << "".to_u << 0xffff << "") + ("".to_u << 0x5200 << "\55".to_u << 0x5900 << "".to_u << 0xffff << "".to_u << 0x0200 << "\55"), ""]) }
    const_attr_reader  :DFA29_transitionS
    
    const_set_lazy(:DFA29_eot) { DFA.unpack_encoded_string(DFA29_eotS) }
    const_attr_reader  :DFA29_eot
    
    const_set_lazy(:DFA29_eof) { DFA.unpack_encoded_string(DFA29_eofS) }
    const_attr_reader  :DFA29_eof
    
    const_set_lazy(:DFA29_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA29_minS) }
    const_attr_reader  :DFA29_min
    
    const_set_lazy(:DFA29_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA29_maxS) }
    const_attr_reader  :DFA29_max
    
    const_set_lazy(:DFA29_accept) { DFA.unpack_encoded_string(DFA29_acceptS) }
    const_attr_reader  :DFA29_accept
    
    const_set_lazy(:DFA29_special) { DFA.unpack_encoded_string(DFA29_specialS) }
    const_attr_reader  :DFA29_special
    
    when_class_loaded do
      num_states = DFA29_transitionS.attr_length
      const_set :DFA29_transition, Array.typed(::Java::Short).new(num_states) { 0 }
      i = 0
      while i < num_states
        DFA29_transition[i] = DFA.unpack_encoded_string(DFA29_transitionS[i])
        ((i += 1) - 1)
      end
    end
    
    const_set_lazy(:DFA29) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaLexer
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 29
        self.attr_eot = DFA29_eot
        self.attr_eof = DFA29_eof
        self.attr_min = DFA29_min
        self.attr_max = DFA29_max
        self.attr_accept = DFA29_accept
        self.attr_special = DFA29_special
        self.attr_transition = DFA29_transition
      end
      
      typesig { [] }
      def get_description
        return "1:1: Tokens : ( T__25 | T__26 | T__27 | T__28 | T__29 | T__30 | T__31 | T__32 | T__33 | T__34 | T__35 | T__36 | T__37 | T__38 | T__39 | T__40 | T__41 | T__42 | T__43 | T__44 | T__45 | T__46 | T__47 | T__48 | T__49 | T__50 | T__51 | T__52 | T__53 | T__54 | T__55 | T__56 | T__57 | T__58 | T__59 | T__60 | T__61 | T__62 | T__63 | T__64 | T__65 | T__66 | T__67 | T__68 | T__69 | T__70 | T__71 | T__72 | T__73 | T__74 | T__75 | T__76 | T__77 | T__78 | T__79 | T__80 | T__81 | T__82 | T__83 | T__84 | T__85 | T__86 | T__87 | T__88 | T__89 | T__90 | T__91 | T__92 | T__93 | T__94 | T__95 | T__96 | T__97 | T__98 | T__99 | T__100 | T__101 | T__102 | T__103 | T__104 | T__105 | T__106 | T__107 | T__108 | T__109 | T__110 | T__111 | T__112 | T__113 | HexLiteral | DecimalLiteral | OctalLiteral | FloatingPointLiteral | CharacterLiteral | StringLiteral | ENUM | ASSERT | Identifier | WS | COMMENT | LINE_COMMENT );"
      end
      
      private
      alias_method :initialize__dfa29, :initialize
    end }
  }
  
  private
  alias_method :initialize__java_lexer, :initialize
end

