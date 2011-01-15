require "rjava"
 # $ANTLR 3.1.1 Java.g 2008-10-11 00:39:43
module JavaParserImports
  class_module.module_eval {
    include ::Java::Lang
    include ::Org::Antlr::Runtime
    include_const ::Java::Util, :Stack
    include_const ::Java::Util, :JavaList
    include_const ::Java::Util, :ArrayList
    include_const ::Java::Util, :Map
    include_const ::Java::Util, :HashMap
    include ::Org::Antlr::Runtime::Debug
    include_const ::Java::Io, :IOException
  }
end

# A Java 1.5 grammar for ANTLR v3 derived from the spec
# 
# This is a very close representation of the spec; the changes
# are comestic (remove left recursion) and also fixes (the spec
# isn't exactly perfect).  I have run this on the 1.4.2 source
# and some nasty looking enums from 1.5, but have not really
# tested for 1.5 compatibility.
# 
# I built this with: java -Xmx100M org.antlr.Tool java.g
# and got two errors that are ok (for now):
# java.g:691:9: Decision can match input such as
# "'0'..'9'{'E', 'e'}{'+', '-'}'0'..'9'{'D', 'F', 'd', 'f'}"
# using multiple alternatives: 3, 4
# As a result, alternative(s) 4 were disabled for that input
# java.g:734:35: Decision can match input such as "{'$', 'A'..'Z',
# '_', 'a'..'z', '\u00C0'..'\u00D6', '\u00D8'..'\u00F6',
# '\u00F8'..'\u1FFF', '\u3040'..'\u318F', '\u3300'..'\u337F',
# '\u3400'..'\u3D2D', '\u4E00'..'\u9FFF', '\uF900'..'\uFAFF'}"
# using multiple alternatives: 1, 2
# As a result, alternative(s) 2 were disabled for that input
# 
# You can turn enum on/off as a keyword :)
# 
# Version 1.0 -- initial release July 5, 2006 (requires 3.0b2 or higher)
# 
# Primary author: Terence Parr, July 2006
# 
# Version 1.0.1 -- corrections by Koen Vanderkimpen & Marko van Dooren,
# October 25, 2006;
# fixed normalInterfaceDeclaration: now uses typeParameters instead
# of typeParameter (according to JLS, 3rd edition)
# fixed castExpression: no longer allows expression next to type
# (according to semantics in JLS, in contrast with syntax in JLS)
# 
# Version 1.0.2 -- Terence Parr, Nov 27, 2006
# java spec I built this from had some bizarre for-loop control.
# Looked weird and so I looked elsewhere...Yep, it's messed up.
# simplified.
# 
# Version 1.0.3 -- Chris Hogue, Feb 26, 2007
# Factored out an annotationName rule and used it in the annotation rule.
# Not sure why, but typeName wasn't recognizing references to inner
# annotations (e.g. @InterfaceName.InnerAnnotation())
# Factored out the elementValue section of an annotation reference.  Created
# elementValuePair and elementValuePairs rules, then used them in the
# annotation rule.  Allows it to recognize annotation references with
# multiple, comma separated attributes.
# Updated elementValueArrayInitializer so that it allows multiple elements.
# (It was only allowing 0 or 1 element).
# Updated localVariableDeclaration to allow annotations.  Interestingly the JLS
# doesn't appear to indicate this is legal, but it does work as of at least
# JDK 1.5.0_06.
# Moved the Identifier portion of annotationTypeElementRest to annotationMethodRest.
# Because annotationConstantRest already references variableDeclarator which
# has the Identifier portion in it, the parser would fail on constants in
# annotation definitions because it expected two identifiers.
# Added optional trailing ';' to the alternatives in annotationTypeElementRest.
# Wouldn't handle an inner interface that has a trailing ';'.
# Swapped the expression and type rule reference order in castExpression to
# make it check for genericized casts first.  It was failing to recognize a
# statement like  "Class<Byte> TYPE = (Class<Byte>)...;" because it was seeing
# 'Class<Byte' in the cast expression as a less than expression, then failing
# on the '>'.
# Changed createdName to use typeArguments instead of nonWildcardTypeArguments.
# Again, JLS doesn't seem to allow this, but java.lang.Class has an example of
# of this construct.
# Changed the 'this' alternative in primary to allow 'identifierSuffix' rather than
# just 'arguments'.  The case it couldn't handle was a call to an explicit
# generic method invocation (e.g. this.<E>doSomething()).  Using identifierSuffix
# may be overly aggressive--perhaps should create a more constrained thisSuffix rule?
# 
# Version 1.0.4 -- Hiroaki Nakamura, May 3, 2007
# 
# Fixed formalParameterDecls, localVariableDeclaration, forInit,
# and forVarControl to use variableModifier* not 'final'? (annotation)?
# 
# Version 1.0.5 -- Terence, June 21, 2007
# --a[i].foo didn't work. Fixed unaryExpression
# 
# Version 1.0.6 -- John Ridgway, March 17, 2008
# Made "assert" a switchable keyword like "enum".
# Fixed compilationUnit to disallow "annotation importDeclaration ...".
# Changed "Identifier ('.' Identifier)*" to "qualifiedName" in more
# places.
# Changed modifier* and/or variableModifier* to classOrInterfaceModifiers,
# modifiers or variableModifiers, as appropriate.
# Renamed "bound" to "typeBound" to better match language in the JLS.
# Added "memberDeclaration" which rewrites to methodDeclaration or
# fieldDeclaration and pulled type into memberDeclaration.  So we parse
# type and then move on to decide whether we're dealing with a field
# or a method.
# Modified "constructorDeclaration" to use "constructorBody" instead of
# "methodBody".  constructorBody starts with explicitConstructorInvocation,
# then goes on to blockStatement*.  Pulling explicitConstructorInvocation
# out of expressions allowed me to simplify "primary".
# Changed variableDeclarator to simplify it.
# Changed type to use classOrInterfaceType, thus simplifying it; of course
# I then had to add classOrInterfaceType, but it is used in several
# places.
# Fixed annotations, old version allowed "@X(y,z)", which is illegal.
# Added optional comma to end of "elementValueArrayInitializer"; as per JLS.
# Changed annotationTypeElementRest to use normalClassDeclaration and
# normalInterfaceDeclaration rather than classDeclaration and
# interfaceDeclaration, thus getting rid of a couple of grammar ambiguities.
# Split localVariableDeclaration into localVariableDeclarationStatement
# (includes the terminating semi-colon) and localVariableDeclaration.
# This allowed me to use localVariableDeclaration in "forInit" clauses,
# simplifying them.
# Changed switchBlockStatementGroup to use multiple labels.  This adds an
# ambiguity, but if one uses appropriately greedy parsing it yields the
# parse that is closest to the meaning of the switch statement.
# Renamed "forVarControl" to "enhancedForControl" -- JLS language.
# Added semantic predicates to test for shift operations rather than other
# things.  Thus, for instance, the string "< <" will never be treated
# as a left-shift operator.
# In "creator" we rule out "nonWildcardTypeArguments" on arrayCreation,
# which are illegal.
# Moved "nonWildcardTypeArguments into innerCreator.
# Removed 'super' superSuffix from explicitGenericInvocation, since that
# is only used in explicitConstructorInvocation at the beginning of a
# constructorBody.  (This is part of the simplification of expressions
# mentioned earlier.)
# Simplified primary (got rid of those things that are only used in
# explicitConstructorInvocation).
# Lexer -- removed "Exponent?" from FloatingPointLiteral choice 4, since it
# led to an ambiguity.
# 
# This grammar successfully parses every .java file in the JDK 1.5 source
# tree (excluding those whose file names include '-', which are not
# valid Java compilation units).
# 
# Known remaining problems:
# "Letter" and "JavaIDDigit" are wrong.  The actual specification of
# "Letter" should be "a character for which the method
# Character.isJavaIdentifierStart(int) returns true."  A "Java
# letter-or-digit is a character for which the method
# Character.isJavaIdentifierPart(int) returns true."
class JavaParser < JavaParserImports.const_get :DebugParser
  include_class_members JavaParserImports
  
  class_module.module_eval {
    const_set_lazy(:TokenNames) { Array.typed(String).new(["<invalid>", "<EOR>", "<DOWN>", "<UP>", "Identifier", "ENUM", "FloatingPointLiteral", "CharacterLiteral", "StringLiteral", "HexLiteral", "OctalLiteral", "DecimalLiteral", "ASSERT", "HexDigit", "IntegerTypeSuffix", "Exponent", "FloatTypeSuffix", "EscapeSequence", "UnicodeEscape", "OctalEscape", "Letter", "JavaIDDigit", "WS", "COMMENT", "LINE_COMMENT", "'package'", "';'", "'import'", "'static'", "'.'", "'*'", "'public'", "'protected'", "'private'", "'abstract'", "'final'", "'strictfp'", "'class'", "'extends'", "'implements'", "'<'", "','", "'>'", "'&'", "'{'", "'}'", "'interface'", "'void'", "'['", "']'", "'throws'", "'='", "'native'", "'synchronized'", "'transient'", "'volatile'", "'boolean'", "'char'", "'byte'", "'short'", "'int'", "'long'", "'float'", "'double'", "'?'", "'super'", "'('", "')'", "'...'", "'this'", "'null'", "'true'", "'false'", "'@'", "'default'", "':'", "'if'", "'else'", "'for'", "'while'", "'do'", "'try'", "'finally'", "'switch'", "'return'", "'throw'", "'break'", "'continue'", "'catch'", "'case'", "'+='", "'-='", "'*='", "'/='", "'&='", "'|='", "'^='", "'%='", "'||'", "'&&'", "'|'", "'^'", "'=='", "'!='", "'instanceof'", "'+'", "'-'", "'/'", "'%'", "'++'", "'--'", "'~'", "'!'", "'new'"]) }
    const_attr_reader  :TokenNames
    
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
    
    const_set_lazy(:ASSERT) { 12 }
    const_attr_reader  :ASSERT
    
    const_set_lazy(:T__87) { 87 }
    const_attr_reader  :T__87
    
    const_set_lazy(:T__86) { 86 }
    const_attr_reader  :T__86
    
    const_set_lazy(:T__89) { 89 }
    const_attr_reader  :T__89
    
    const_set_lazy(:T__88) { 88 }
    const_attr_reader  :T__88
    
    const_set_lazy(:WS) { 22 }
    const_attr_reader  :WS
    
    const_set_lazy(:T__71) { 71 }
    const_attr_reader  :T__71
    
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
    
    const_set_lazy(:ENUM) { 5 }
    const_attr_reader  :ENUM
    
    const_set_lazy(:T__34) { 34 }
    const_attr_reader  :T__34
    
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
    
    # delegates
    # delegators
    const_set_lazy(:RuleNames) { Array.typed(String).new(["invalidRule", "synpred140_Java", "constantDeclaratorsRest", "synpred258_Java", "annotationName", "enumDeclaration", "synpred257_Java", "synpred81_Java", "synpred144_Java", "synpred214_Java", "synpred41_Java", "synpred172_Java", "typeList", "synpred46_Java", "synpred183_Java", "synpred44_Java", "synpred32_Java", "synpred1_Java", "synpred195_Java", "synpred24_Java", "synpred268_Java", "synpred128_Java", "synpred137_Java", "synpred99_Java", "synpred102_Java", "unaryExpressionNotPlusMinus", "selector", "catches", "classCreatorRest", "synpred31_Java", "synpred20_Java", "memberDeclaration", "synpred244_Java", "assignmentOperator", "synpred30_Java", "synpred185_Java", "synpred248_Java", "classDeclaration", "formalParameterDeclsRest", "synpred234_Java", "synpred21_Java", "synpred190_Java", "synpred203_Java", "synpred201_Java", "synpred264_Java", "synpred11_Java", "importDeclaration", "synpred148_Java", "synpred7_Java", "synpred124_Java", "synpred135_Java", "expressionList", "methodDeclaration", "synpred187_Java", "blockStatement", "conditionalOrExpression", "synpred105_Java", "nonWildcardTypeArguments", "type", "synpred63_Java", "methodDeclaratorRest", "synpred74_Java", "synpred192_Java", "synpred96_Java", "forControl", "synpred236_Java", "andExpression", "arrayInitializer", "synpred156_Java", "synpred64_Java", "synpred3_Java", "formalParameterDecls", "primary", "catchClause", "synpred58_Java", "synpred272_Java", "synpred212_Java", "synpred222_Java", "synpred126_Java", "synpred255_Java", "synpred37_Java", "synpred153_Java", "synpred235_Java", "synpred228_Java", "castExpression", "annotations", "synpred173_Java", "synpred69_Java", "synpred182_Java", "synpred14_Java", "synpred95_Java", "synpred35_Java", "synpred116_Java", "synpred62_Java", "synpred19_Java", "parExpression", "synpred34_Java", "classOrInterfaceModifiers", "annotationTypeDeclaration", "synpred152_Java", "synpred188_Java", "synpred164_Java", "synpred16_Java", "genericMethodOrConstructorRest", "synpred110_Java", "synpred132_Java", "synpred217_Java", "interfaceMethodOrFieldDecl", "voidMethodDeclaratorRest", "elementValuePair", "synpred8_Java", "modifiers", "voidInterfaceMethodDeclaratorRest", "enumBodyDeclarations", "constantExpression", "classOrInterfaceDeclaration", "synpred55_Java", "synpred39_Java", "synpred224_Java", "normalInterfaceDeclaration", "synpred218_Java", "synpred10_Java", "switchBlockStatementGroup", "qualifiedName", "synpred68_Java", "elementValueArrayInitializer", "synpred186_Java", "synpred85_Java", "synpred65_Java", "synpred133_Java", "synpred151_Java", "explicitConstructorInvocation", "synpred176_Java", "synpred130_Java", "synpred146_Java", "synpred100_Java", "synpred94_Java", "synpred159_Java", "synpred97_Java", "synpred13_Java", "forInit", "synpred71_Java", "synpred251_Java", "synpred249_Java", "synpred265_Java", "synpred138_Java", "statementExpression", "synpred141_Java", "synpred6_Java", "synpred165_Java", "synpred149_Java", "synpred232_Java", "enumConstantName", "synpred239_Java", "synpred136_Java", "synpred219_Java", "synpred28_Java", "synpred120_Java", "synpred134_Java", "synpred191_Java", "synpred154_Java", "synpred155_Java", "synpred33_Java", "synpred26_Java", "synpred70_Java", "packageDeclaration", "synpred261_Java", "elementValuePairs", "identifierSuffix", "creator", "synpred267_Java", "synpred259_Java", "synpred123_Java", "additiveExpression", "constantDeclaratorRest", "synpred189_Java", "synpred266_Java", "enumConstant", "defaultValue", "classOrInterfaceType", "synpred254_Java", "synpred45_Java", "synpred202_Java", "synpred168_Java", "normalClassDeclaration", "conditionalAndExpression", "synpred131_Java", "synpred231_Java", "synpred210_Java", "synpred233_Java", "synpred208_Java", "typeArguments", "synpred160_Java", "typeParameter", "arrayCreatorRest", "synpred175_Java", "localVariableDeclaration", "statement", "synpred243_Java", "synpred129_Java", "synpred229_Java", "synpred230_Java", "synpred78_Java", "synpred86_Java", "booleanLiteral", "synpred80_Java", "equalityExpression", "synpred115_Java", "synpred206_Java", "interfaceDeclaration", "interfaceBody", "synpred15_Java", "synpred119_Java", "synpred109_Java", "synpred200_Java", "synpred216_Java", "synpred209_Java", "annotationMethodRest", "synpred181_Java", "synpred73_Java", "synpred171_Java", "arguments", "synpred194_Java", "synpred106_Java", "modifier", "synpred184_Java", "synpred121_Java", "synpred180_Java", "synpred51_Java", "synpred178_Java", "synpred158_Java", "synpred29_Java", "synpred112_Java", "synpred17_Java", "unaryExpression", "synpred66_Java", "synpred88_Java", "synpred270_Java", "synpred92_Java", "synpred60_Java", "synpred223_Java", "synpred211_Java", "annotation", "conditionalExpression", "synpred103_Java", "synpred87_Java", "synpred118_Java", "instanceOfExpression", "shiftExpression", "variableModifier", "synpred61_Java", "annotationMethodOrConstantRest", "interfaceMethodDeclaratorRest", "primitiveType", "synpred98_Java", "formalParameter", "memberDecl", "synpred177_Java", "synpred198_Java", "synpred38_Java", "synpred196_Java", "synpred143_Java", "synpred83_Java", "synpred127_Java", "synpred52_Java", "synpred262_Java", "elementValue", "synpred227_Java", "synpred122_Java", "explicitGenericInvocation", "synpred163_Java", "variableDeclaratorId", "constantDeclarator", "classBody", "synpred269_Java", "annotationTypeElementDeclaration", "synpred56_Java", "synpred40_Java", "synpred215_Java", "synpred23_Java", "enhancedForControl", "synpred199_Java", "interfaceMemberDecl", "superSuffix", "synpred54_Java", "interfaceGenericMethodDecl", "methodBody", "synpred113_Java", "synpred207_Java", "shiftOp", "synpred204_Java", "synpred147_Java", "synpred77_Java", "synpred247_Java", "synpred162_Java", "formalParameters", "synpred157_Java", "createdName", "synpred256_Java", "synpred107_Java", "expression", "synpred27_Java", "synpred72_Java", "synpred47_Java", "synpred220_Java", "synpred242_Java", "synpred75_Java", "innerCreator", "switchBlockStatementGroups", "forUpdate", "synpred36_Java", "synpred226_Java", "synpred49_Java", "synpred59_Java", "synpred84_Java", "relationalOp", "variableDeclarators", "typeParameters", "synpred93_Java", "qualifiedNameList", "synpred179_Java", "synpred142_Java", "synpred76_Java", "synpred246_Java", "genericMethodOrConstructorDecl", "synpred43_Java", "packageOrTypeName", "typeDeclaration", "synpred22_Java", "synpred9_Java", "variableDeclarator", "annotationTypeElementRest", "interfaceBodyDeclaration", "typeArgument", "synpred42_Java", "synpred2_Java", "multiplicativeExpression", "synpred193_Java", "synpred161_Java", "inclusiveOrExpression", "synpred91_Java", "synpred253_Java", "constructorBody", "synpred5_Java", "integerLiteral", "synpred57_Java", "synpred25_Java", "synpred139_Java", "synpred213_Java", "synpred241_Java", "enumBody", "synpred260_Java", "synpred167_Java", "interfaceMethodOrFieldRest", "synpred82_Java", "synpred250_Java", "localVariableDeclarationStatement", "synpred238_Java", "exclusiveOrExpression", "synpred240_Java", "switchLabel", "synpred174_Java", "synpred12_Java", "synpred4_Java", "block", "synpred221_Java", "synpred50_Java", "synpred114_Java", "annotationConstantRest", "synpred108_Java", "synpred117_Java", "synpred237_Java", "synpred18_Java", "annotationTypeBody", "variableModifiers", "synpred197_Java", "classOrInterfaceModifier", "variableInitializer", "synpred145_Java", "synpred90_Java", "constructorDeclaratorRest", "synpred104_Java", "synpred170_Java", "synpred101_Java", "synpred111_Java", "typeBound", "relationalExpression", "enumConstants", "classBodyDeclaration", "synpred245_Java", "synpred53_Java", "synpred125_Java", "synpred79_Java", "synpred169_Java", "compilationUnit", "synpred263_Java", "synpred48_Java", "synpred252_Java", "synpred271_Java", "synpred150_Java", "synpred166_Java", "typeName", "synpred67_Java", "literal", "synpred225_Java", "synpred89_Java", "synpred205_Java", "fieldDeclaration"]) }
    const_attr_reader  :RuleNames
  }
  
  attr_accessor :rule_level
  alias_method :attr_rule_level, :rule_level
  undef_method :rule_level
  alias_method :attr_rule_level=, :rule_level=
  undef_method :rule_level=
  
  typesig { [] }
  def get_rule_level
    return @rule_level
  end
  
  typesig { [] }
  def inc_rule_level
    @rule_level += 1
  end
  
  typesig { [] }
  def dec_rule_level
    @rule_level -= 1
  end
  
  typesig { [TokenStream] }
  def initialize(input)
    initialize__java_parser(input, DebugEventSocketProxy::DEFAULT_DEBUGGER_PORT, RecognizerSharedState.new)
  end
  
  typesig { [TokenStream, ::Java::Int, RecognizerSharedState] }
  def initialize(input, port, state)
    @rule_level = 0
    @dfa8 = nil
    @dfa81 = nil
    @dfa85 = nil
    @dfa106 = nil
    @dfa114 = nil
    @dfa123 = nil
    @dfa124 = nil
    @dfa126 = nil
    @dfa127 = nil
    @dfa139 = nil
    @dfa145 = nil
    @dfa146 = nil
    @dfa149 = nil
    @dfa151 = nil
    @dfa156 = nil
    @dfa155 = nil
    @dfa162 = nil
    super(input, state)
    @rule_level = 0
    @dfa8 = DFA8.new_local(self, self)
    @dfa81 = DFA81.new_local(self, self)
    @dfa85 = DFA85.new_local(self, self)
    @dfa106 = DFA106.new_local(self, self)
    @dfa114 = DFA114.new_local(self, self)
    @dfa123 = DFA123.new_local(self, self)
    @dfa124 = DFA124.new_local(self, self)
    @dfa126 = DFA126.new_local(self, self)
    @dfa127 = DFA127.new_local(self, self)
    @dfa139 = DFA139.new_local(self, self)
    @dfa145 = DFA145.new_local(self, self)
    @dfa146 = DFA146.new_local(self, self)
    @dfa149 = DFA149.new_local(self, self)
    @dfa151 = DFA151.new_local(self, self)
    @dfa156 = DFA156.new_local(self, self)
    @dfa155 = DFA155.new_local(self, self)
    @dfa162 = DFA162.new_local(self, self)
    self.attr_state.attr_rule_memo = Array.typed(HashMap).new(407 + 1) { nil }
    proxy = DebugEventSocketProxy.new(self, port, nil)
    set_debug_listener(proxy)
    begin
      proxy.handshake
    rescue IOException => ioe
      report_error(ioe)
    end
  end
  
  typesig { [TokenStream, DebugEventListener] }
  def initialize(input, dbg)
    @rule_level = 0
    @dfa8 = nil
    @dfa81 = nil
    @dfa85 = nil
    @dfa106 = nil
    @dfa114 = nil
    @dfa123 = nil
    @dfa124 = nil
    @dfa126 = nil
    @dfa127 = nil
    @dfa139 = nil
    @dfa145 = nil
    @dfa146 = nil
    @dfa149 = nil
    @dfa151 = nil
    @dfa156 = nil
    @dfa155 = nil
    @dfa162 = nil
    super(input, dbg, RecognizerSharedState.new)
    @rule_level = 0
    @dfa8 = DFA8.new_local(self, self)
    @dfa81 = DFA81.new_local(self, self)
    @dfa85 = DFA85.new_local(self, self)
    @dfa106 = DFA106.new_local(self, self)
    @dfa114 = DFA114.new_local(self, self)
    @dfa123 = DFA123.new_local(self, self)
    @dfa124 = DFA124.new_local(self, self)
    @dfa126 = DFA126.new_local(self, self)
    @dfa127 = DFA127.new_local(self, self)
    @dfa139 = DFA139.new_local(self, self)
    @dfa145 = DFA145.new_local(self, self)
    @dfa146 = DFA146.new_local(self, self)
    @dfa149 = DFA149.new_local(self, self)
    @dfa151 = DFA151.new_local(self, self)
    @dfa156 = DFA156.new_local(self, self)
    @dfa155 = DFA155.new_local(self, self)
    @dfa162 = DFA162.new_local(self, self)
    self.attr_state.attr_rule_memo = Array.typed(HashMap).new(407 + 1) { nil }
  end
  
  typesig { [::Java::Boolean, String] }
  def eval_predicate(result, predicate)
    self.attr_dbg.semantic_predicate(result, predicate)
    return result
  end
  
  typesig { [] }
  def get_token_names
    return JavaParser.attr_token_names
  end
  
  typesig { [] }
  def get_grammar_file_name
    return "Java.g"
  end
  
  typesig { [] }
  # $ANTLR start "compilationUnit"
  # Java.g:177:1: compilationUnit : ( annotations ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* ) | ( packageDeclaration )? ( importDeclaration )* ( typeDeclaration )* );
  def compilation_unit
    compilation_unit_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "compilationUnit")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(177, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 1))
          return
        end
        # Java.g:178:5: ( annotations ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* ) | ( packageDeclaration )? ( importDeclaration )* ( typeDeclaration )* )
        alt8 = 2
        begin
          self.attr_dbg.enter_decision(8)
          begin
            self.attr_is_cyclic_decision = true
            alt8 = @dfa8.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(8)
        end
        case (alt8)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:178:9: annotations ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* )
          self.attr_dbg.location(178, 9)
          push_follow(FOLLOW_annotations_in_compilationUnit44)
          annotations
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(179, 9)
          # Java.g:179:9: ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* )
          alt4 = 2
          begin
            self.attr_dbg.enter_sub_rule(4)
            begin
              self.attr_dbg.enter_decision(4)
              la4_0 = self.attr_input._la(1)
              if (((la4_0).equal?(25)))
                alt4 = 1
              else
                if (((la4_0).equal?(ENUM) || (la4_0).equal?(28) || (la4_0 >= 31 && la4_0 <= 37) || (la4_0).equal?(46) || (la4_0).equal?(73)))
                  alt4 = 2
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 4, 0, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            ensure
              self.attr_dbg.exit_decision(4)
            end
            case (alt4)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:179:13: packageDeclaration ( importDeclaration )* ( typeDeclaration )*
              self.attr_dbg.location(179, 13)
              push_follow(FOLLOW_packageDeclaration_in_compilationUnit58)
              package_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(179, 32)
              # Java.g:179:32: ( importDeclaration )*
              begin
                self.attr_dbg.enter_sub_rule(1)
                begin
                  alt1 = 2
                  begin
                    self.attr_dbg.enter_decision(1)
                    la1_0 = self.attr_input._la(1)
                    if (((la1_0).equal?(27)))
                      alt1 = 1
                    end
                  ensure
                    self.attr_dbg.exit_decision(1)
                  end
                  case (alt1)
                  when 1
                    self.attr_dbg.enter_alt(1)
                    # Java.g:0:0: importDeclaration
                    self.attr_dbg.location(179, 32)
                    push_follow(FOLLOW_importDeclaration_in_compilationUnit60)
                    import_declaration
                    self.attr_state.attr__fsp -= 1
                    if (self.attr_state.attr_failed)
                      return
                    end
                  else
                    break
                  end
                end while (true)
              ensure
                self.attr_dbg.exit_sub_rule(1)
              end
              self.attr_dbg.location(179, 51)
              # Java.g:179:51: ( typeDeclaration )*
              begin
                self.attr_dbg.enter_sub_rule(2)
                begin
                  alt2 = 2
                  begin
                    self.attr_dbg.enter_decision(2)
                    la2_0 = self.attr_input._la(1)
                    if (((la2_0).equal?(ENUM) || (la2_0).equal?(26) || (la2_0).equal?(28) || (la2_0 >= 31 && la2_0 <= 37) || (la2_0).equal?(46) || (la2_0).equal?(73)))
                      alt2 = 1
                    end
                  ensure
                    self.attr_dbg.exit_decision(2)
                  end
                  case (alt2)
                  when 1
                    self.attr_dbg.enter_alt(1)
                    # Java.g:0:0: typeDeclaration
                    self.attr_dbg.location(179, 51)
                    push_follow(FOLLOW_typeDeclaration_in_compilationUnit63)
                    type_declaration
                    self.attr_state.attr__fsp -= 1
                    if (self.attr_state.attr_failed)
                      return
                    end
                  else
                    break
                  end
                end while (true)
              ensure
                self.attr_dbg.exit_sub_rule(2)
              end
            when 2
              self.attr_dbg.enter_alt(2)
              # Java.g:180:13: classOrInterfaceDeclaration ( typeDeclaration )*
              self.attr_dbg.location(180, 13)
              push_follow(FOLLOW_classOrInterfaceDeclaration_in_compilationUnit78)
              class_or_interface_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(180, 41)
              # Java.g:180:41: ( typeDeclaration )*
              begin
                self.attr_dbg.enter_sub_rule(3)
                begin
                  alt3 = 2
                  begin
                    self.attr_dbg.enter_decision(3)
                    la3_0 = self.attr_input._la(1)
                    if (((la3_0).equal?(ENUM) || (la3_0).equal?(26) || (la3_0).equal?(28) || (la3_0 >= 31 && la3_0 <= 37) || (la3_0).equal?(46) || (la3_0).equal?(73)))
                      alt3 = 1
                    end
                  ensure
                    self.attr_dbg.exit_decision(3)
                  end
                  case (alt3)
                  when 1
                    self.attr_dbg.enter_alt(1)
                    # Java.g:0:0: typeDeclaration
                    self.attr_dbg.location(180, 41)
                    push_follow(FOLLOW_typeDeclaration_in_compilationUnit80)
                    type_declaration
                    self.attr_state.attr__fsp -= 1
                    if (self.attr_state.attr_failed)
                      return
                    end
                  else
                    break
                  end
                end while (true)
              ensure
                self.attr_dbg.exit_sub_rule(3)
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(4)
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:182:9: ( packageDeclaration )? ( importDeclaration )* ( typeDeclaration )*
          self.attr_dbg.location(182, 9)
          # Java.g:182:9: ( packageDeclaration )?
          alt5 = 2
          begin
            self.attr_dbg.enter_sub_rule(5)
            begin
              self.attr_dbg.enter_decision(5)
              la5_0 = self.attr_input._la(1)
              if (((la5_0).equal?(25)))
                alt5 = 1
              end
            ensure
              self.attr_dbg.exit_decision(5)
            end
            case (alt5)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: packageDeclaration
              self.attr_dbg.location(182, 9)
              push_follow(FOLLOW_packageDeclaration_in_compilationUnit101)
              package_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(5)
          end
          self.attr_dbg.location(182, 29)
          # Java.g:182:29: ( importDeclaration )*
          begin
            self.attr_dbg.enter_sub_rule(6)
            begin
              alt6 = 2
              begin
                self.attr_dbg.enter_decision(6)
                la6_0 = self.attr_input._la(1)
                if (((la6_0).equal?(27)))
                  alt6 = 1
                end
              ensure
                self.attr_dbg.exit_decision(6)
              end
              case (alt6)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:0:0: importDeclaration
                self.attr_dbg.location(182, 29)
                push_follow(FOLLOW_importDeclaration_in_compilationUnit104)
                import_declaration
                self.attr_state.attr__fsp -= 1
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(6)
          end
          self.attr_dbg.location(182, 48)
          # Java.g:182:48: ( typeDeclaration )*
          begin
            self.attr_dbg.enter_sub_rule(7)
            begin
              alt7 = 2
              begin
                self.attr_dbg.enter_decision(7)
                la7_0 = self.attr_input._la(1)
                if (((la7_0).equal?(ENUM) || (la7_0).equal?(26) || (la7_0).equal?(28) || (la7_0 >= 31 && la7_0 <= 37) || (la7_0).equal?(46) || (la7_0).equal?(73)))
                  alt7 = 1
                end
              ensure
                self.attr_dbg.exit_decision(7)
              end
              case (alt7)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:0:0: typeDeclaration
                self.attr_dbg.location(182, 48)
                push_follow(FOLLOW_typeDeclaration_in_compilationUnit107)
                type_declaration
                self.attr_state.attr__fsp -= 1
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(7)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 1, compilation_unit_start_index)
        end
      end
      self.attr_dbg.location(183, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "compilationUnit")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "compilationUnit"
  # $ANTLR start "packageDeclaration"
  # Java.g:185:1: packageDeclaration : 'package' qualifiedName ';' ;
  def package_declaration
    package_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "packageDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(185, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 2))
          return
        end
        # Java.g:186:5: ( 'package' qualifiedName ';' )
        self.attr_dbg.enter_alt(1)
        # Java.g:186:9: 'package' qualifiedName ';'
        self.attr_dbg.location(186, 9)
        match(self.attr_input, 25, FOLLOW_25_in_packageDeclaration127)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(186, 19)
        push_follow(FOLLOW_qualifiedName_in_packageDeclaration129)
        qualified_name
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(186, 33)
        match(self.attr_input, 26, FOLLOW_26_in_packageDeclaration131)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 2, package_declaration_start_index)
        end
      end
      self.attr_dbg.location(187, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "packageDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "packageDeclaration"
  # $ANTLR start "importDeclaration"
  # Java.g:189:1: importDeclaration : 'import' ( 'static' )? qualifiedName ( '.' '*' )? ';' ;
  def import_declaration
    import_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "importDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(189, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 3))
          return
        end
        # Java.g:190:5: ( 'import' ( 'static' )? qualifiedName ( '.' '*' )? ';' )
        self.attr_dbg.enter_alt(1)
        # Java.g:190:9: 'import' ( 'static' )? qualifiedName ( '.' '*' )? ';'
        self.attr_dbg.location(190, 9)
        match(self.attr_input, 27, FOLLOW_27_in_importDeclaration154)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(190, 18)
        # Java.g:190:18: ( 'static' )?
        alt9 = 2
        begin
          self.attr_dbg.enter_sub_rule(9)
          begin
            self.attr_dbg.enter_decision(9)
            la9_0 = self.attr_input._la(1)
            if (((la9_0).equal?(28)))
              alt9 = 1
            end
          ensure
            self.attr_dbg.exit_decision(9)
          end
          case (alt9)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: 'static'
            self.attr_dbg.location(190, 18)
            match(self.attr_input, 28, FOLLOW_28_in_importDeclaration156)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(9)
        end
        self.attr_dbg.location(190, 28)
        push_follow(FOLLOW_qualifiedName_in_importDeclaration159)
        qualified_name
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(190, 42)
        # Java.g:190:42: ( '.' '*' )?
        alt10 = 2
        begin
          self.attr_dbg.enter_sub_rule(10)
          begin
            self.attr_dbg.enter_decision(10)
            la10_0 = self.attr_input._la(1)
            if (((la10_0).equal?(29)))
              alt10 = 1
            end
          ensure
            self.attr_dbg.exit_decision(10)
          end
          case (alt10)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:190:43: '.' '*'
            self.attr_dbg.location(190, 43)
            match(self.attr_input, 29, FOLLOW_29_in_importDeclaration162)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(190, 47)
            match(self.attr_input, 30, FOLLOW_30_in_importDeclaration164)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(10)
        end
        self.attr_dbg.location(190, 53)
        match(self.attr_input, 26, FOLLOW_26_in_importDeclaration168)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 3, import_declaration_start_index)
        end
      end
      self.attr_dbg.location(191, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "importDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "importDeclaration"
  # $ANTLR start "typeDeclaration"
  # Java.g:193:1: typeDeclaration : ( classOrInterfaceDeclaration | ';' );
  def type_declaration
    type_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(193, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 4))
          return
        end
        # Java.g:194:5: ( classOrInterfaceDeclaration | ';' )
        alt11 = 2
        begin
          self.attr_dbg.enter_decision(11)
          la11_0 = self.attr_input._la(1)
          if (((la11_0).equal?(ENUM) || (la11_0).equal?(28) || (la11_0 >= 31 && la11_0 <= 37) || (la11_0).equal?(46) || (la11_0).equal?(73)))
            alt11 = 1
          else
            if (((la11_0).equal?(26)))
              alt11 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 11, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(11)
        end
        case (alt11)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:194:9: classOrInterfaceDeclaration
          self.attr_dbg.location(194, 9)
          push_follow(FOLLOW_classOrInterfaceDeclaration_in_typeDeclaration191)
          class_or_interface_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:195:9: ';'
          self.attr_dbg.location(195, 9)
          match(self.attr_input, 26, FOLLOW_26_in_typeDeclaration201)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 4, type_declaration_start_index)
        end
      end
      self.attr_dbg.location(196, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeDeclaration"
  # $ANTLR start "classOrInterfaceDeclaration"
  # Java.g:198:1: classOrInterfaceDeclaration : classOrInterfaceModifiers ( classDeclaration | interfaceDeclaration ) ;
  def class_or_interface_declaration
    class_or_interface_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classOrInterfaceDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(198, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 5))
          return
        end
        # Java.g:199:5: ( classOrInterfaceModifiers ( classDeclaration | interfaceDeclaration ) )
        self.attr_dbg.enter_alt(1)
        # Java.g:199:9: classOrInterfaceModifiers ( classDeclaration | interfaceDeclaration )
        self.attr_dbg.location(199, 9)
        push_follow(FOLLOW_classOrInterfaceModifiers_in_classOrInterfaceDeclaration224)
        class_or_interface_modifiers
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(199, 35)
        # Java.g:199:35: ( classDeclaration | interfaceDeclaration )
        alt12 = 2
        begin
          self.attr_dbg.enter_sub_rule(12)
          begin
            self.attr_dbg.enter_decision(12)
            la12_0 = self.attr_input._la(1)
            if (((la12_0).equal?(ENUM) || (la12_0).equal?(37)))
              alt12 = 1
            else
              if (((la12_0).equal?(46) || (la12_0).equal?(73)))
                alt12 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 12, 0, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          ensure
            self.attr_dbg.exit_decision(12)
          end
          case (alt12)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:199:36: classDeclaration
            self.attr_dbg.location(199, 36)
            push_follow(FOLLOW_classDeclaration_in_classOrInterfaceDeclaration227)
            class_declaration
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          when 2
            self.attr_dbg.enter_alt(2)
            # Java.g:199:55: interfaceDeclaration
            self.attr_dbg.location(199, 55)
            push_follow(FOLLOW_interfaceDeclaration_in_classOrInterfaceDeclaration231)
            interface_declaration
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(12)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 5, class_or_interface_declaration_start_index)
        end
      end
      self.attr_dbg.location(200, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classOrInterfaceDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classOrInterfaceDeclaration"
  # $ANTLR start "classOrInterfaceModifiers"
  # Java.g:202:1: classOrInterfaceModifiers : ( classOrInterfaceModifier )* ;
  def class_or_interface_modifiers
    class_or_interface_modifiers_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classOrInterfaceModifiers")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(202, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 6))
          return
        end
        # Java.g:203:5: ( ( classOrInterfaceModifier )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:203:9: ( classOrInterfaceModifier )*
        self.attr_dbg.location(203, 9)
        # Java.g:203:9: ( classOrInterfaceModifier )*
        begin
          self.attr_dbg.enter_sub_rule(13)
          begin
            alt13 = 2
            begin
              self.attr_dbg.enter_decision(13)
              la13_0 = self.attr_input._la(1)
              if (((la13_0).equal?(73)))
                la13_2 = self.attr_input._la(2)
                if (((la13_2).equal?(Identifier)))
                  alt13 = 1
                end
              else
                if (((la13_0).equal?(28) || (la13_0 >= 31 && la13_0 <= 36)))
                  alt13 = 1
                end
              end
            ensure
              self.attr_dbg.exit_decision(13)
            end
            case (alt13)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: classOrInterfaceModifier
              self.attr_dbg.location(203, 9)
              push_follow(FOLLOW_classOrInterfaceModifier_in_classOrInterfaceModifiers255)
              class_or_interface_modifier
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(13)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 6, class_or_interface_modifiers_start_index)
        end
      end
      self.attr_dbg.location(204, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classOrInterfaceModifiers")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classOrInterfaceModifiers"
  # $ANTLR start "classOrInterfaceModifier"
  # Java.g:206:1: classOrInterfaceModifier : ( annotation | 'public' | 'protected' | 'private' | 'abstract' | 'static' | 'final' | 'strictfp' );
  def class_or_interface_modifier
    class_or_interface_modifier_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classOrInterfaceModifier")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(206, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 7))
          return
        end
        # Java.g:207:5: ( annotation | 'public' | 'protected' | 'private' | 'abstract' | 'static' | 'final' | 'strictfp' )
        alt14 = 8
        begin
          self.attr_dbg.enter_decision(14)
          case (self.attr_input._la(1))
          when 73
            alt14 = 1
          when 31
            alt14 = 2
          when 32
            alt14 = 3
          when 33
            alt14 = 4
          when 34
            alt14 = 5
          when 28
            alt14 = 6
          when 35
            alt14 = 7
          when 36
            alt14 = 8
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 14, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(14)
        end
        case (alt14)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:207:9: annotation
          self.attr_dbg.location(207, 9)
          push_follow(FOLLOW_annotation_in_classOrInterfaceModifier275)
          annotation
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:208:9: 'public'
          self.attr_dbg.location(208, 9)
          match(self.attr_input, 31, FOLLOW_31_in_classOrInterfaceModifier288)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:209:9: 'protected'
          self.attr_dbg.location(209, 9)
          match(self.attr_input, 32, FOLLOW_32_in_classOrInterfaceModifier303)
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:210:9: 'private'
          self.attr_dbg.location(210, 9)
          match(self.attr_input, 33, FOLLOW_33_in_classOrInterfaceModifier315)
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:211:9: 'abstract'
          self.attr_dbg.location(211, 9)
          match(self.attr_input, 34, FOLLOW_34_in_classOrInterfaceModifier329)
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:212:9: 'static'
          self.attr_dbg.location(212, 9)
          match(self.attr_input, 28, FOLLOW_28_in_classOrInterfaceModifier342)
          if (self.attr_state.attr_failed)
            return
          end
        when 7
          self.attr_dbg.enter_alt(7)
          # Java.g:213:9: 'final'
          self.attr_dbg.location(213, 9)
          match(self.attr_input, 35, FOLLOW_35_in_classOrInterfaceModifier357)
          if (self.attr_state.attr_failed)
            return
          end
        when 8
          self.attr_dbg.enter_alt(8)
          # Java.g:214:9: 'strictfp'
          self.attr_dbg.location(214, 9)
          match(self.attr_input, 36, FOLLOW_36_in_classOrInterfaceModifier373)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 7, class_or_interface_modifier_start_index)
        end
      end
      self.attr_dbg.location(215, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classOrInterfaceModifier")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classOrInterfaceModifier"
  # $ANTLR start "modifiers"
  # Java.g:217:1: modifiers : ( modifier )* ;
  def modifiers
    modifiers_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "modifiers")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(217, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 8))
          return
        end
        # Java.g:218:5: ( ( modifier )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:218:9: ( modifier )*
        self.attr_dbg.location(218, 9)
        # Java.g:218:9: ( modifier )*
        begin
          self.attr_dbg.enter_sub_rule(15)
          begin
            alt15 = 2
            begin
              self.attr_dbg.enter_decision(15)
              la15_0 = self.attr_input._la(1)
              if (((la15_0).equal?(73)))
                la15_2 = self.attr_input._la(2)
                if (((la15_2).equal?(Identifier)))
                  alt15 = 1
                end
              else
                if (((la15_0).equal?(28) || (la15_0 >= 31 && la15_0 <= 36) || (la15_0 >= 52 && la15_0 <= 55)))
                  alt15 = 1
                end
              end
            ensure
              self.attr_dbg.exit_decision(15)
            end
            case (alt15)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: modifier
              self.attr_dbg.location(218, 9)
              push_follow(FOLLOW_modifier_in_modifiers395)
              modifier
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(15)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 8, modifiers_start_index)
        end
      end
      self.attr_dbg.location(219, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "modifiers")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "modifiers"
  # $ANTLR start "classDeclaration"
  # Java.g:221:1: classDeclaration : ( normalClassDeclaration | enumDeclaration );
  def class_declaration
    class_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(221, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 9))
          return
        end
        # Java.g:222:5: ( normalClassDeclaration | enumDeclaration )
        alt16 = 2
        begin
          self.attr_dbg.enter_decision(16)
          la16_0 = self.attr_input._la(1)
          if (((la16_0).equal?(37)))
            alt16 = 1
          else
            if (((la16_0).equal?(ENUM)))
              alt16 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 16, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(16)
        end
        case (alt16)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:222:9: normalClassDeclaration
          self.attr_dbg.location(222, 9)
          push_follow(FOLLOW_normalClassDeclaration_in_classDeclaration415)
          normal_class_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:223:9: enumDeclaration
          self.attr_dbg.location(223, 9)
          push_follow(FOLLOW_enumDeclaration_in_classDeclaration425)
          enum_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 9, class_declaration_start_index)
        end
      end
      self.attr_dbg.location(224, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classDeclaration"
  # $ANTLR start "normalClassDeclaration"
  # Java.g:226:1: normalClassDeclaration : 'class' Identifier ( typeParameters )? ( 'extends' type )? ( 'implements' typeList )? classBody ;
  def normal_class_declaration
    normal_class_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "normalClassDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(226, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 10))
          return
        end
        # Java.g:227:5: ( 'class' Identifier ( typeParameters )? ( 'extends' type )? ( 'implements' typeList )? classBody )
        self.attr_dbg.enter_alt(1)
        # Java.g:227:9: 'class' Identifier ( typeParameters )? ( 'extends' type )? ( 'implements' typeList )? classBody
        self.attr_dbg.location(227, 9)
        match(self.attr_input, 37, FOLLOW_37_in_normalClassDeclaration448)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(227, 17)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_normalClassDeclaration450)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(227, 28)
        # Java.g:227:28: ( typeParameters )?
        alt17 = 2
        begin
          self.attr_dbg.enter_sub_rule(17)
          begin
            self.attr_dbg.enter_decision(17)
            la17_0 = self.attr_input._la(1)
            if (((la17_0).equal?(40)))
              alt17 = 1
            end
          ensure
            self.attr_dbg.exit_decision(17)
          end
          case (alt17)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: typeParameters
            self.attr_dbg.location(227, 28)
            push_follow(FOLLOW_typeParameters_in_normalClassDeclaration452)
            type_parameters
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(17)
        end
        self.attr_dbg.location(228, 9)
        # Java.g:228:9: ( 'extends' type )?
        alt18 = 2
        begin
          self.attr_dbg.enter_sub_rule(18)
          begin
            self.attr_dbg.enter_decision(18)
            la18_0 = self.attr_input._la(1)
            if (((la18_0).equal?(38)))
              alt18 = 1
            end
          ensure
            self.attr_dbg.exit_decision(18)
          end
          case (alt18)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:228:10: 'extends' type
            self.attr_dbg.location(228, 10)
            match(self.attr_input, 38, FOLLOW_38_in_normalClassDeclaration464)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(228, 20)
            push_follow(FOLLOW_type_in_normalClassDeclaration466)
            type
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(18)
        end
        self.attr_dbg.location(229, 9)
        # Java.g:229:9: ( 'implements' typeList )?
        alt19 = 2
        begin
          self.attr_dbg.enter_sub_rule(19)
          begin
            self.attr_dbg.enter_decision(19)
            la19_0 = self.attr_input._la(1)
            if (((la19_0).equal?(39)))
              alt19 = 1
            end
          ensure
            self.attr_dbg.exit_decision(19)
          end
          case (alt19)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:229:10: 'implements' typeList
            self.attr_dbg.location(229, 10)
            match(self.attr_input, 39, FOLLOW_39_in_normalClassDeclaration479)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(229, 23)
            push_follow(FOLLOW_typeList_in_normalClassDeclaration481)
            type_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(19)
        end
        self.attr_dbg.location(230, 9)
        push_follow(FOLLOW_classBody_in_normalClassDeclaration493)
        class_body
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 10, normal_class_declaration_start_index)
        end
      end
      self.attr_dbg.location(231, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "normalClassDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "normalClassDeclaration"
  # $ANTLR start "typeParameters"
  # Java.g:233:1: typeParameters : '<' typeParameter ( ',' typeParameter )* '>' ;
  def type_parameters
    type_parameters_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeParameters")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(233, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 11))
          return
        end
        # Java.g:234:5: ( '<' typeParameter ( ',' typeParameter )* '>' )
        self.attr_dbg.enter_alt(1)
        # Java.g:234:9: '<' typeParameter ( ',' typeParameter )* '>'
        self.attr_dbg.location(234, 9)
        match(self.attr_input, 40, FOLLOW_40_in_typeParameters516)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(234, 13)
        push_follow(FOLLOW_typeParameter_in_typeParameters518)
        type_parameter
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(234, 27)
        # Java.g:234:27: ( ',' typeParameter )*
        begin
          self.attr_dbg.enter_sub_rule(20)
          begin
            alt20 = 2
            begin
              self.attr_dbg.enter_decision(20)
              la20_0 = self.attr_input._la(1)
              if (((la20_0).equal?(41)))
                alt20 = 1
              end
            ensure
              self.attr_dbg.exit_decision(20)
            end
            case (alt20)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:234:28: ',' typeParameter
              self.attr_dbg.location(234, 28)
              match(self.attr_input, 41, FOLLOW_41_in_typeParameters521)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(234, 32)
              push_follow(FOLLOW_typeParameter_in_typeParameters523)
              type_parameter
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(20)
        end
        self.attr_dbg.location(234, 48)
        match(self.attr_input, 42, FOLLOW_42_in_typeParameters527)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 11, type_parameters_start_index)
        end
      end
      self.attr_dbg.location(235, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeParameters")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeParameters"
  # $ANTLR start "typeParameter"
  # Java.g:237:1: typeParameter : Identifier ( 'extends' typeBound )? ;
  def type_parameter
    type_parameter_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeParameter")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(237, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 12))
          return
        end
        # Java.g:238:5: ( Identifier ( 'extends' typeBound )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:238:9: Identifier ( 'extends' typeBound )?
        self.attr_dbg.location(238, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_typeParameter546)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(238, 20)
        # Java.g:238:20: ( 'extends' typeBound )?
        alt21 = 2
        begin
          self.attr_dbg.enter_sub_rule(21)
          begin
            self.attr_dbg.enter_decision(21)
            la21_0 = self.attr_input._la(1)
            if (((la21_0).equal?(38)))
              alt21 = 1
            end
          ensure
            self.attr_dbg.exit_decision(21)
          end
          case (alt21)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:238:21: 'extends' typeBound
            self.attr_dbg.location(238, 21)
            match(self.attr_input, 38, FOLLOW_38_in_typeParameter549)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(238, 31)
            push_follow(FOLLOW_typeBound_in_typeParameter551)
            type_bound
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(21)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 12, type_parameter_start_index)
        end
      end
      self.attr_dbg.location(239, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeParameter")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeParameter"
  # $ANTLR start "typeBound"
  # Java.g:241:1: typeBound : type ( '&' type )* ;
  def type_bound
    type_bound_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeBound")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(241, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 13))
          return
        end
        # Java.g:242:5: ( type ( '&' type )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:242:9: type ( '&' type )*
        self.attr_dbg.location(242, 9)
        push_follow(FOLLOW_type_in_typeBound580)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(242, 14)
        # Java.g:242:14: ( '&' type )*
        begin
          self.attr_dbg.enter_sub_rule(22)
          begin
            alt22 = 2
            begin
              self.attr_dbg.enter_decision(22)
              la22_0 = self.attr_input._la(1)
              if (((la22_0).equal?(43)))
                alt22 = 1
              end
            ensure
              self.attr_dbg.exit_decision(22)
            end
            case (alt22)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:242:15: '&' type
              self.attr_dbg.location(242, 15)
              match(self.attr_input, 43, FOLLOW_43_in_typeBound583)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(242, 19)
              push_follow(FOLLOW_type_in_typeBound585)
              type
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(22)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 13, type_bound_start_index)
        end
      end
      self.attr_dbg.location(243, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeBound")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeBound"
  # $ANTLR start "enumDeclaration"
  # Java.g:245:1: enumDeclaration : ENUM Identifier ( 'implements' typeList )? enumBody ;
  def enum_declaration
    enum_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enumDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(245, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 14))
          return
        end
        # Java.g:246:5: ( ENUM Identifier ( 'implements' typeList )? enumBody )
        self.attr_dbg.enter_alt(1)
        # Java.g:246:9: ENUM Identifier ( 'implements' typeList )? enumBody
        self.attr_dbg.location(246, 9)
        match(self.attr_input, ENUM, FOLLOW_ENUM_in_enumDeclaration606)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(246, 14)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_enumDeclaration608)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(246, 25)
        # Java.g:246:25: ( 'implements' typeList )?
        alt23 = 2
        begin
          self.attr_dbg.enter_sub_rule(23)
          begin
            self.attr_dbg.enter_decision(23)
            la23_0 = self.attr_input._la(1)
            if (((la23_0).equal?(39)))
              alt23 = 1
            end
          ensure
            self.attr_dbg.exit_decision(23)
          end
          case (alt23)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:246:26: 'implements' typeList
            self.attr_dbg.location(246, 26)
            match(self.attr_input, 39, FOLLOW_39_in_enumDeclaration611)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(246, 39)
            push_follow(FOLLOW_typeList_in_enumDeclaration613)
            type_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(23)
        end
        self.attr_dbg.location(246, 50)
        push_follow(FOLLOW_enumBody_in_enumDeclaration617)
        enum_body
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 14, enum_declaration_start_index)
        end
      end
      self.attr_dbg.location(247, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enumDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enumDeclaration"
  # $ANTLR start "enumBody"
  # Java.g:249:1: enumBody : '{' ( enumConstants )? ( ',' )? ( enumBodyDeclarations )? '}' ;
  def enum_body
    enum_body_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enumBody")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(249, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 15))
          return
        end
        # Java.g:250:5: ( '{' ( enumConstants )? ( ',' )? ( enumBodyDeclarations )? '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:250:9: '{' ( enumConstants )? ( ',' )? ( enumBodyDeclarations )? '}'
        self.attr_dbg.location(250, 9)
        match(self.attr_input, 44, FOLLOW_44_in_enumBody636)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(250, 13)
        # Java.g:250:13: ( enumConstants )?
        alt24 = 2
        begin
          self.attr_dbg.enter_sub_rule(24)
          begin
            self.attr_dbg.enter_decision(24)
            la24_0 = self.attr_input._la(1)
            if (((la24_0).equal?(Identifier) || (la24_0).equal?(73)))
              alt24 = 1
            end
          ensure
            self.attr_dbg.exit_decision(24)
          end
          case (alt24)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: enumConstants
            self.attr_dbg.location(250, 13)
            push_follow(FOLLOW_enumConstants_in_enumBody638)
            enum_constants
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(24)
        end
        self.attr_dbg.location(250, 28)
        # Java.g:250:28: ( ',' )?
        alt25 = 2
        begin
          self.attr_dbg.enter_sub_rule(25)
          begin
            self.attr_dbg.enter_decision(25)
            la25_0 = self.attr_input._la(1)
            if (((la25_0).equal?(41)))
              alt25 = 1
            end
          ensure
            self.attr_dbg.exit_decision(25)
          end
          case (alt25)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: ','
            self.attr_dbg.location(250, 28)
            match(self.attr_input, 41, FOLLOW_41_in_enumBody641)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(25)
        end
        self.attr_dbg.location(250, 33)
        # Java.g:250:33: ( enumBodyDeclarations )?
        alt26 = 2
        begin
          self.attr_dbg.enter_sub_rule(26)
          begin
            self.attr_dbg.enter_decision(26)
            la26_0 = self.attr_input._la(1)
            if (((la26_0).equal?(26)))
              alt26 = 1
            end
          ensure
            self.attr_dbg.exit_decision(26)
          end
          case (alt26)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: enumBodyDeclarations
            self.attr_dbg.location(250, 33)
            push_follow(FOLLOW_enumBodyDeclarations_in_enumBody644)
            enum_body_declarations
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(26)
        end
        self.attr_dbg.location(250, 55)
        match(self.attr_input, 45, FOLLOW_45_in_enumBody647)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 15, enum_body_start_index)
        end
      end
      self.attr_dbg.location(251, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enumBody")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enumBody"
  # $ANTLR start "enumConstants"
  # Java.g:253:1: enumConstants : enumConstant ( ',' enumConstant )* ;
  def enum_constants
    enum_constants_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enumConstants")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(253, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 16))
          return
        end
        # Java.g:254:5: ( enumConstant ( ',' enumConstant )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:254:9: enumConstant ( ',' enumConstant )*
        self.attr_dbg.location(254, 9)
        push_follow(FOLLOW_enumConstant_in_enumConstants666)
        enum_constant
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(254, 22)
        # Java.g:254:22: ( ',' enumConstant )*
        begin
          self.attr_dbg.enter_sub_rule(27)
          begin
            alt27 = 2
            begin
              self.attr_dbg.enter_decision(27)
              la27_0 = self.attr_input._la(1)
              if (((la27_0).equal?(41)))
                la27_1 = self.attr_input._la(2)
                if (((la27_1).equal?(Identifier) || (la27_1).equal?(73)))
                  alt27 = 1
                end
              end
            ensure
              self.attr_dbg.exit_decision(27)
            end
            case (alt27)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:254:23: ',' enumConstant
              self.attr_dbg.location(254, 23)
              match(self.attr_input, 41, FOLLOW_41_in_enumConstants669)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(254, 27)
              push_follow(FOLLOW_enumConstant_in_enumConstants671)
              enum_constant
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(27)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 16, enum_constants_start_index)
        end
      end
      self.attr_dbg.location(255, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enumConstants")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enumConstants"
  # $ANTLR start "enumConstant"
  # Java.g:257:1: enumConstant : ( annotations )? Identifier ( arguments )? ( classBody )? ;
  def enum_constant
    enum_constant_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enumConstant")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(257, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 17))
          return
        end
        # Java.g:258:5: ( ( annotations )? Identifier ( arguments )? ( classBody )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:258:9: ( annotations )? Identifier ( arguments )? ( classBody )?
        self.attr_dbg.location(258, 9)
        # Java.g:258:9: ( annotations )?
        alt28 = 2
        begin
          self.attr_dbg.enter_sub_rule(28)
          begin
            self.attr_dbg.enter_decision(28)
            la28_0 = self.attr_input._la(1)
            if (((la28_0).equal?(73)))
              alt28 = 1
            end
          ensure
            self.attr_dbg.exit_decision(28)
          end
          case (alt28)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: annotations
            self.attr_dbg.location(258, 9)
            push_follow(FOLLOW_annotations_in_enumConstant696)
            annotations
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(28)
        end
        self.attr_dbg.location(258, 22)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_enumConstant699)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(258, 33)
        # Java.g:258:33: ( arguments )?
        alt29 = 2
        begin
          self.attr_dbg.enter_sub_rule(29)
          begin
            self.attr_dbg.enter_decision(29)
            la29_0 = self.attr_input._la(1)
            if (((la29_0).equal?(66)))
              alt29 = 1
            end
          ensure
            self.attr_dbg.exit_decision(29)
          end
          case (alt29)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: arguments
            self.attr_dbg.location(258, 33)
            push_follow(FOLLOW_arguments_in_enumConstant701)
            arguments
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(29)
        end
        self.attr_dbg.location(258, 44)
        # Java.g:258:44: ( classBody )?
        alt30 = 2
        begin
          self.attr_dbg.enter_sub_rule(30)
          begin
            self.attr_dbg.enter_decision(30)
            la30_0 = self.attr_input._la(1)
            if (((la30_0).equal?(44)))
              alt30 = 1
            end
          ensure
            self.attr_dbg.exit_decision(30)
          end
          case (alt30)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: classBody
            self.attr_dbg.location(258, 44)
            push_follow(FOLLOW_classBody_in_enumConstant704)
            class_body
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(30)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 17, enum_constant_start_index)
        end
      end
      self.attr_dbg.location(259, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enumConstant")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enumConstant"
  # $ANTLR start "enumBodyDeclarations"
  # Java.g:261:1: enumBodyDeclarations : ';' ( classBodyDeclaration )* ;
  def enum_body_declarations
    enum_body_declarations_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enumBodyDeclarations")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(261, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 18))
          return
        end
        # Java.g:262:5: ( ';' ( classBodyDeclaration )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:262:9: ';' ( classBodyDeclaration )*
        self.attr_dbg.location(262, 9)
        match(self.attr_input, 26, FOLLOW_26_in_enumBodyDeclarations728)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(262, 13)
        # Java.g:262:13: ( classBodyDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(31)
          begin
            alt31 = 2
            begin
              self.attr_dbg.enter_decision(31)
              la31_0 = self.attr_input._la(1)
              if (((la31_0 >= Identifier && la31_0 <= ENUM) || (la31_0).equal?(26) || (la31_0).equal?(28) || (la31_0 >= 31 && la31_0 <= 37) || (la31_0).equal?(40) || (la31_0).equal?(44) || (la31_0 >= 46 && la31_0 <= 47) || (la31_0 >= 52 && la31_0 <= 63) || (la31_0).equal?(73)))
                alt31 = 1
              end
            ensure
              self.attr_dbg.exit_decision(31)
            end
            case (alt31)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:262:14: classBodyDeclaration
              self.attr_dbg.location(262, 14)
              push_follow(FOLLOW_classBodyDeclaration_in_enumBodyDeclarations731)
              class_body_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(31)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 18, enum_body_declarations_start_index)
        end
      end
      self.attr_dbg.location(263, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enumBodyDeclarations")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enumBodyDeclarations"
  # $ANTLR start "interfaceDeclaration"
  # Java.g:265:1: interfaceDeclaration : ( normalInterfaceDeclaration | annotationTypeDeclaration );
  def interface_declaration
    interface_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(265, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 19))
          return
        end
        # Java.g:266:5: ( normalInterfaceDeclaration | annotationTypeDeclaration )
        alt32 = 2
        begin
          self.attr_dbg.enter_decision(32)
          la32_0 = self.attr_input._la(1)
          if (((la32_0).equal?(46)))
            alt32 = 1
          else
            if (((la32_0).equal?(73)))
              alt32 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 32, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(32)
        end
        case (alt32)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:266:9: normalInterfaceDeclaration
          self.attr_dbg.location(266, 9)
          push_follow(FOLLOW_normalInterfaceDeclaration_in_interfaceDeclaration756)
          normal_interface_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:267:9: annotationTypeDeclaration
          self.attr_dbg.location(267, 9)
          push_follow(FOLLOW_annotationTypeDeclaration_in_interfaceDeclaration766)
          annotation_type_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 19, interface_declaration_start_index)
        end
      end
      self.attr_dbg.location(268, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceDeclaration"
  # $ANTLR start "normalInterfaceDeclaration"
  # Java.g:270:1: normalInterfaceDeclaration : 'interface' Identifier ( typeParameters )? ( 'extends' typeList )? interfaceBody ;
  def normal_interface_declaration
    normal_interface_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "normalInterfaceDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(270, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 20))
          return
        end
        # Java.g:271:5: ( 'interface' Identifier ( typeParameters )? ( 'extends' typeList )? interfaceBody )
        self.attr_dbg.enter_alt(1)
        # Java.g:271:9: 'interface' Identifier ( typeParameters )? ( 'extends' typeList )? interfaceBody
        self.attr_dbg.location(271, 9)
        match(self.attr_input, 46, FOLLOW_46_in_normalInterfaceDeclaration789)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(271, 21)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_normalInterfaceDeclaration791)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(271, 32)
        # Java.g:271:32: ( typeParameters )?
        alt33 = 2
        begin
          self.attr_dbg.enter_sub_rule(33)
          begin
            self.attr_dbg.enter_decision(33)
            la33_0 = self.attr_input._la(1)
            if (((la33_0).equal?(40)))
              alt33 = 1
            end
          ensure
            self.attr_dbg.exit_decision(33)
          end
          case (alt33)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: typeParameters
            self.attr_dbg.location(271, 32)
            push_follow(FOLLOW_typeParameters_in_normalInterfaceDeclaration793)
            type_parameters
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(33)
        end
        self.attr_dbg.location(271, 48)
        # Java.g:271:48: ( 'extends' typeList )?
        alt34 = 2
        begin
          self.attr_dbg.enter_sub_rule(34)
          begin
            self.attr_dbg.enter_decision(34)
            la34_0 = self.attr_input._la(1)
            if (((la34_0).equal?(38)))
              alt34 = 1
            end
          ensure
            self.attr_dbg.exit_decision(34)
          end
          case (alt34)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:271:49: 'extends' typeList
            self.attr_dbg.location(271, 49)
            match(self.attr_input, 38, FOLLOW_38_in_normalInterfaceDeclaration797)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(271, 59)
            push_follow(FOLLOW_typeList_in_normalInterfaceDeclaration799)
            type_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(34)
        end
        self.attr_dbg.location(271, 70)
        push_follow(FOLLOW_interfaceBody_in_normalInterfaceDeclaration803)
        interface_body
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 20, normal_interface_declaration_start_index)
        end
      end
      self.attr_dbg.location(272, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "normalInterfaceDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "normalInterfaceDeclaration"
  # $ANTLR start "typeList"
  # Java.g:274:1: typeList : type ( ',' type )* ;
  def type_list
    type_list_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeList")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(274, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 21))
          return
        end
        # Java.g:275:5: ( type ( ',' type )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:275:9: type ( ',' type )*
        self.attr_dbg.location(275, 9)
        push_follow(FOLLOW_type_in_typeList826)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(275, 14)
        # Java.g:275:14: ( ',' type )*
        begin
          self.attr_dbg.enter_sub_rule(35)
          begin
            alt35 = 2
            begin
              self.attr_dbg.enter_decision(35)
              la35_0 = self.attr_input._la(1)
              if (((la35_0).equal?(41)))
                alt35 = 1
              end
            ensure
              self.attr_dbg.exit_decision(35)
            end
            case (alt35)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:275:15: ',' type
              self.attr_dbg.location(275, 15)
              match(self.attr_input, 41, FOLLOW_41_in_typeList829)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(275, 19)
              push_follow(FOLLOW_type_in_typeList831)
              type
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(35)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 21, type_list_start_index)
        end
      end
      self.attr_dbg.location(276, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeList")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeList"
  # $ANTLR start "classBody"
  # Java.g:278:1: classBody : '{' ( classBodyDeclaration )* '}' ;
  def class_body
    class_body_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classBody")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(278, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 22))
          return
        end
        # Java.g:279:5: ( '{' ( classBodyDeclaration )* '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:279:9: '{' ( classBodyDeclaration )* '}'
        self.attr_dbg.location(279, 9)
        match(self.attr_input, 44, FOLLOW_44_in_classBody856)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(279, 13)
        # Java.g:279:13: ( classBodyDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(36)
          begin
            alt36 = 2
            begin
              self.attr_dbg.enter_decision(36)
              la36_0 = self.attr_input._la(1)
              if (((la36_0 >= Identifier && la36_0 <= ENUM) || (la36_0).equal?(26) || (la36_0).equal?(28) || (la36_0 >= 31 && la36_0 <= 37) || (la36_0).equal?(40) || (la36_0).equal?(44) || (la36_0 >= 46 && la36_0 <= 47) || (la36_0 >= 52 && la36_0 <= 63) || (la36_0).equal?(73)))
                alt36 = 1
              end
            ensure
              self.attr_dbg.exit_decision(36)
            end
            case (alt36)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: classBodyDeclaration
              self.attr_dbg.location(279, 13)
              push_follow(FOLLOW_classBodyDeclaration_in_classBody858)
              class_body_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(36)
        end
        self.attr_dbg.location(279, 35)
        match(self.attr_input, 45, FOLLOW_45_in_classBody861)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 22, class_body_start_index)
        end
      end
      self.attr_dbg.location(280, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classBody")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classBody"
  # $ANTLR start "interfaceBody"
  # Java.g:282:1: interfaceBody : '{' ( interfaceBodyDeclaration )* '}' ;
  def interface_body
    interface_body_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceBody")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(282, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 23))
          return
        end
        # Java.g:283:5: ( '{' ( interfaceBodyDeclaration )* '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:283:9: '{' ( interfaceBodyDeclaration )* '}'
        self.attr_dbg.location(283, 9)
        match(self.attr_input, 44, FOLLOW_44_in_interfaceBody884)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(283, 13)
        # Java.g:283:13: ( interfaceBodyDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(37)
          begin
            alt37 = 2
            begin
              self.attr_dbg.enter_decision(37)
              la37_0 = self.attr_input._la(1)
              if (((la37_0 >= Identifier && la37_0 <= ENUM) || (la37_0).equal?(26) || (la37_0).equal?(28) || (la37_0 >= 31 && la37_0 <= 37) || (la37_0).equal?(40) || (la37_0 >= 46 && la37_0 <= 47) || (la37_0 >= 52 && la37_0 <= 63) || (la37_0).equal?(73)))
                alt37 = 1
              end
            ensure
              self.attr_dbg.exit_decision(37)
            end
            case (alt37)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: interfaceBodyDeclaration
              self.attr_dbg.location(283, 13)
              push_follow(FOLLOW_interfaceBodyDeclaration_in_interfaceBody886)
              interface_body_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(37)
        end
        self.attr_dbg.location(283, 39)
        match(self.attr_input, 45, FOLLOW_45_in_interfaceBody889)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 23, interface_body_start_index)
        end
      end
      self.attr_dbg.location(284, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceBody")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceBody"
  # $ANTLR start "classBodyDeclaration"
  # Java.g:286:1: classBodyDeclaration : ( ';' | ( 'static' )? block | modifiers memberDecl );
  def class_body_declaration
    class_body_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classBodyDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(286, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 24))
          return
        end
        # Java.g:287:5: ( ';' | ( 'static' )? block | modifiers memberDecl )
        alt39 = 3
        begin
          self.attr_dbg.enter_decision(39)
          case (self.attr_input._la(1))
          when 26
            alt39 = 1
          when 28
            la39_2 = self.attr_input._la(2)
            if (((la39_2 >= Identifier && la39_2 <= ENUM) || (la39_2).equal?(28) || (la39_2 >= 31 && la39_2 <= 37) || (la39_2).equal?(40) || (la39_2 >= 46 && la39_2 <= 47) || (la39_2 >= 52 && la39_2 <= 63) || (la39_2).equal?(73)))
              alt39 = 3
            else
              if (((la39_2).equal?(44)))
                alt39 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 39, 2, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          when 44
            alt39 = 2
          when Identifier, ENUM, 31, 32, 33, 34, 35, 36, 37, 40, 46, 47, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 73
            alt39 = 3
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 39, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(39)
        end
        case (alt39)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:287:9: ';'
          self.attr_dbg.location(287, 9)
          match(self.attr_input, 26, FOLLOW_26_in_classBodyDeclaration908)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:288:9: ( 'static' )? block
          self.attr_dbg.location(288, 9)
          # Java.g:288:9: ( 'static' )?
          alt38 = 2
          begin
            self.attr_dbg.enter_sub_rule(38)
            begin
              self.attr_dbg.enter_decision(38)
              la38_0 = self.attr_input._la(1)
              if (((la38_0).equal?(28)))
                alt38 = 1
              end
            ensure
              self.attr_dbg.exit_decision(38)
            end
            case (alt38)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: 'static'
              self.attr_dbg.location(288, 9)
              match(self.attr_input, 28, FOLLOW_28_in_classBodyDeclaration918)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(38)
          end
          self.attr_dbg.location(288, 19)
          push_follow(FOLLOW_block_in_classBodyDeclaration921)
          block
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:289:9: modifiers memberDecl
          self.attr_dbg.location(289, 9)
          push_follow(FOLLOW_modifiers_in_classBodyDeclaration931)
          modifiers
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(289, 19)
          push_follow(FOLLOW_memberDecl_in_classBodyDeclaration933)
          member_decl
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 24, class_body_declaration_start_index)
        end
      end
      self.attr_dbg.location(290, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classBodyDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classBodyDeclaration"
  # $ANTLR start "memberDecl"
  # Java.g:292:1: memberDecl : ( genericMethodOrConstructorDecl | memberDeclaration | 'void' Identifier voidMethodDeclaratorRest | Identifier constructorDeclaratorRest | interfaceDeclaration | classDeclaration );
  def member_decl
    member_decl_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "memberDecl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(292, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 25))
          return
        end
        # Java.g:293:5: ( genericMethodOrConstructorDecl | memberDeclaration | 'void' Identifier voidMethodDeclaratorRest | Identifier constructorDeclaratorRest | interfaceDeclaration | classDeclaration )
        alt40 = 6
        begin
          self.attr_dbg.enter_decision(40)
          case (self.attr_input._la(1))
          when 40
            alt40 = 1
          when Identifier
            la40_2 = self.attr_input._la(2)
            if (((la40_2).equal?(66)))
              alt40 = 4
            else
              if (((la40_2).equal?(Identifier) || (la40_2).equal?(29) || (la40_2).equal?(40) || (la40_2).equal?(48)))
                alt40 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 40, 2, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          when 56, 57, 58, 59, 60, 61, 62, 63
            alt40 = 2
          when 47
            alt40 = 3
          when 46, 73
            alt40 = 5
          when ENUM, 37
            alt40 = 6
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 40, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(40)
        end
        case (alt40)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:293:9: genericMethodOrConstructorDecl
          self.attr_dbg.location(293, 9)
          push_follow(FOLLOW_genericMethodOrConstructorDecl_in_memberDecl956)
          generic_method_or_constructor_decl
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:294:9: memberDeclaration
          self.attr_dbg.location(294, 9)
          push_follow(FOLLOW_memberDeclaration_in_memberDecl966)
          member_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:295:9: 'void' Identifier voidMethodDeclaratorRest
          self.attr_dbg.location(295, 9)
          match(self.attr_input, 47, FOLLOW_47_in_memberDecl976)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(295, 16)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_memberDecl978)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(295, 27)
          push_follow(FOLLOW_voidMethodDeclaratorRest_in_memberDecl980)
          void_method_declarator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:296:9: Identifier constructorDeclaratorRest
          self.attr_dbg.location(296, 9)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_memberDecl990)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(296, 20)
          push_follow(FOLLOW_constructorDeclaratorRest_in_memberDecl992)
          constructor_declarator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:297:9: interfaceDeclaration
          self.attr_dbg.location(297, 9)
          push_follow(FOLLOW_interfaceDeclaration_in_memberDecl1002)
          interface_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:298:9: classDeclaration
          self.attr_dbg.location(298, 9)
          push_follow(FOLLOW_classDeclaration_in_memberDecl1012)
          class_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 25, member_decl_start_index)
        end
      end
      self.attr_dbg.location(299, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "memberDecl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "memberDecl"
  # $ANTLR start "memberDeclaration"
  # Java.g:301:1: memberDeclaration : type ( methodDeclaration | fieldDeclaration ) ;
  def member_declaration
    member_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "memberDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(301, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 26))
          return
        end
        # Java.g:302:5: ( type ( methodDeclaration | fieldDeclaration ) )
        self.attr_dbg.enter_alt(1)
        # Java.g:302:9: type ( methodDeclaration | fieldDeclaration )
        self.attr_dbg.location(302, 9)
        push_follow(FOLLOW_type_in_memberDeclaration1035)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(302, 14)
        # Java.g:302:14: ( methodDeclaration | fieldDeclaration )
        alt41 = 2
        begin
          self.attr_dbg.enter_sub_rule(41)
          begin
            self.attr_dbg.enter_decision(41)
            la41_0 = self.attr_input._la(1)
            if (((la41_0).equal?(Identifier)))
              la41_1 = self.attr_input._la(2)
              if (((la41_1).equal?(66)))
                alt41 = 1
              else
                if (((la41_1).equal?(26) || (la41_1).equal?(41) || (la41_1).equal?(48) || (la41_1).equal?(51)))
                  alt41 = 2
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 41, 1, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 41, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          ensure
            self.attr_dbg.exit_decision(41)
          end
          case (alt41)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:302:15: methodDeclaration
            self.attr_dbg.location(302, 15)
            push_follow(FOLLOW_methodDeclaration_in_memberDeclaration1038)
            method_declaration
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          when 2
            self.attr_dbg.enter_alt(2)
            # Java.g:302:35: fieldDeclaration
            self.attr_dbg.location(302, 35)
            push_follow(FOLLOW_fieldDeclaration_in_memberDeclaration1042)
            field_declaration
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(41)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 26, member_declaration_start_index)
        end
      end
      self.attr_dbg.location(303, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "memberDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "memberDeclaration"
  # $ANTLR start "genericMethodOrConstructorDecl"
  # Java.g:305:1: genericMethodOrConstructorDecl : typeParameters genericMethodOrConstructorRest ;
  def generic_method_or_constructor_decl
    generic_method_or_constructor_decl_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "genericMethodOrConstructorDecl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(305, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 27))
          return
        end
        # Java.g:306:5: ( typeParameters genericMethodOrConstructorRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:306:9: typeParameters genericMethodOrConstructorRest
        self.attr_dbg.location(306, 9)
        push_follow(FOLLOW_typeParameters_in_genericMethodOrConstructorDecl1062)
        type_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(306, 24)
        push_follow(FOLLOW_genericMethodOrConstructorRest_in_genericMethodOrConstructorDecl1064)
        generic_method_or_constructor_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 27, generic_method_or_constructor_decl_start_index)
        end
      end
      self.attr_dbg.location(307, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "genericMethodOrConstructorDecl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "genericMethodOrConstructorDecl"
  # $ANTLR start "genericMethodOrConstructorRest"
  # Java.g:309:1: genericMethodOrConstructorRest : ( ( type | 'void' ) Identifier methodDeclaratorRest | Identifier constructorDeclaratorRest );
  def generic_method_or_constructor_rest
    generic_method_or_constructor_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "genericMethodOrConstructorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(309, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 28))
          return
        end
        # Java.g:310:5: ( ( type | 'void' ) Identifier methodDeclaratorRest | Identifier constructorDeclaratorRest )
        alt43 = 2
        begin
          self.attr_dbg.enter_decision(43)
          la43_0 = self.attr_input._la(1)
          if (((la43_0).equal?(Identifier)))
            la43_1 = self.attr_input._la(2)
            if (((la43_1).equal?(Identifier) || (la43_1).equal?(29) || (la43_1).equal?(40) || (la43_1).equal?(48)))
              alt43 = 1
            else
              if (((la43_1).equal?(66)))
                alt43 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 43, 1, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          else
            if (((la43_0).equal?(47) || (la43_0 >= 56 && la43_0 <= 63)))
              alt43 = 1
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 43, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(43)
        end
        case (alt43)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:310:9: ( type | 'void' ) Identifier methodDeclaratorRest
          self.attr_dbg.location(310, 9)
          # Java.g:310:9: ( type | 'void' )
          alt42 = 2
          begin
            self.attr_dbg.enter_sub_rule(42)
            begin
              self.attr_dbg.enter_decision(42)
              la42_0 = self.attr_input._la(1)
              if (((la42_0).equal?(Identifier) || (la42_0 >= 56 && la42_0 <= 63)))
                alt42 = 1
              else
                if (((la42_0).equal?(47)))
                  alt42 = 2
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 42, 0, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            ensure
              self.attr_dbg.exit_decision(42)
            end
            case (alt42)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:310:10: type
              self.attr_dbg.location(310, 10)
              push_follow(FOLLOW_type_in_genericMethodOrConstructorRest1088)
              type
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            when 2
              self.attr_dbg.enter_alt(2)
              # Java.g:310:17: 'void'
              self.attr_dbg.location(310, 17)
              match(self.attr_input, 47, FOLLOW_47_in_genericMethodOrConstructorRest1092)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(42)
          end
          self.attr_dbg.location(310, 25)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_genericMethodOrConstructorRest1095)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(310, 36)
          push_follow(FOLLOW_methodDeclaratorRest_in_genericMethodOrConstructorRest1097)
          method_declarator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:311:9: Identifier constructorDeclaratorRest
          self.attr_dbg.location(311, 9)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_genericMethodOrConstructorRest1107)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(311, 20)
          push_follow(FOLLOW_constructorDeclaratorRest_in_genericMethodOrConstructorRest1109)
          constructor_declarator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 28, generic_method_or_constructor_rest_start_index)
        end
      end
      self.attr_dbg.location(312, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "genericMethodOrConstructorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "genericMethodOrConstructorRest"
  # $ANTLR start "methodDeclaration"
  # Java.g:314:1: methodDeclaration : Identifier methodDeclaratorRest ;
  def method_declaration
    method_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "methodDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(314, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 29))
          return
        end
        # Java.g:315:5: ( Identifier methodDeclaratorRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:315:9: Identifier methodDeclaratorRest
        self.attr_dbg.location(315, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_methodDeclaration1128)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(315, 20)
        push_follow(FOLLOW_methodDeclaratorRest_in_methodDeclaration1130)
        method_declarator_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 29, method_declaration_start_index)
        end
      end
      self.attr_dbg.location(316, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "methodDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "methodDeclaration"
  # $ANTLR start "fieldDeclaration"
  # Java.g:318:1: fieldDeclaration : variableDeclarators ';' ;
  def field_declaration
    field_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "fieldDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(318, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 30))
          return
        end
        # Java.g:319:5: ( variableDeclarators ';' )
        self.attr_dbg.enter_alt(1)
        # Java.g:319:9: variableDeclarators ';'
        self.attr_dbg.location(319, 9)
        push_follow(FOLLOW_variableDeclarators_in_fieldDeclaration1149)
        variable_declarators
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(319, 29)
        match(self.attr_input, 26, FOLLOW_26_in_fieldDeclaration1151)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 30, field_declaration_start_index)
        end
      end
      self.attr_dbg.location(320, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "fieldDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "fieldDeclaration"
  # $ANTLR start "interfaceBodyDeclaration"
  # Java.g:322:1: interfaceBodyDeclaration : ( modifiers interfaceMemberDecl | ';' );
  def interface_body_declaration
    interface_body_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceBodyDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(322, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 31))
          return
        end
        # Java.g:323:5: ( modifiers interfaceMemberDecl | ';' )
        alt44 = 2
        begin
          self.attr_dbg.enter_decision(44)
          la44_0 = self.attr_input._la(1)
          if (((la44_0 >= Identifier && la44_0 <= ENUM) || (la44_0).equal?(28) || (la44_0 >= 31 && la44_0 <= 37) || (la44_0).equal?(40) || (la44_0 >= 46 && la44_0 <= 47) || (la44_0 >= 52 && la44_0 <= 63) || (la44_0).equal?(73)))
            alt44 = 1
          else
            if (((la44_0).equal?(26)))
              alt44 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 44, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(44)
        end
        case (alt44)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:323:9: modifiers interfaceMemberDecl
          self.attr_dbg.location(323, 9)
          push_follow(FOLLOW_modifiers_in_interfaceBodyDeclaration1178)
          modifiers
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(323, 19)
          push_follow(FOLLOW_interfaceMemberDecl_in_interfaceBodyDeclaration1180)
          interface_member_decl
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:324:9: ';'
          self.attr_dbg.location(324, 9)
          match(self.attr_input, 26, FOLLOW_26_in_interfaceBodyDeclaration1190)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 31, interface_body_declaration_start_index)
        end
      end
      self.attr_dbg.location(325, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceBodyDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceBodyDeclaration"
  # $ANTLR start "interfaceMemberDecl"
  # Java.g:327:1: interfaceMemberDecl : ( interfaceMethodOrFieldDecl | interfaceGenericMethodDecl | 'void' Identifier voidInterfaceMethodDeclaratorRest | interfaceDeclaration | classDeclaration );
  def interface_member_decl
    interface_member_decl_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceMemberDecl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(327, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 32))
          return
        end
        # Java.g:328:5: ( interfaceMethodOrFieldDecl | interfaceGenericMethodDecl | 'void' Identifier voidInterfaceMethodDeclaratorRest | interfaceDeclaration | classDeclaration )
        alt45 = 5
        begin
          self.attr_dbg.enter_decision(45)
          case (self.attr_input._la(1))
          when Identifier, 56, 57, 58, 59, 60, 61, 62, 63
            alt45 = 1
          when 40
            alt45 = 2
          when 47
            alt45 = 3
          when 46, 73
            alt45 = 4
          when ENUM, 37
            alt45 = 5
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 45, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(45)
        end
        case (alt45)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:328:9: interfaceMethodOrFieldDecl
          self.attr_dbg.location(328, 9)
          push_follow(FOLLOW_interfaceMethodOrFieldDecl_in_interfaceMemberDecl1209)
          interface_method_or_field_decl
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:329:9: interfaceGenericMethodDecl
          self.attr_dbg.location(329, 9)
          push_follow(FOLLOW_interfaceGenericMethodDecl_in_interfaceMemberDecl1219)
          interface_generic_method_decl
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:330:9: 'void' Identifier voidInterfaceMethodDeclaratorRest
          self.attr_dbg.location(330, 9)
          match(self.attr_input, 47, FOLLOW_47_in_interfaceMemberDecl1229)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(330, 16)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_interfaceMemberDecl1231)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(330, 27)
          push_follow(FOLLOW_voidInterfaceMethodDeclaratorRest_in_interfaceMemberDecl1233)
          void_interface_method_declarator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:331:9: interfaceDeclaration
          self.attr_dbg.location(331, 9)
          push_follow(FOLLOW_interfaceDeclaration_in_interfaceMemberDecl1243)
          interface_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:332:9: classDeclaration
          self.attr_dbg.location(332, 9)
          push_follow(FOLLOW_classDeclaration_in_interfaceMemberDecl1253)
          class_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 32, interface_member_decl_start_index)
        end
      end
      self.attr_dbg.location(333, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceMemberDecl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceMemberDecl"
  # $ANTLR start "interfaceMethodOrFieldDecl"
  # Java.g:335:1: interfaceMethodOrFieldDecl : type Identifier interfaceMethodOrFieldRest ;
  def interface_method_or_field_decl
    interface_method_or_field_decl_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceMethodOrFieldDecl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(335, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 33))
          return
        end
        # Java.g:336:5: ( type Identifier interfaceMethodOrFieldRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:336:9: type Identifier interfaceMethodOrFieldRest
        self.attr_dbg.location(336, 9)
        push_follow(FOLLOW_type_in_interfaceMethodOrFieldDecl1276)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(336, 14)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_interfaceMethodOrFieldDecl1278)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(336, 25)
        push_follow(FOLLOW_interfaceMethodOrFieldRest_in_interfaceMethodOrFieldDecl1280)
        interface_method_or_field_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 33, interface_method_or_field_decl_start_index)
        end
      end
      self.attr_dbg.location(337, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceMethodOrFieldDecl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceMethodOrFieldDecl"
  # $ANTLR start "interfaceMethodOrFieldRest"
  # Java.g:339:1: interfaceMethodOrFieldRest : ( constantDeclaratorsRest ';' | interfaceMethodDeclaratorRest );
  def interface_method_or_field_rest
    interface_method_or_field_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceMethodOrFieldRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(339, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 34))
          return
        end
        # Java.g:340:5: ( constantDeclaratorsRest ';' | interfaceMethodDeclaratorRest )
        alt46 = 2
        begin
          self.attr_dbg.enter_decision(46)
          la46_0 = self.attr_input._la(1)
          if (((la46_0).equal?(48) || (la46_0).equal?(51)))
            alt46 = 1
          else
            if (((la46_0).equal?(66)))
              alt46 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 46, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(46)
        end
        case (alt46)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:340:9: constantDeclaratorsRest ';'
          self.attr_dbg.location(340, 9)
          push_follow(FOLLOW_constantDeclaratorsRest_in_interfaceMethodOrFieldRest1303)
          constant_declarators_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(340, 33)
          match(self.attr_input, 26, FOLLOW_26_in_interfaceMethodOrFieldRest1305)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:341:9: interfaceMethodDeclaratorRest
          self.attr_dbg.location(341, 9)
          push_follow(FOLLOW_interfaceMethodDeclaratorRest_in_interfaceMethodOrFieldRest1315)
          interface_method_declarator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 34, interface_method_or_field_rest_start_index)
        end
      end
      self.attr_dbg.location(342, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceMethodOrFieldRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceMethodOrFieldRest"
  # $ANTLR start "methodDeclaratorRest"
  # Java.g:344:1: methodDeclaratorRest : formalParameters ( '[' ']' )* ( 'throws' qualifiedNameList )? ( methodBody | ';' ) ;
  def method_declarator_rest
    method_declarator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "methodDeclaratorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(344, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 35))
          return
        end
        # Java.g:345:5: ( formalParameters ( '[' ']' )* ( 'throws' qualifiedNameList )? ( methodBody | ';' ) )
        self.attr_dbg.enter_alt(1)
        # Java.g:345:9: formalParameters ( '[' ']' )* ( 'throws' qualifiedNameList )? ( methodBody | ';' )
        self.attr_dbg.location(345, 9)
        push_follow(FOLLOW_formalParameters_in_methodDeclaratorRest1338)
        formal_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(345, 26)
        # Java.g:345:26: ( '[' ']' )*
        begin
          self.attr_dbg.enter_sub_rule(47)
          begin
            alt47 = 2
            begin
              self.attr_dbg.enter_decision(47)
              la47_0 = self.attr_input._la(1)
              if (((la47_0).equal?(48)))
                alt47 = 1
              end
            ensure
              self.attr_dbg.exit_decision(47)
            end
            case (alt47)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:345:27: '[' ']'
              self.attr_dbg.location(345, 27)
              match(self.attr_input, 48, FOLLOW_48_in_methodDeclaratorRest1341)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(345, 31)
              match(self.attr_input, 49, FOLLOW_49_in_methodDeclaratorRest1343)
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(47)
        end
        self.attr_dbg.location(346, 9)
        # Java.g:346:9: ( 'throws' qualifiedNameList )?
        alt48 = 2
        begin
          self.attr_dbg.enter_sub_rule(48)
          begin
            self.attr_dbg.enter_decision(48)
            la48_0 = self.attr_input._la(1)
            if (((la48_0).equal?(50)))
              alt48 = 1
            end
          ensure
            self.attr_dbg.exit_decision(48)
          end
          case (alt48)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:346:10: 'throws' qualifiedNameList
            self.attr_dbg.location(346, 10)
            match(self.attr_input, 50, FOLLOW_50_in_methodDeclaratorRest1356)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(346, 19)
            push_follow(FOLLOW_qualifiedNameList_in_methodDeclaratorRest1358)
            qualified_name_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(48)
        end
        self.attr_dbg.location(347, 9)
        # Java.g:347:9: ( methodBody | ';' )
        alt49 = 2
        begin
          self.attr_dbg.enter_sub_rule(49)
          begin
            self.attr_dbg.enter_decision(49)
            la49_0 = self.attr_input._la(1)
            if (((la49_0).equal?(44)))
              alt49 = 1
            else
              if (((la49_0).equal?(26)))
                alt49 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 49, 0, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          ensure
            self.attr_dbg.exit_decision(49)
          end
          case (alt49)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:347:13: methodBody
            self.attr_dbg.location(347, 13)
            push_follow(FOLLOW_methodBody_in_methodDeclaratorRest1374)
            method_body
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          when 2
            self.attr_dbg.enter_alt(2)
            # Java.g:348:13: ';'
            self.attr_dbg.location(348, 13)
            match(self.attr_input, 26, FOLLOW_26_in_methodDeclaratorRest1388)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(49)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 35, method_declarator_rest_start_index)
        end
      end
      self.attr_dbg.location(350, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "methodDeclaratorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "methodDeclaratorRest"
  # $ANTLR start "voidMethodDeclaratorRest"
  # Java.g:352:1: voidMethodDeclaratorRest : formalParameters ( 'throws' qualifiedNameList )? ( methodBody | ';' ) ;
  def void_method_declarator_rest
    void_method_declarator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "voidMethodDeclaratorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(352, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 36))
          return
        end
        # Java.g:353:5: ( formalParameters ( 'throws' qualifiedNameList )? ( methodBody | ';' ) )
        self.attr_dbg.enter_alt(1)
        # Java.g:353:9: formalParameters ( 'throws' qualifiedNameList )? ( methodBody | ';' )
        self.attr_dbg.location(353, 9)
        push_follow(FOLLOW_formalParameters_in_voidMethodDeclaratorRest1421)
        formal_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(353, 26)
        # Java.g:353:26: ( 'throws' qualifiedNameList )?
        alt50 = 2
        begin
          self.attr_dbg.enter_sub_rule(50)
          begin
            self.attr_dbg.enter_decision(50)
            la50_0 = self.attr_input._la(1)
            if (((la50_0).equal?(50)))
              alt50 = 1
            end
          ensure
            self.attr_dbg.exit_decision(50)
          end
          case (alt50)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:353:27: 'throws' qualifiedNameList
            self.attr_dbg.location(353, 27)
            match(self.attr_input, 50, FOLLOW_50_in_voidMethodDeclaratorRest1424)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(353, 36)
            push_follow(FOLLOW_qualifiedNameList_in_voidMethodDeclaratorRest1426)
            qualified_name_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(50)
        end
        self.attr_dbg.location(354, 9)
        # Java.g:354:9: ( methodBody | ';' )
        alt51 = 2
        begin
          self.attr_dbg.enter_sub_rule(51)
          begin
            self.attr_dbg.enter_decision(51)
            la51_0 = self.attr_input._la(1)
            if (((la51_0).equal?(44)))
              alt51 = 1
            else
              if (((la51_0).equal?(26)))
                alt51 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 51, 0, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          ensure
            self.attr_dbg.exit_decision(51)
          end
          case (alt51)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:354:13: methodBody
            self.attr_dbg.location(354, 13)
            push_follow(FOLLOW_methodBody_in_voidMethodDeclaratorRest1442)
            method_body
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          when 2
            self.attr_dbg.enter_alt(2)
            # Java.g:355:13: ';'
            self.attr_dbg.location(355, 13)
            match(self.attr_input, 26, FOLLOW_26_in_voidMethodDeclaratorRest1456)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(51)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 36, void_method_declarator_rest_start_index)
        end
      end
      self.attr_dbg.location(357, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "voidMethodDeclaratorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "voidMethodDeclaratorRest"
  # $ANTLR start "interfaceMethodDeclaratorRest"
  # Java.g:359:1: interfaceMethodDeclaratorRest : formalParameters ( '[' ']' )* ( 'throws' qualifiedNameList )? ';' ;
  def interface_method_declarator_rest
    interface_method_declarator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceMethodDeclaratorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(359, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 37))
          return
        end
        # Java.g:360:5: ( formalParameters ( '[' ']' )* ( 'throws' qualifiedNameList )? ';' )
        self.attr_dbg.enter_alt(1)
        # Java.g:360:9: formalParameters ( '[' ']' )* ( 'throws' qualifiedNameList )? ';'
        self.attr_dbg.location(360, 9)
        push_follow(FOLLOW_formalParameters_in_interfaceMethodDeclaratorRest1489)
        formal_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(360, 26)
        # Java.g:360:26: ( '[' ']' )*
        begin
          self.attr_dbg.enter_sub_rule(52)
          begin
            alt52 = 2
            begin
              self.attr_dbg.enter_decision(52)
              la52_0 = self.attr_input._la(1)
              if (((la52_0).equal?(48)))
                alt52 = 1
              end
            ensure
              self.attr_dbg.exit_decision(52)
            end
            case (alt52)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:360:27: '[' ']'
              self.attr_dbg.location(360, 27)
              match(self.attr_input, 48, FOLLOW_48_in_interfaceMethodDeclaratorRest1492)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(360, 31)
              match(self.attr_input, 49, FOLLOW_49_in_interfaceMethodDeclaratorRest1494)
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(52)
        end
        self.attr_dbg.location(360, 37)
        # Java.g:360:37: ( 'throws' qualifiedNameList )?
        alt53 = 2
        begin
          self.attr_dbg.enter_sub_rule(53)
          begin
            self.attr_dbg.enter_decision(53)
            la53_0 = self.attr_input._la(1)
            if (((la53_0).equal?(50)))
              alt53 = 1
            end
          ensure
            self.attr_dbg.exit_decision(53)
          end
          case (alt53)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:360:38: 'throws' qualifiedNameList
            self.attr_dbg.location(360, 38)
            match(self.attr_input, 50, FOLLOW_50_in_interfaceMethodDeclaratorRest1499)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(360, 47)
            push_follow(FOLLOW_qualifiedNameList_in_interfaceMethodDeclaratorRest1501)
            qualified_name_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(53)
        end
        self.attr_dbg.location(360, 67)
        match(self.attr_input, 26, FOLLOW_26_in_interfaceMethodDeclaratorRest1505)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 37, interface_method_declarator_rest_start_index)
        end
      end
      self.attr_dbg.location(361, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceMethodDeclaratorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceMethodDeclaratorRest"
  # $ANTLR start "interfaceGenericMethodDecl"
  # Java.g:363:1: interfaceGenericMethodDecl : typeParameters ( type | 'void' ) Identifier interfaceMethodDeclaratorRest ;
  def interface_generic_method_decl
    interface_generic_method_decl_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "interfaceGenericMethodDecl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(363, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 38))
          return
        end
        # Java.g:364:5: ( typeParameters ( type | 'void' ) Identifier interfaceMethodDeclaratorRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:364:9: typeParameters ( type | 'void' ) Identifier interfaceMethodDeclaratorRest
        self.attr_dbg.location(364, 9)
        push_follow(FOLLOW_typeParameters_in_interfaceGenericMethodDecl1528)
        type_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(364, 24)
        # Java.g:364:24: ( type | 'void' )
        alt54 = 2
        begin
          self.attr_dbg.enter_sub_rule(54)
          begin
            self.attr_dbg.enter_decision(54)
            la54_0 = self.attr_input._la(1)
            if (((la54_0).equal?(Identifier) || (la54_0 >= 56 && la54_0 <= 63)))
              alt54 = 1
            else
              if (((la54_0).equal?(47)))
                alt54 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 54, 0, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          ensure
            self.attr_dbg.exit_decision(54)
          end
          case (alt54)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:364:25: type
            self.attr_dbg.location(364, 25)
            push_follow(FOLLOW_type_in_interfaceGenericMethodDecl1531)
            type
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          when 2
            self.attr_dbg.enter_alt(2)
            # Java.g:364:32: 'void'
            self.attr_dbg.location(364, 32)
            match(self.attr_input, 47, FOLLOW_47_in_interfaceGenericMethodDecl1535)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(54)
        end
        self.attr_dbg.location(364, 40)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_interfaceGenericMethodDecl1538)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(365, 9)
        push_follow(FOLLOW_interfaceMethodDeclaratorRest_in_interfaceGenericMethodDecl1548)
        interface_method_declarator_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 38, interface_generic_method_decl_start_index)
        end
      end
      self.attr_dbg.location(366, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "interfaceGenericMethodDecl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "interfaceGenericMethodDecl"
  # $ANTLR start "voidInterfaceMethodDeclaratorRest"
  # Java.g:368:1: voidInterfaceMethodDeclaratorRest : formalParameters ( 'throws' qualifiedNameList )? ';' ;
  def void_interface_method_declarator_rest
    void_interface_method_declarator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "voidInterfaceMethodDeclaratorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(368, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 39))
          return
        end
        # Java.g:369:5: ( formalParameters ( 'throws' qualifiedNameList )? ';' )
        self.attr_dbg.enter_alt(1)
        # Java.g:369:9: formalParameters ( 'throws' qualifiedNameList )? ';'
        self.attr_dbg.location(369, 9)
        push_follow(FOLLOW_formalParameters_in_voidInterfaceMethodDeclaratorRest1571)
        formal_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(369, 26)
        # Java.g:369:26: ( 'throws' qualifiedNameList )?
        alt55 = 2
        begin
          self.attr_dbg.enter_sub_rule(55)
          begin
            self.attr_dbg.enter_decision(55)
            la55_0 = self.attr_input._la(1)
            if (((la55_0).equal?(50)))
              alt55 = 1
            end
          ensure
            self.attr_dbg.exit_decision(55)
          end
          case (alt55)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:369:27: 'throws' qualifiedNameList
            self.attr_dbg.location(369, 27)
            match(self.attr_input, 50, FOLLOW_50_in_voidInterfaceMethodDeclaratorRest1574)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(369, 36)
            push_follow(FOLLOW_qualifiedNameList_in_voidInterfaceMethodDeclaratorRest1576)
            qualified_name_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(55)
        end
        self.attr_dbg.location(369, 56)
        match(self.attr_input, 26, FOLLOW_26_in_voidInterfaceMethodDeclaratorRest1580)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 39, void_interface_method_declarator_rest_start_index)
        end
      end
      self.attr_dbg.location(370, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "voidInterfaceMethodDeclaratorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "voidInterfaceMethodDeclaratorRest"
  # $ANTLR start "constructorDeclaratorRest"
  # Java.g:372:1: constructorDeclaratorRest : formalParameters ( 'throws' qualifiedNameList )? constructorBody ;
  def constructor_declarator_rest
    constructor_declarator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "constructorDeclaratorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(372, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 40))
          return
        end
        # Java.g:373:5: ( formalParameters ( 'throws' qualifiedNameList )? constructorBody )
        self.attr_dbg.enter_alt(1)
        # Java.g:373:9: formalParameters ( 'throws' qualifiedNameList )? constructorBody
        self.attr_dbg.location(373, 9)
        push_follow(FOLLOW_formalParameters_in_constructorDeclaratorRest1603)
        formal_parameters
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(373, 26)
        # Java.g:373:26: ( 'throws' qualifiedNameList )?
        alt56 = 2
        begin
          self.attr_dbg.enter_sub_rule(56)
          begin
            self.attr_dbg.enter_decision(56)
            la56_0 = self.attr_input._la(1)
            if (((la56_0).equal?(50)))
              alt56 = 1
            end
          ensure
            self.attr_dbg.exit_decision(56)
          end
          case (alt56)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:373:27: 'throws' qualifiedNameList
            self.attr_dbg.location(373, 27)
            match(self.attr_input, 50, FOLLOW_50_in_constructorDeclaratorRest1606)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(373, 36)
            push_follow(FOLLOW_qualifiedNameList_in_constructorDeclaratorRest1608)
            qualified_name_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(56)
        end
        self.attr_dbg.location(373, 56)
        push_follow(FOLLOW_constructorBody_in_constructorDeclaratorRest1612)
        constructor_body
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 40, constructor_declarator_rest_start_index)
        end
      end
      self.attr_dbg.location(374, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "constructorDeclaratorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "constructorDeclaratorRest"
  # $ANTLR start "constantDeclarator"
  # Java.g:376:1: constantDeclarator : Identifier constantDeclaratorRest ;
  def constant_declarator
    constant_declarator_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "constantDeclarator")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(376, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 41))
          return
        end
        # Java.g:377:5: ( Identifier constantDeclaratorRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:377:9: Identifier constantDeclaratorRest
        self.attr_dbg.location(377, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_constantDeclarator1631)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(377, 20)
        push_follow(FOLLOW_constantDeclaratorRest_in_constantDeclarator1633)
        constant_declarator_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 41, constant_declarator_start_index)
        end
      end
      self.attr_dbg.location(378, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "constantDeclarator")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "constantDeclarator"
  # $ANTLR start "variableDeclarators"
  # Java.g:380:1: variableDeclarators : variableDeclarator ( ',' variableDeclarator )* ;
  def variable_declarators
    variable_declarators_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "variableDeclarators")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(380, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 42))
          return
        end
        # Java.g:381:5: ( variableDeclarator ( ',' variableDeclarator )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:381:9: variableDeclarator ( ',' variableDeclarator )*
        self.attr_dbg.location(381, 9)
        push_follow(FOLLOW_variableDeclarator_in_variableDeclarators1656)
        variable_declarator
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(381, 28)
        # Java.g:381:28: ( ',' variableDeclarator )*
        begin
          self.attr_dbg.enter_sub_rule(57)
          begin
            alt57 = 2
            begin
              self.attr_dbg.enter_decision(57)
              la57_0 = self.attr_input._la(1)
              if (((la57_0).equal?(41)))
                alt57 = 1
              end
            ensure
              self.attr_dbg.exit_decision(57)
            end
            case (alt57)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:381:29: ',' variableDeclarator
              self.attr_dbg.location(381, 29)
              match(self.attr_input, 41, FOLLOW_41_in_variableDeclarators1659)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(381, 33)
              push_follow(FOLLOW_variableDeclarator_in_variableDeclarators1661)
              variable_declarator
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(57)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 42, variable_declarators_start_index)
        end
      end
      self.attr_dbg.location(382, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "variableDeclarators")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "variableDeclarators"
  # $ANTLR start "variableDeclarator"
  # Java.g:384:1: variableDeclarator : variableDeclaratorId ( '=' variableInitializer )? ;
  def variable_declarator
    variable_declarator_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "variableDeclarator")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(384, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 43))
          return
        end
        # Java.g:385:5: ( variableDeclaratorId ( '=' variableInitializer )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:385:9: variableDeclaratorId ( '=' variableInitializer )?
        self.attr_dbg.location(385, 9)
        push_follow(FOLLOW_variableDeclaratorId_in_variableDeclarator1682)
        variable_declarator_id
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(385, 30)
        # Java.g:385:30: ( '=' variableInitializer )?
        alt58 = 2
        begin
          self.attr_dbg.enter_sub_rule(58)
          begin
            self.attr_dbg.enter_decision(58)
            la58_0 = self.attr_input._la(1)
            if (((la58_0).equal?(51)))
              alt58 = 1
            end
          ensure
            self.attr_dbg.exit_decision(58)
          end
          case (alt58)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:385:31: '=' variableInitializer
            self.attr_dbg.location(385, 31)
            match(self.attr_input, 51, FOLLOW_51_in_variableDeclarator1685)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(385, 35)
            push_follow(FOLLOW_variableInitializer_in_variableDeclarator1687)
            variable_initializer
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(58)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 43, variable_declarator_start_index)
        end
      end
      self.attr_dbg.location(386, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "variableDeclarator")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "variableDeclarator"
  # $ANTLR start "constantDeclaratorsRest"
  # Java.g:388:1: constantDeclaratorsRest : constantDeclaratorRest ( ',' constantDeclarator )* ;
  def constant_declarators_rest
    constant_declarators_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "constantDeclaratorsRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(388, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 44))
          return
        end
        # Java.g:389:5: ( constantDeclaratorRest ( ',' constantDeclarator )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:389:9: constantDeclaratorRest ( ',' constantDeclarator )*
        self.attr_dbg.location(389, 9)
        push_follow(FOLLOW_constantDeclaratorRest_in_constantDeclaratorsRest1712)
        constant_declarator_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(389, 32)
        # Java.g:389:32: ( ',' constantDeclarator )*
        begin
          self.attr_dbg.enter_sub_rule(59)
          begin
            alt59 = 2
            begin
              self.attr_dbg.enter_decision(59)
              la59_0 = self.attr_input._la(1)
              if (((la59_0).equal?(41)))
                alt59 = 1
              end
            ensure
              self.attr_dbg.exit_decision(59)
            end
            case (alt59)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:389:33: ',' constantDeclarator
              self.attr_dbg.location(389, 33)
              match(self.attr_input, 41, FOLLOW_41_in_constantDeclaratorsRest1715)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(389, 37)
              push_follow(FOLLOW_constantDeclarator_in_constantDeclaratorsRest1717)
              constant_declarator
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(59)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 44, constant_declarators_rest_start_index)
        end
      end
      self.attr_dbg.location(390, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "constantDeclaratorsRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "constantDeclaratorsRest"
  # $ANTLR start "constantDeclaratorRest"
  # Java.g:392:1: constantDeclaratorRest : ( '[' ']' )* '=' variableInitializer ;
  def constant_declarator_rest
    constant_declarator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "constantDeclaratorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(392, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 45))
          return
        end
        # Java.g:393:5: ( ( '[' ']' )* '=' variableInitializer )
        self.attr_dbg.enter_alt(1)
        # Java.g:393:9: ( '[' ']' )* '=' variableInitializer
        self.attr_dbg.location(393, 9)
        # Java.g:393:9: ( '[' ']' )*
        begin
          self.attr_dbg.enter_sub_rule(60)
          begin
            alt60 = 2
            begin
              self.attr_dbg.enter_decision(60)
              la60_0 = self.attr_input._la(1)
              if (((la60_0).equal?(48)))
                alt60 = 1
              end
            ensure
              self.attr_dbg.exit_decision(60)
            end
            case (alt60)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:393:10: '[' ']'
              self.attr_dbg.location(393, 10)
              match(self.attr_input, 48, FOLLOW_48_in_constantDeclaratorRest1739)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(393, 14)
              match(self.attr_input, 49, FOLLOW_49_in_constantDeclaratorRest1741)
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(60)
        end
        self.attr_dbg.location(393, 20)
        match(self.attr_input, 51, FOLLOW_51_in_constantDeclaratorRest1745)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(393, 24)
        push_follow(FOLLOW_variableInitializer_in_constantDeclaratorRest1747)
        variable_initializer
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 45, constant_declarator_rest_start_index)
        end
      end
      self.attr_dbg.location(394, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "constantDeclaratorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "constantDeclaratorRest"
  # $ANTLR start "variableDeclaratorId"
  # Java.g:396:1: variableDeclaratorId : Identifier ( '[' ']' )* ;
  def variable_declarator_id
    variable_declarator_id_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "variableDeclaratorId")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(396, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 46))
          return
        end
        # Java.g:397:5: ( Identifier ( '[' ']' )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:397:9: Identifier ( '[' ']' )*
        self.attr_dbg.location(397, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_variableDeclaratorId1770)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(397, 20)
        # Java.g:397:20: ( '[' ']' )*
        begin
          self.attr_dbg.enter_sub_rule(61)
          begin
            alt61 = 2
            begin
              self.attr_dbg.enter_decision(61)
              la61_0 = self.attr_input._la(1)
              if (((la61_0).equal?(48)))
                alt61 = 1
              end
            ensure
              self.attr_dbg.exit_decision(61)
            end
            case (alt61)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:397:21: '[' ']'
              self.attr_dbg.location(397, 21)
              match(self.attr_input, 48, FOLLOW_48_in_variableDeclaratorId1773)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(397, 25)
              match(self.attr_input, 49, FOLLOW_49_in_variableDeclaratorId1775)
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(61)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 46, variable_declarator_id_start_index)
        end
      end
      self.attr_dbg.location(398, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "variableDeclaratorId")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "variableDeclaratorId"
  # $ANTLR start "variableInitializer"
  # Java.g:400:1: variableInitializer : ( arrayInitializer | expression );
  def variable_initializer
    variable_initializer_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "variableInitializer")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(400, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 47))
          return
        end
        # Java.g:401:5: ( arrayInitializer | expression )
        alt62 = 2
        begin
          self.attr_dbg.enter_decision(62)
          la62_0 = self.attr_input._la(1)
          if (((la62_0).equal?(44)))
            alt62 = 1
          else
            if (((la62_0).equal?(Identifier) || (la62_0 >= FloatingPointLiteral && la62_0 <= DecimalLiteral) || (la62_0).equal?(47) || (la62_0 >= 56 && la62_0 <= 63) || (la62_0 >= 65 && la62_0 <= 66) || (la62_0 >= 69 && la62_0 <= 72) || (la62_0 >= 105 && la62_0 <= 106) || (la62_0 >= 109 && la62_0 <= 113)))
              alt62 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 62, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(62)
        end
        case (alt62)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:401:9: arrayInitializer
          self.attr_dbg.location(401, 9)
          push_follow(FOLLOW_arrayInitializer_in_variableInitializer1796)
          array_initializer
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:402:9: expression
          self.attr_dbg.location(402, 9)
          push_follow(FOLLOW_expression_in_variableInitializer1806)
          expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 47, variable_initializer_start_index)
        end
      end
      self.attr_dbg.location(403, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "variableInitializer")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "variableInitializer"
  # $ANTLR start "arrayInitializer"
  # Java.g:405:1: arrayInitializer : '{' ( variableInitializer ( ',' variableInitializer )* ( ',' )? )? '}' ;
  def array_initializer
    array_initializer_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "arrayInitializer")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(405, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 48))
          return
        end
        # Java.g:406:5: ( '{' ( variableInitializer ( ',' variableInitializer )* ( ',' )? )? '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:406:9: '{' ( variableInitializer ( ',' variableInitializer )* ( ',' )? )? '}'
        self.attr_dbg.location(406, 9)
        match(self.attr_input, 44, FOLLOW_44_in_arrayInitializer1833)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(406, 13)
        # Java.g:406:13: ( variableInitializer ( ',' variableInitializer )* ( ',' )? )?
        alt65 = 2
        begin
          self.attr_dbg.enter_sub_rule(65)
          begin
            self.attr_dbg.enter_decision(65)
            la65_0 = self.attr_input._la(1)
            if (((la65_0).equal?(Identifier) || (la65_0 >= FloatingPointLiteral && la65_0 <= DecimalLiteral) || (la65_0).equal?(44) || (la65_0).equal?(47) || (la65_0 >= 56 && la65_0 <= 63) || (la65_0 >= 65 && la65_0 <= 66) || (la65_0 >= 69 && la65_0 <= 72) || (la65_0 >= 105 && la65_0 <= 106) || (la65_0 >= 109 && la65_0 <= 113)))
              alt65 = 1
            end
          ensure
            self.attr_dbg.exit_decision(65)
          end
          case (alt65)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:406:14: variableInitializer ( ',' variableInitializer )* ( ',' )?
            self.attr_dbg.location(406, 14)
            push_follow(FOLLOW_variableInitializer_in_arrayInitializer1836)
            variable_initializer
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(406, 34)
            # Java.g:406:34: ( ',' variableInitializer )*
            begin
              self.attr_dbg.enter_sub_rule(63)
              begin
                alt63 = 2
                begin
                  self.attr_dbg.enter_decision(63)
                  la63_0 = self.attr_input._la(1)
                  if (((la63_0).equal?(41)))
                    la63_1 = self.attr_input._la(2)
                    if (((la63_1).equal?(Identifier) || (la63_1 >= FloatingPointLiteral && la63_1 <= DecimalLiteral) || (la63_1).equal?(44) || (la63_1).equal?(47) || (la63_1 >= 56 && la63_1 <= 63) || (la63_1 >= 65 && la63_1 <= 66) || (la63_1 >= 69 && la63_1 <= 72) || (la63_1 >= 105 && la63_1 <= 106) || (la63_1 >= 109 && la63_1 <= 113)))
                      alt63 = 1
                    end
                  end
                ensure
                  self.attr_dbg.exit_decision(63)
                end
                case (alt63)
                when 1
                  self.attr_dbg.enter_alt(1)
                  # Java.g:406:35: ',' variableInitializer
                  self.attr_dbg.location(406, 35)
                  match(self.attr_input, 41, FOLLOW_41_in_arrayInitializer1839)
                  if (self.attr_state.attr_failed)
                    return
                  end
                  self.attr_dbg.location(406, 39)
                  push_follow(FOLLOW_variableInitializer_in_arrayInitializer1841)
                  variable_initializer
                  self.attr_state.attr__fsp -= 1
                  if (self.attr_state.attr_failed)
                    return
                  end
                else
                  break
                end
              end while (true)
            ensure
              self.attr_dbg.exit_sub_rule(63)
            end
            self.attr_dbg.location(406, 61)
            # Java.g:406:61: ( ',' )?
            alt64 = 2
            begin
              self.attr_dbg.enter_sub_rule(64)
              begin
                self.attr_dbg.enter_decision(64)
                la64_0 = self.attr_input._la(1)
                if (((la64_0).equal?(41)))
                  alt64 = 1
                end
              ensure
                self.attr_dbg.exit_decision(64)
              end
              case (alt64)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:406:62: ','
                self.attr_dbg.location(406, 62)
                match(self.attr_input, 41, FOLLOW_41_in_arrayInitializer1846)
                if (self.attr_state.attr_failed)
                  return
                end
              end
            ensure
              self.attr_dbg.exit_sub_rule(64)
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(65)
        end
        self.attr_dbg.location(406, 71)
        match(self.attr_input, 45, FOLLOW_45_in_arrayInitializer1853)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 48, array_initializer_start_index)
        end
      end
      self.attr_dbg.location(407, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "arrayInitializer")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "arrayInitializer"
  # $ANTLR start "modifier"
  # Java.g:409:1: modifier : ( annotation | 'public' | 'protected' | 'private' | 'static' | 'abstract' | 'final' | 'native' | 'synchronized' | 'transient' | 'volatile' | 'strictfp' );
  def modifier
    modifier_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "modifier")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(409, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 49))
          return
        end
        # Java.g:410:5: ( annotation | 'public' | 'protected' | 'private' | 'static' | 'abstract' | 'final' | 'native' | 'synchronized' | 'transient' | 'volatile' | 'strictfp' )
        alt66 = 12
        begin
          self.attr_dbg.enter_decision(66)
          case (self.attr_input._la(1))
          when 73
            alt66 = 1
          when 31
            alt66 = 2
          when 32
            alt66 = 3
          when 33
            alt66 = 4
          when 28
            alt66 = 5
          when 34
            alt66 = 6
          when 35
            alt66 = 7
          when 52
            alt66 = 8
          when 53
            alt66 = 9
          when 54
            alt66 = 10
          when 55
            alt66 = 11
          when 36
            alt66 = 12
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 66, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(66)
        end
        case (alt66)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:410:9: annotation
          self.attr_dbg.location(410, 9)
          push_follow(FOLLOW_annotation_in_modifier1872)
          annotation
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:411:9: 'public'
          self.attr_dbg.location(411, 9)
          match(self.attr_input, 31, FOLLOW_31_in_modifier1882)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:412:9: 'protected'
          self.attr_dbg.location(412, 9)
          match(self.attr_input, 32, FOLLOW_32_in_modifier1892)
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:413:9: 'private'
          self.attr_dbg.location(413, 9)
          match(self.attr_input, 33, FOLLOW_33_in_modifier1902)
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:414:9: 'static'
          self.attr_dbg.location(414, 9)
          match(self.attr_input, 28, FOLLOW_28_in_modifier1912)
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:415:9: 'abstract'
          self.attr_dbg.location(415, 9)
          match(self.attr_input, 34, FOLLOW_34_in_modifier1922)
          if (self.attr_state.attr_failed)
            return
          end
        when 7
          self.attr_dbg.enter_alt(7)
          # Java.g:416:9: 'final'
          self.attr_dbg.location(416, 9)
          match(self.attr_input, 35, FOLLOW_35_in_modifier1932)
          if (self.attr_state.attr_failed)
            return
          end
        when 8
          self.attr_dbg.enter_alt(8)
          # Java.g:417:9: 'native'
          self.attr_dbg.location(417, 9)
          match(self.attr_input, 52, FOLLOW_52_in_modifier1942)
          if (self.attr_state.attr_failed)
            return
          end
        when 9
          self.attr_dbg.enter_alt(9)
          # Java.g:418:9: 'synchronized'
          self.attr_dbg.location(418, 9)
          match(self.attr_input, 53, FOLLOW_53_in_modifier1952)
          if (self.attr_state.attr_failed)
            return
          end
        when 10
          self.attr_dbg.enter_alt(10)
          # Java.g:419:9: 'transient'
          self.attr_dbg.location(419, 9)
          match(self.attr_input, 54, FOLLOW_54_in_modifier1962)
          if (self.attr_state.attr_failed)
            return
          end
        when 11
          self.attr_dbg.enter_alt(11)
          # Java.g:420:9: 'volatile'
          self.attr_dbg.location(420, 9)
          match(self.attr_input, 55, FOLLOW_55_in_modifier1972)
          if (self.attr_state.attr_failed)
            return
          end
        when 12
          self.attr_dbg.enter_alt(12)
          # Java.g:421:9: 'strictfp'
          self.attr_dbg.location(421, 9)
          match(self.attr_input, 36, FOLLOW_36_in_modifier1982)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 49, modifier_start_index)
        end
      end
      self.attr_dbg.location(422, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "modifier")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "modifier"
  # $ANTLR start "packageOrTypeName"
  # Java.g:424:1: packageOrTypeName : qualifiedName ;
  def package_or_type_name
    package_or_type_name_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "packageOrTypeName")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(424, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 50))
          return
        end
        # Java.g:425:5: ( qualifiedName )
        self.attr_dbg.enter_alt(1)
        # Java.g:425:9: qualifiedName
        self.attr_dbg.location(425, 9)
        push_follow(FOLLOW_qualifiedName_in_packageOrTypeName2001)
        qualified_name
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 50, package_or_type_name_start_index)
        end
      end
      self.attr_dbg.location(426, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "packageOrTypeName")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "packageOrTypeName"
  # $ANTLR start "enumConstantName"
  # Java.g:428:1: enumConstantName : Identifier ;
  def enum_constant_name
    enum_constant_name_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enumConstantName")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(428, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 51))
          return
        end
        # Java.g:429:5: ( Identifier )
        self.attr_dbg.enter_alt(1)
        # Java.g:429:9: Identifier
        self.attr_dbg.location(429, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_enumConstantName2020)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 51, enum_constant_name_start_index)
        end
      end
      self.attr_dbg.location(430, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enumConstantName")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enumConstantName"
  # $ANTLR start "typeName"
  # Java.g:432:1: typeName : qualifiedName ;
  def type_name
    type_name_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeName")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(432, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 52))
          return
        end
        # Java.g:433:5: ( qualifiedName )
        self.attr_dbg.enter_alt(1)
        # Java.g:433:9: qualifiedName
        self.attr_dbg.location(433, 9)
        push_follow(FOLLOW_qualifiedName_in_typeName2039)
        qualified_name
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 52, type_name_start_index)
        end
      end
      self.attr_dbg.location(434, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeName")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeName"
  # $ANTLR start "type"
  # Java.g:436:1: type : ( classOrInterfaceType ( '[' ']' )* | primitiveType ( '[' ']' )* );
  def type
    type_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "type")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(436, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 53))
          return
        end
        # Java.g:437:2: ( classOrInterfaceType ( '[' ']' )* | primitiveType ( '[' ']' )* )
        alt69 = 2
        begin
          self.attr_dbg.enter_decision(69)
          la69_0 = self.attr_input._la(1)
          if (((la69_0).equal?(Identifier)))
            alt69 = 1
          else
            if (((la69_0 >= 56 && la69_0 <= 63)))
              alt69 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 69, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(69)
        end
        case (alt69)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:437:4: classOrInterfaceType ( '[' ']' )*
          self.attr_dbg.location(437, 4)
          push_follow(FOLLOW_classOrInterfaceType_in_type2053)
          class_or_interface_type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(437, 25)
          # Java.g:437:25: ( '[' ']' )*
          begin
            self.attr_dbg.enter_sub_rule(67)
            begin
              alt67 = 2
              begin
                self.attr_dbg.enter_decision(67)
                la67_0 = self.attr_input._la(1)
                if (((la67_0).equal?(48)))
                  alt67 = 1
                end
              ensure
                self.attr_dbg.exit_decision(67)
              end
              case (alt67)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:437:26: '[' ']'
                self.attr_dbg.location(437, 26)
                match(self.attr_input, 48, FOLLOW_48_in_type2056)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(437, 30)
                match(self.attr_input, 49, FOLLOW_49_in_type2058)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(67)
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:438:4: primitiveType ( '[' ']' )*
          self.attr_dbg.location(438, 4)
          push_follow(FOLLOW_primitiveType_in_type2065)
          primitive_type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(438, 18)
          # Java.g:438:18: ( '[' ']' )*
          begin
            self.attr_dbg.enter_sub_rule(68)
            begin
              alt68 = 2
              begin
                self.attr_dbg.enter_decision(68)
                la68_0 = self.attr_input._la(1)
                if (((la68_0).equal?(48)))
                  alt68 = 1
                end
              ensure
                self.attr_dbg.exit_decision(68)
              end
              case (alt68)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:438:19: '[' ']'
                self.attr_dbg.location(438, 19)
                match(self.attr_input, 48, FOLLOW_48_in_type2068)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(438, 23)
                match(self.attr_input, 49, FOLLOW_49_in_type2070)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(68)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 53, type_start_index)
        end
      end
      self.attr_dbg.location(439, 2)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "type")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "type"
  # $ANTLR start "classOrInterfaceType"
  # Java.g:441:1: classOrInterfaceType : Identifier ( typeArguments )? ( '.' Identifier ( typeArguments )? )* ;
  def class_or_interface_type
    class_or_interface_type_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classOrInterfaceType")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(441, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 54))
          return
        end
        # Java.g:442:2: ( Identifier ( typeArguments )? ( '.' Identifier ( typeArguments )? )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:442:4: Identifier ( typeArguments )? ( '.' Identifier ( typeArguments )? )*
        self.attr_dbg.location(442, 4)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_classOrInterfaceType2083)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(442, 15)
        # Java.g:442:15: ( typeArguments )?
        alt70 = 2
        begin
          self.attr_dbg.enter_sub_rule(70)
          begin
            self.attr_dbg.enter_decision(70)
            la70_0 = self.attr_input._la(1)
            if (((la70_0).equal?(40)))
              la70_1 = self.attr_input._la(2)
              if (((la70_1).equal?(Identifier) || (la70_1 >= 56 && la70_1 <= 64)))
                alt70 = 1
              end
            end
          ensure
            self.attr_dbg.exit_decision(70)
          end
          case (alt70)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: typeArguments
            self.attr_dbg.location(442, 15)
            push_follow(FOLLOW_typeArguments_in_classOrInterfaceType2085)
            type_arguments
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(70)
        end
        self.attr_dbg.location(442, 30)
        # Java.g:442:30: ( '.' Identifier ( typeArguments )? )*
        begin
          self.attr_dbg.enter_sub_rule(72)
          begin
            alt72 = 2
            begin
              self.attr_dbg.enter_decision(72)
              la72_0 = self.attr_input._la(1)
              if (((la72_0).equal?(29)))
                alt72 = 1
              end
            ensure
              self.attr_dbg.exit_decision(72)
            end
            case (alt72)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:442:31: '.' Identifier ( typeArguments )?
              self.attr_dbg.location(442, 31)
              match(self.attr_input, 29, FOLLOW_29_in_classOrInterfaceType2089)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(442, 35)
              match(self.attr_input, Identifier, FOLLOW_Identifier_in_classOrInterfaceType2091)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(442, 46)
              # Java.g:442:46: ( typeArguments )?
              alt71 = 2
              begin
                self.attr_dbg.enter_sub_rule(71)
                begin
                  self.attr_dbg.enter_decision(71)
                  la71_0 = self.attr_input._la(1)
                  if (((la71_0).equal?(40)))
                    la71_1 = self.attr_input._la(2)
                    if (((la71_1).equal?(Identifier) || (la71_1 >= 56 && la71_1 <= 64)))
                      alt71 = 1
                    end
                  end
                ensure
                  self.attr_dbg.exit_decision(71)
                end
                case (alt71)
                when 1
                  self.attr_dbg.enter_alt(1)
                  # Java.g:0:0: typeArguments
                  self.attr_dbg.location(442, 46)
                  push_follow(FOLLOW_typeArguments_in_classOrInterfaceType2093)
                  type_arguments
                  self.attr_state.attr__fsp -= 1
                  if (self.attr_state.attr_failed)
                    return
                  end
                end
              ensure
                self.attr_dbg.exit_sub_rule(71)
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(72)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 54, class_or_interface_type_start_index)
        end
      end
      self.attr_dbg.location(443, 2)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classOrInterfaceType")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classOrInterfaceType"
  # $ANTLR start "primitiveType"
  # Java.g:445:1: primitiveType : ( 'boolean' | 'char' | 'byte' | 'short' | 'int' | 'long' | 'float' | 'double' );
  def primitive_type
    primitive_type_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "primitiveType")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(445, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 55))
          return
        end
        # Java.g:446:5: ( 'boolean' | 'char' | 'byte' | 'short' | 'int' | 'long' | 'float' | 'double' )
        self.attr_dbg.enter_alt(1)
        # Java.g:
        self.attr_dbg.location(446, 5)
        if ((self.attr_input._la(1) >= 56 && self.attr_input._la(1) <= 63))
          self.attr_input.consume
          self.attr_state.attr_error_recovery = false
          self.attr_state.attr_failed = false
        else
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          mse = MismatchedSetException.new(nil, self.attr_input)
          self.attr_dbg.recognition_exception(mse)
          raise mse
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 55, primitive_type_start_index)
        end
      end
      self.attr_dbg.location(454, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "primitiveType")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "primitiveType"
  # $ANTLR start "variableModifier"
  # Java.g:456:1: variableModifier : ( 'final' | annotation );
  def variable_modifier
    variable_modifier_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "variableModifier")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(456, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 56))
          return
        end
        # Java.g:457:5: ( 'final' | annotation )
        alt73 = 2
        begin
          self.attr_dbg.enter_decision(73)
          la73_0 = self.attr_input._la(1)
          if (((la73_0).equal?(35)))
            alt73 = 1
          else
            if (((la73_0).equal?(73)))
              alt73 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 73, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(73)
        end
        case (alt73)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:457:9: 'final'
          self.attr_dbg.location(457, 9)
          match(self.attr_input, 35, FOLLOW_35_in_variableModifier2202)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:458:9: annotation
          self.attr_dbg.location(458, 9)
          push_follow(FOLLOW_annotation_in_variableModifier2212)
          annotation
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 56, variable_modifier_start_index)
        end
      end
      self.attr_dbg.location(459, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "variableModifier")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "variableModifier"
  # $ANTLR start "typeArguments"
  # Java.g:461:1: typeArguments : '<' typeArgument ( ',' typeArgument )* '>' ;
  def type_arguments
    type_arguments_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeArguments")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(461, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 57))
          return
        end
        # Java.g:462:5: ( '<' typeArgument ( ',' typeArgument )* '>' )
        self.attr_dbg.enter_alt(1)
        # Java.g:462:9: '<' typeArgument ( ',' typeArgument )* '>'
        self.attr_dbg.location(462, 9)
        match(self.attr_input, 40, FOLLOW_40_in_typeArguments2231)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(462, 13)
        push_follow(FOLLOW_typeArgument_in_typeArguments2233)
        type_argument
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(462, 26)
        # Java.g:462:26: ( ',' typeArgument )*
        begin
          self.attr_dbg.enter_sub_rule(74)
          begin
            alt74 = 2
            begin
              self.attr_dbg.enter_decision(74)
              la74_0 = self.attr_input._la(1)
              if (((la74_0).equal?(41)))
                alt74 = 1
              end
            ensure
              self.attr_dbg.exit_decision(74)
            end
            case (alt74)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:462:27: ',' typeArgument
              self.attr_dbg.location(462, 27)
              match(self.attr_input, 41, FOLLOW_41_in_typeArguments2236)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(462, 31)
              push_follow(FOLLOW_typeArgument_in_typeArguments2238)
              type_argument
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(74)
        end
        self.attr_dbg.location(462, 46)
        match(self.attr_input, 42, FOLLOW_42_in_typeArguments2242)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 57, type_arguments_start_index)
        end
      end
      self.attr_dbg.location(463, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeArguments")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeArguments"
  # $ANTLR start "typeArgument"
  # Java.g:465:1: typeArgument : ( type | '?' ( ( 'extends' | 'super' ) type )? );
  def type_argument
    type_argument_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "typeArgument")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(465, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 58))
          return
        end
        # Java.g:466:5: ( type | '?' ( ( 'extends' | 'super' ) type )? )
        alt76 = 2
        begin
          self.attr_dbg.enter_decision(76)
          la76_0 = self.attr_input._la(1)
          if (((la76_0).equal?(Identifier) || (la76_0 >= 56 && la76_0 <= 63)))
            alt76 = 1
          else
            if (((la76_0).equal?(64)))
              alt76 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 76, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(76)
        end
        case (alt76)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:466:9: type
          self.attr_dbg.location(466, 9)
          push_follow(FOLLOW_type_in_typeArgument2265)
          type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:467:9: '?' ( ( 'extends' | 'super' ) type )?
          self.attr_dbg.location(467, 9)
          match(self.attr_input, 64, FOLLOW_64_in_typeArgument2275)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(467, 13)
          # Java.g:467:13: ( ( 'extends' | 'super' ) type )?
          alt75 = 2
          begin
            self.attr_dbg.enter_sub_rule(75)
            begin
              self.attr_dbg.enter_decision(75)
              la75_0 = self.attr_input._la(1)
              if (((la75_0).equal?(38) || (la75_0).equal?(65)))
                alt75 = 1
              end
            ensure
              self.attr_dbg.exit_decision(75)
            end
            case (alt75)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:467:14: ( 'extends' | 'super' ) type
              self.attr_dbg.location(467, 14)
              if ((self.attr_input._la(1)).equal?(38) || (self.attr_input._la(1)).equal?(65))
                self.attr_input.consume
                self.attr_state.attr_error_recovery = false
                self.attr_state.attr_failed = false
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                mse = MismatchedSetException.new(nil, self.attr_input)
                self.attr_dbg.recognition_exception(mse)
                raise mse
              end
              self.attr_dbg.location(467, 36)
              push_follow(FOLLOW_type_in_typeArgument2286)
              type
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(75)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 58, type_argument_start_index)
        end
      end
      self.attr_dbg.location(468, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "typeArgument")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "typeArgument"
  # $ANTLR start "qualifiedNameList"
  # Java.g:470:1: qualifiedNameList : qualifiedName ( ',' qualifiedName )* ;
  def qualified_name_list
    qualified_name_list_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "qualifiedNameList")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(470, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 59))
          return
        end
        # Java.g:471:5: ( qualifiedName ( ',' qualifiedName )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:471:9: qualifiedName ( ',' qualifiedName )*
        self.attr_dbg.location(471, 9)
        push_follow(FOLLOW_qualifiedName_in_qualifiedNameList2311)
        qualified_name
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(471, 23)
        # Java.g:471:23: ( ',' qualifiedName )*
        begin
          self.attr_dbg.enter_sub_rule(77)
          begin
            alt77 = 2
            begin
              self.attr_dbg.enter_decision(77)
              la77_0 = self.attr_input._la(1)
              if (((la77_0).equal?(41)))
                alt77 = 1
              end
            ensure
              self.attr_dbg.exit_decision(77)
            end
            case (alt77)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:471:24: ',' qualifiedName
              self.attr_dbg.location(471, 24)
              match(self.attr_input, 41, FOLLOW_41_in_qualifiedNameList2314)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(471, 28)
              push_follow(FOLLOW_qualifiedName_in_qualifiedNameList2316)
              qualified_name
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(77)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 59, qualified_name_list_start_index)
        end
      end
      self.attr_dbg.location(472, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "qualifiedNameList")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "qualifiedNameList"
  # $ANTLR start "formalParameters"
  # Java.g:474:1: formalParameters : '(' ( formalParameterDecls )? ')' ;
  def formal_parameters
    formal_parameters_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "formalParameters")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(474, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 60))
          return
        end
        # Java.g:475:5: ( '(' ( formalParameterDecls )? ')' )
        self.attr_dbg.enter_alt(1)
        # Java.g:475:9: '(' ( formalParameterDecls )? ')'
        self.attr_dbg.location(475, 9)
        match(self.attr_input, 66, FOLLOW_66_in_formalParameters2337)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(475, 13)
        # Java.g:475:13: ( formalParameterDecls )?
        alt78 = 2
        begin
          self.attr_dbg.enter_sub_rule(78)
          begin
            self.attr_dbg.enter_decision(78)
            la78_0 = self.attr_input._la(1)
            if (((la78_0).equal?(Identifier) || (la78_0).equal?(35) || (la78_0 >= 56 && la78_0 <= 63) || (la78_0).equal?(73)))
              alt78 = 1
            end
          ensure
            self.attr_dbg.exit_decision(78)
          end
          case (alt78)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: formalParameterDecls
            self.attr_dbg.location(475, 13)
            push_follow(FOLLOW_formalParameterDecls_in_formalParameters2339)
            formal_parameter_decls
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(78)
        end
        self.attr_dbg.location(475, 35)
        match(self.attr_input, 67, FOLLOW_67_in_formalParameters2342)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 60, formal_parameters_start_index)
        end
      end
      self.attr_dbg.location(476, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "formalParameters")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "formalParameters"
  # $ANTLR start "formalParameterDecls"
  # Java.g:478:1: formalParameterDecls : variableModifiers type formalParameterDeclsRest ;
  def formal_parameter_decls
    formal_parameter_decls_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "formalParameterDecls")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(478, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 61))
          return
        end
        # Java.g:479:5: ( variableModifiers type formalParameterDeclsRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:479:9: variableModifiers type formalParameterDeclsRest
        self.attr_dbg.location(479, 9)
        push_follow(FOLLOW_variableModifiers_in_formalParameterDecls2365)
        variable_modifiers
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(479, 27)
        push_follow(FOLLOW_type_in_formalParameterDecls2367)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(479, 32)
        push_follow(FOLLOW_formalParameterDeclsRest_in_formalParameterDecls2369)
        formal_parameter_decls_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 61, formal_parameter_decls_start_index)
        end
      end
      self.attr_dbg.location(480, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "formalParameterDecls")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "formalParameterDecls"
  # $ANTLR start "formalParameterDeclsRest"
  # Java.g:482:1: formalParameterDeclsRest : ( variableDeclaratorId ( ',' formalParameterDecls )? | '...' variableDeclaratorId );
  def formal_parameter_decls_rest
    formal_parameter_decls_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "formalParameterDeclsRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(482, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 62))
          return
        end
        # Java.g:483:5: ( variableDeclaratorId ( ',' formalParameterDecls )? | '...' variableDeclaratorId )
        alt80 = 2
        begin
          self.attr_dbg.enter_decision(80)
          la80_0 = self.attr_input._la(1)
          if (((la80_0).equal?(Identifier)))
            alt80 = 1
          else
            if (((la80_0).equal?(68)))
              alt80 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 80, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(80)
        end
        case (alt80)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:483:9: variableDeclaratorId ( ',' formalParameterDecls )?
          self.attr_dbg.location(483, 9)
          push_follow(FOLLOW_variableDeclaratorId_in_formalParameterDeclsRest2392)
          variable_declarator_id
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(483, 30)
          # Java.g:483:30: ( ',' formalParameterDecls )?
          alt79 = 2
          begin
            self.attr_dbg.enter_sub_rule(79)
            begin
              self.attr_dbg.enter_decision(79)
              la79_0 = self.attr_input._la(1)
              if (((la79_0).equal?(41)))
                alt79 = 1
              end
            ensure
              self.attr_dbg.exit_decision(79)
            end
            case (alt79)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:483:31: ',' formalParameterDecls
              self.attr_dbg.location(483, 31)
              match(self.attr_input, 41, FOLLOW_41_in_formalParameterDeclsRest2395)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(483, 35)
              push_follow(FOLLOW_formalParameterDecls_in_formalParameterDeclsRest2397)
              formal_parameter_decls
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(79)
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:484:9: '...' variableDeclaratorId
          self.attr_dbg.location(484, 9)
          match(self.attr_input, 68, FOLLOW_68_in_formalParameterDeclsRest2409)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(484, 15)
          push_follow(FOLLOW_variableDeclaratorId_in_formalParameterDeclsRest2411)
          variable_declarator_id
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 62, formal_parameter_decls_rest_start_index)
        end
      end
      self.attr_dbg.location(485, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "formalParameterDeclsRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "formalParameterDeclsRest"
  # $ANTLR start "methodBody"
  # Java.g:487:1: methodBody : block ;
  def method_body
    method_body_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "methodBody")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(487, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 63))
          return
        end
        # Java.g:488:5: ( block )
        self.attr_dbg.enter_alt(1)
        # Java.g:488:9: block
        self.attr_dbg.location(488, 9)
        push_follow(FOLLOW_block_in_methodBody2434)
        block
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 63, method_body_start_index)
        end
      end
      self.attr_dbg.location(489, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "methodBody")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "methodBody"
  # $ANTLR start "constructorBody"
  # Java.g:491:1: constructorBody : '{' ( explicitConstructorInvocation )? ( blockStatement )* '}' ;
  def constructor_body
    constructor_body_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "constructorBody")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(491, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 64))
          return
        end
        # Java.g:492:5: ( '{' ( explicitConstructorInvocation )? ( blockStatement )* '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:492:9: '{' ( explicitConstructorInvocation )? ( blockStatement )* '}'
        self.attr_dbg.location(492, 9)
        match(self.attr_input, 44, FOLLOW_44_in_constructorBody2453)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(492, 13)
        # Java.g:492:13: ( explicitConstructorInvocation )?
        alt81 = 2
        begin
          self.attr_dbg.enter_sub_rule(81)
          begin
            self.attr_dbg.enter_decision(81)
            begin
              self.attr_is_cyclic_decision = true
              alt81 = @dfa81.predict(self.attr_input)
            rescue NoViableAltException => nvae
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          ensure
            self.attr_dbg.exit_decision(81)
          end
          case (alt81)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: explicitConstructorInvocation
            self.attr_dbg.location(492, 13)
            push_follow(FOLLOW_explicitConstructorInvocation_in_constructorBody2455)
            explicit_constructor_invocation
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(81)
        end
        self.attr_dbg.location(492, 44)
        # Java.g:492:44: ( blockStatement )*
        begin
          self.attr_dbg.enter_sub_rule(82)
          begin
            alt82 = 2
            begin
              self.attr_dbg.enter_decision(82)
              la82_0 = self.attr_input._la(1)
              if (((la82_0 >= Identifier && la82_0 <= ASSERT) || (la82_0).equal?(26) || (la82_0).equal?(28) || (la82_0 >= 31 && la82_0 <= 37) || (la82_0).equal?(44) || (la82_0 >= 46 && la82_0 <= 47) || (la82_0).equal?(53) || (la82_0 >= 56 && la82_0 <= 63) || (la82_0 >= 65 && la82_0 <= 66) || (la82_0 >= 69 && la82_0 <= 73) || (la82_0).equal?(76) || (la82_0 >= 78 && la82_0 <= 81) || (la82_0 >= 83 && la82_0 <= 87) || (la82_0 >= 105 && la82_0 <= 106) || (la82_0 >= 109 && la82_0 <= 113)))
                alt82 = 1
              end
            ensure
              self.attr_dbg.exit_decision(82)
            end
            case (alt82)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: blockStatement
              self.attr_dbg.location(492, 44)
              push_follow(FOLLOW_blockStatement_in_constructorBody2458)
              block_statement
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(82)
        end
        self.attr_dbg.location(492, 60)
        match(self.attr_input, 45, FOLLOW_45_in_constructorBody2461)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 64, constructor_body_start_index)
        end
      end
      self.attr_dbg.location(493, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "constructorBody")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "constructorBody"
  # $ANTLR start "explicitConstructorInvocation"
  # Java.g:495:1: explicitConstructorInvocation : ( ( nonWildcardTypeArguments )? ( 'this' | 'super' ) arguments ';' | primary '.' ( nonWildcardTypeArguments )? 'super' arguments ';' );
  def explicit_constructor_invocation
    explicit_constructor_invocation_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "explicitConstructorInvocation")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(495, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 65))
          return
        end
        # Java.g:496:5: ( ( nonWildcardTypeArguments )? ( 'this' | 'super' ) arguments ';' | primary '.' ( nonWildcardTypeArguments )? 'super' arguments ';' )
        alt85 = 2
        begin
          self.attr_dbg.enter_decision(85)
          begin
            self.attr_is_cyclic_decision = true
            alt85 = @dfa85.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(85)
        end
        case (alt85)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:496:9: ( nonWildcardTypeArguments )? ( 'this' | 'super' ) arguments ';'
          self.attr_dbg.location(496, 9)
          # Java.g:496:9: ( nonWildcardTypeArguments )?
          alt83 = 2
          begin
            self.attr_dbg.enter_sub_rule(83)
            begin
              self.attr_dbg.enter_decision(83)
              la83_0 = self.attr_input._la(1)
              if (((la83_0).equal?(40)))
                alt83 = 1
              end
            ensure
              self.attr_dbg.exit_decision(83)
            end
            case (alt83)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: nonWildcardTypeArguments
              self.attr_dbg.location(496, 9)
              push_follow(FOLLOW_nonWildcardTypeArguments_in_explicitConstructorInvocation2480)
              non_wildcard_type_arguments
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(83)
          end
          self.attr_dbg.location(496, 35)
          if ((self.attr_input._la(1)).equal?(65) || (self.attr_input._la(1)).equal?(69))
            self.attr_input.consume
            self.attr_state.attr_error_recovery = false
            self.attr_state.attr_failed = false
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            mse = MismatchedSetException.new(nil, self.attr_input)
            self.attr_dbg.recognition_exception(mse)
            raise mse
          end
          self.attr_dbg.location(496, 54)
          push_follow(FOLLOW_arguments_in_explicitConstructorInvocation2491)
          arguments
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(496, 64)
          match(self.attr_input, 26, FOLLOW_26_in_explicitConstructorInvocation2493)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:497:9: primary '.' ( nonWildcardTypeArguments )? 'super' arguments ';'
          self.attr_dbg.location(497, 9)
          push_follow(FOLLOW_primary_in_explicitConstructorInvocation2503)
          primary
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(497, 17)
          match(self.attr_input, 29, FOLLOW_29_in_explicitConstructorInvocation2505)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(497, 21)
          # Java.g:497:21: ( nonWildcardTypeArguments )?
          alt84 = 2
          begin
            self.attr_dbg.enter_sub_rule(84)
            begin
              self.attr_dbg.enter_decision(84)
              la84_0 = self.attr_input._la(1)
              if (((la84_0).equal?(40)))
                alt84 = 1
              end
            ensure
              self.attr_dbg.exit_decision(84)
            end
            case (alt84)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: nonWildcardTypeArguments
              self.attr_dbg.location(497, 21)
              push_follow(FOLLOW_nonWildcardTypeArguments_in_explicitConstructorInvocation2507)
              non_wildcard_type_arguments
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(84)
          end
          self.attr_dbg.location(497, 47)
          match(self.attr_input, 65, FOLLOW_65_in_explicitConstructorInvocation2510)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(497, 55)
          push_follow(FOLLOW_arguments_in_explicitConstructorInvocation2512)
          arguments
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(497, 65)
          match(self.attr_input, 26, FOLLOW_26_in_explicitConstructorInvocation2514)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 65, explicit_constructor_invocation_start_index)
        end
      end
      self.attr_dbg.location(498, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "explicitConstructorInvocation")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "explicitConstructorInvocation"
  # $ANTLR start "qualifiedName"
  # Java.g:501:1: qualifiedName : Identifier ( '.' Identifier )* ;
  def qualified_name
    qualified_name_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "qualifiedName")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(501, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 66))
          return
        end
        # Java.g:502:5: ( Identifier ( '.' Identifier )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:502:9: Identifier ( '.' Identifier )*
        self.attr_dbg.location(502, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_qualifiedName2534)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(502, 20)
        # Java.g:502:20: ( '.' Identifier )*
        begin
          self.attr_dbg.enter_sub_rule(86)
          begin
            alt86 = 2
            begin
              self.attr_dbg.enter_decision(86)
              la86_0 = self.attr_input._la(1)
              if (((la86_0).equal?(29)))
                la86_2 = self.attr_input._la(2)
                if (((la86_2).equal?(Identifier)))
                  alt86 = 1
                end
              end
            ensure
              self.attr_dbg.exit_decision(86)
            end
            case (alt86)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:502:21: '.' Identifier
              self.attr_dbg.location(502, 21)
              match(self.attr_input, 29, FOLLOW_29_in_qualifiedName2537)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(502, 25)
              match(self.attr_input, Identifier, FOLLOW_Identifier_in_qualifiedName2539)
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(86)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 66, qualified_name_start_index)
        end
      end
      self.attr_dbg.location(503, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "qualifiedName")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "qualifiedName"
  # $ANTLR start "literal"
  # Java.g:505:1: literal : ( integerLiteral | FloatingPointLiteral | CharacterLiteral | StringLiteral | booleanLiteral | 'null' );
  def literal
    literal_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "literal")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(505, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 67))
          return
        end
        # Java.g:506:5: ( integerLiteral | FloatingPointLiteral | CharacterLiteral | StringLiteral | booleanLiteral | 'null' )
        alt87 = 6
        begin
          self.attr_dbg.enter_decision(87)
          case (self.attr_input._la(1))
          when HexLiteral, OctalLiteral, DecimalLiteral
            alt87 = 1
          when FloatingPointLiteral
            alt87 = 2
          when CharacterLiteral
            alt87 = 3
          when StringLiteral
            alt87 = 4
          when 71, 72
            alt87 = 5
          when 70
            alt87 = 6
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 87, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(87)
        end
        case (alt87)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:506:9: integerLiteral
          self.attr_dbg.location(506, 9)
          push_follow(FOLLOW_integerLiteral_in_literal2565)
          integer_literal
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:507:9: FloatingPointLiteral
          self.attr_dbg.location(507, 9)
          match(self.attr_input, FloatingPointLiteral, FOLLOW_FloatingPointLiteral_in_literal2575)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:508:9: CharacterLiteral
          self.attr_dbg.location(508, 9)
          match(self.attr_input, CharacterLiteral, FOLLOW_CharacterLiteral_in_literal2585)
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:509:9: StringLiteral
          self.attr_dbg.location(509, 9)
          match(self.attr_input, StringLiteral, FOLLOW_StringLiteral_in_literal2595)
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:510:9: booleanLiteral
          self.attr_dbg.location(510, 9)
          push_follow(FOLLOW_booleanLiteral_in_literal2605)
          boolean_literal
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:511:9: 'null'
          self.attr_dbg.location(511, 9)
          match(self.attr_input, 70, FOLLOW_70_in_literal2615)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 67, literal_start_index)
        end
      end
      self.attr_dbg.location(512, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "literal")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "literal"
  # $ANTLR start "integerLiteral"
  # Java.g:514:1: integerLiteral : ( HexLiteral | OctalLiteral | DecimalLiteral );
  def integer_literal
    integer_literal_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "integerLiteral")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(514, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 68))
          return
        end
        # Java.g:515:5: ( HexLiteral | OctalLiteral | DecimalLiteral )
        self.attr_dbg.enter_alt(1)
        # Java.g:
        self.attr_dbg.location(515, 5)
        if ((self.attr_input._la(1) >= HexLiteral && self.attr_input._la(1) <= DecimalLiteral))
          self.attr_input.consume
          self.attr_state.attr_error_recovery = false
          self.attr_state.attr_failed = false
        else
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          mse = MismatchedSetException.new(nil, self.attr_input)
          self.attr_dbg.recognition_exception(mse)
          raise mse
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 68, integer_literal_start_index)
        end
      end
      self.attr_dbg.location(518, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "integerLiteral")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "integerLiteral"
  # $ANTLR start "booleanLiteral"
  # Java.g:520:1: booleanLiteral : ( 'true' | 'false' );
  def boolean_literal
    boolean_literal_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "booleanLiteral")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(520, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 69))
          return
        end
        # Java.g:521:5: ( 'true' | 'false' )
        self.attr_dbg.enter_alt(1)
        # Java.g:
        self.attr_dbg.location(521, 5)
        if ((self.attr_input._la(1) >= 71 && self.attr_input._la(1) <= 72))
          self.attr_input.consume
          self.attr_state.attr_error_recovery = false
          self.attr_state.attr_failed = false
        else
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          mse = MismatchedSetException.new(nil, self.attr_input)
          self.attr_dbg.recognition_exception(mse)
          raise mse
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 69, boolean_literal_start_index)
        end
      end
      self.attr_dbg.location(523, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "booleanLiteral")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "booleanLiteral"
  # $ANTLR start "annotations"
  # Java.g:527:1: annotations : ( annotation )+ ;
  def annotations
    annotations_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotations")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(527, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 70))
          return
        end
        # Java.g:528:5: ( ( annotation )+ )
        self.attr_dbg.enter_alt(1)
        # Java.g:528:9: ( annotation )+
        self.attr_dbg.location(528, 9)
        # Java.g:528:9: ( annotation )+
        cnt88 = 0
        begin
          self.attr_dbg.enter_sub_rule(88)
          begin
            alt88 = 2
            begin
              self.attr_dbg.enter_decision(88)
              la88_0 = self.attr_input._la(1)
              if (((la88_0).equal?(73)))
                la88_2 = self.attr_input._la(2)
                if (((la88_2).equal?(Identifier)))
                  la88_3 = self.attr_input._la(3)
                  if ((synpred128__java))
                    alt88 = 1
                  end
                end
              end
            ensure
              self.attr_dbg.exit_decision(88)
            end
            case (alt88)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: annotation
              self.attr_dbg.location(528, 9)
              push_follow(FOLLOW_annotation_in_annotations2704)
              annotation
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              if (cnt88 >= 1)
                break
              end
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              eee = EarlyExitException.new(88, self.attr_input)
              self.attr_dbg.recognition_exception(eee)
              raise eee
            end
            cnt88 += 1
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(88)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 70, annotations_start_index)
        end
      end
      self.attr_dbg.location(529, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotations")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotations"
  # $ANTLR start "annotation"
  # Java.g:531:1: annotation : '@' annotationName ( '(' ( elementValuePairs | elementValue )? ')' )? ;
  def annotation
    annotation_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotation")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(531, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 71))
          return
        end
        # Java.g:532:5: ( '@' annotationName ( '(' ( elementValuePairs | elementValue )? ')' )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:532:9: '@' annotationName ( '(' ( elementValuePairs | elementValue )? ')' )?
        self.attr_dbg.location(532, 9)
        match(self.attr_input, 73, FOLLOW_73_in_annotation2724)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(532, 13)
        push_follow(FOLLOW_annotationName_in_annotation2726)
        annotation_name
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(532, 28)
        # Java.g:532:28: ( '(' ( elementValuePairs | elementValue )? ')' )?
        alt90 = 2
        begin
          self.attr_dbg.enter_sub_rule(90)
          begin
            self.attr_dbg.enter_decision(90)
            la90_0 = self.attr_input._la(1)
            if (((la90_0).equal?(66)))
              alt90 = 1
            end
          ensure
            self.attr_dbg.exit_decision(90)
          end
          case (alt90)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:532:30: '(' ( elementValuePairs | elementValue )? ')'
            self.attr_dbg.location(532, 30)
            match(self.attr_input, 66, FOLLOW_66_in_annotation2730)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(532, 34)
            # Java.g:532:34: ( elementValuePairs | elementValue )?
            alt89 = 3
            begin
              self.attr_dbg.enter_sub_rule(89)
              begin
                self.attr_dbg.enter_decision(89)
                la89_0 = self.attr_input._la(1)
                if (((la89_0).equal?(Identifier)))
                  la89_1 = self.attr_input._la(2)
                  if (((la89_1).equal?(51)))
                    alt89 = 1
                  else
                    if (((la89_1 >= 29 && la89_1 <= 30) || (la89_1).equal?(40) || (la89_1 >= 42 && la89_1 <= 43) || (la89_1).equal?(48) || (la89_1).equal?(64) || (la89_1 >= 66 && la89_1 <= 67) || (la89_1 >= 98 && la89_1 <= 110)))
                      alt89 = 2
                    end
                  end
                else
                  if (((la89_0 >= FloatingPointLiteral && la89_0 <= DecimalLiteral) || (la89_0).equal?(44) || (la89_0).equal?(47) || (la89_0 >= 56 && la89_0 <= 63) || (la89_0 >= 65 && la89_0 <= 66) || (la89_0 >= 69 && la89_0 <= 73) || (la89_0 >= 105 && la89_0 <= 106) || (la89_0 >= 109 && la89_0 <= 113)))
                    alt89 = 2
                  end
                end
              ensure
                self.attr_dbg.exit_decision(89)
              end
              case (alt89)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:532:36: elementValuePairs
                self.attr_dbg.location(532, 36)
                push_follow(FOLLOW_elementValuePairs_in_annotation2734)
                element_value_pairs
                self.attr_state.attr__fsp -= 1
                if (self.attr_state.attr_failed)
                  return
                end
              when 2
                self.attr_dbg.enter_alt(2)
                # Java.g:532:56: elementValue
                self.attr_dbg.location(532, 56)
                push_follow(FOLLOW_elementValue_in_annotation2738)
                element_value
                self.attr_state.attr__fsp -= 1
                if (self.attr_state.attr_failed)
                  return
                end
              end
            ensure
              self.attr_dbg.exit_sub_rule(89)
            end
            self.attr_dbg.location(532, 72)
            match(self.attr_input, 67, FOLLOW_67_in_annotation2743)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(90)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 71, annotation_start_index)
        end
      end
      self.attr_dbg.location(533, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotation")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotation"
  # $ANTLR start "annotationName"
  # Java.g:535:1: annotationName : Identifier ( '.' Identifier )* ;
  def annotation_name
    annotation_name_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationName")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(535, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 72))
          return
        end
        # Java.g:536:5: ( Identifier ( '.' Identifier )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:536:7: Identifier ( '.' Identifier )*
        self.attr_dbg.location(536, 7)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_annotationName2767)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(536, 18)
        # Java.g:536:18: ( '.' Identifier )*
        begin
          self.attr_dbg.enter_sub_rule(91)
          begin
            alt91 = 2
            begin
              self.attr_dbg.enter_decision(91)
              la91_0 = self.attr_input._la(1)
              if (((la91_0).equal?(29)))
                alt91 = 1
              end
            ensure
              self.attr_dbg.exit_decision(91)
            end
            case (alt91)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:536:19: '.' Identifier
              self.attr_dbg.location(536, 19)
              match(self.attr_input, 29, FOLLOW_29_in_annotationName2770)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(536, 23)
              match(self.attr_input, Identifier, FOLLOW_Identifier_in_annotationName2772)
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(91)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 72, annotation_name_start_index)
        end
      end
      self.attr_dbg.location(537, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationName")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationName"
  # $ANTLR start "elementValuePairs"
  # Java.g:539:1: elementValuePairs : elementValuePair ( ',' elementValuePair )* ;
  def element_value_pairs
    element_value_pairs_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "elementValuePairs")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(539, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 73))
          return
        end
        # Java.g:540:5: ( elementValuePair ( ',' elementValuePair )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:540:9: elementValuePair ( ',' elementValuePair )*
        self.attr_dbg.location(540, 9)
        push_follow(FOLLOW_elementValuePair_in_elementValuePairs2793)
        element_value_pair
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(540, 26)
        # Java.g:540:26: ( ',' elementValuePair )*
        begin
          self.attr_dbg.enter_sub_rule(92)
          begin
            alt92 = 2
            begin
              self.attr_dbg.enter_decision(92)
              la92_0 = self.attr_input._la(1)
              if (((la92_0).equal?(41)))
                alt92 = 1
              end
            ensure
              self.attr_dbg.exit_decision(92)
            end
            case (alt92)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:540:27: ',' elementValuePair
              self.attr_dbg.location(540, 27)
              match(self.attr_input, 41, FOLLOW_41_in_elementValuePairs2796)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(540, 31)
              push_follow(FOLLOW_elementValuePair_in_elementValuePairs2798)
              element_value_pair
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(92)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 73, element_value_pairs_start_index)
        end
      end
      self.attr_dbg.location(541, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "elementValuePairs")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "elementValuePairs"
  # $ANTLR start "elementValuePair"
  # Java.g:543:1: elementValuePair : Identifier '=' elementValue ;
  def element_value_pair
    element_value_pair_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "elementValuePair")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(543, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 74))
          return
        end
        # Java.g:544:5: ( Identifier '=' elementValue )
        self.attr_dbg.enter_alt(1)
        # Java.g:544:9: Identifier '=' elementValue
        self.attr_dbg.location(544, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_elementValuePair2819)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(544, 20)
        match(self.attr_input, 51, FOLLOW_51_in_elementValuePair2821)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(544, 24)
        push_follow(FOLLOW_elementValue_in_elementValuePair2823)
        element_value
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 74, element_value_pair_start_index)
        end
      end
      self.attr_dbg.location(545, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "elementValuePair")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "elementValuePair"
  # $ANTLR start "elementValue"
  # Java.g:547:1: elementValue : ( conditionalExpression | annotation | elementValueArrayInitializer );
  def element_value
    element_value_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "elementValue")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(547, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 75))
          return
        end
        # Java.g:548:5: ( conditionalExpression | annotation | elementValueArrayInitializer )
        alt93 = 3
        begin
          self.attr_dbg.enter_decision(93)
          case (self.attr_input._la(1))
          when Identifier, FloatingPointLiteral, CharacterLiteral, StringLiteral, HexLiteral, OctalLiteral, DecimalLiteral, 47, 56, 57, 58, 59, 60, 61, 62, 63, 65, 66, 69, 70, 71, 72, 105, 106, 109, 110, 111, 112, 113
            alt93 = 1
          when 73
            alt93 = 2
          when 44
            alt93 = 3
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 93, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(93)
        end
        case (alt93)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:548:9: conditionalExpression
          self.attr_dbg.location(548, 9)
          push_follow(FOLLOW_conditionalExpression_in_elementValue2846)
          conditional_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:549:9: annotation
          self.attr_dbg.location(549, 9)
          push_follow(FOLLOW_annotation_in_elementValue2856)
          annotation
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:550:9: elementValueArrayInitializer
          self.attr_dbg.location(550, 9)
          push_follow(FOLLOW_elementValueArrayInitializer_in_elementValue2866)
          element_value_array_initializer
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 75, element_value_start_index)
        end
      end
      self.attr_dbg.location(551, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "elementValue")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "elementValue"
  # $ANTLR start "elementValueArrayInitializer"
  # Java.g:553:1: elementValueArrayInitializer : '{' ( elementValue ( ',' elementValue )* )? ( ',' )? '}' ;
  def element_value_array_initializer
    element_value_array_initializer_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "elementValueArrayInitializer")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(553, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 76))
          return
        end
        # Java.g:554:5: ( '{' ( elementValue ( ',' elementValue )* )? ( ',' )? '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:554:9: '{' ( elementValue ( ',' elementValue )* )? ( ',' )? '}'
        self.attr_dbg.location(554, 9)
        match(self.attr_input, 44, FOLLOW_44_in_elementValueArrayInitializer2889)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(554, 13)
        # Java.g:554:13: ( elementValue ( ',' elementValue )* )?
        alt95 = 2
        begin
          self.attr_dbg.enter_sub_rule(95)
          begin
            self.attr_dbg.enter_decision(95)
            la95_0 = self.attr_input._la(1)
            if (((la95_0).equal?(Identifier) || (la95_0 >= FloatingPointLiteral && la95_0 <= DecimalLiteral) || (la95_0).equal?(44) || (la95_0).equal?(47) || (la95_0 >= 56 && la95_0 <= 63) || (la95_0 >= 65 && la95_0 <= 66) || (la95_0 >= 69 && la95_0 <= 73) || (la95_0 >= 105 && la95_0 <= 106) || (la95_0 >= 109 && la95_0 <= 113)))
              alt95 = 1
            end
          ensure
            self.attr_dbg.exit_decision(95)
          end
          case (alt95)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:554:14: elementValue ( ',' elementValue )*
            self.attr_dbg.location(554, 14)
            push_follow(FOLLOW_elementValue_in_elementValueArrayInitializer2892)
            element_value
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(554, 27)
            # Java.g:554:27: ( ',' elementValue )*
            begin
              self.attr_dbg.enter_sub_rule(94)
              begin
                alt94 = 2
                begin
                  self.attr_dbg.enter_decision(94)
                  la94_0 = self.attr_input._la(1)
                  if (((la94_0).equal?(41)))
                    la94_1 = self.attr_input._la(2)
                    if (((la94_1).equal?(Identifier) || (la94_1 >= FloatingPointLiteral && la94_1 <= DecimalLiteral) || (la94_1).equal?(44) || (la94_1).equal?(47) || (la94_1 >= 56 && la94_1 <= 63) || (la94_1 >= 65 && la94_1 <= 66) || (la94_1 >= 69 && la94_1 <= 73) || (la94_1 >= 105 && la94_1 <= 106) || (la94_1 >= 109 && la94_1 <= 113)))
                      alt94 = 1
                    end
                  end
                ensure
                  self.attr_dbg.exit_decision(94)
                end
                case (alt94)
                when 1
                  self.attr_dbg.enter_alt(1)
                  # Java.g:554:28: ',' elementValue
                  self.attr_dbg.location(554, 28)
                  match(self.attr_input, 41, FOLLOW_41_in_elementValueArrayInitializer2895)
                  if (self.attr_state.attr_failed)
                    return
                  end
                  self.attr_dbg.location(554, 32)
                  push_follow(FOLLOW_elementValue_in_elementValueArrayInitializer2897)
                  element_value
                  self.attr_state.attr__fsp -= 1
                  if (self.attr_state.attr_failed)
                    return
                  end
                else
                  break
                end
              end while (true)
            ensure
              self.attr_dbg.exit_sub_rule(94)
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(95)
        end
        self.attr_dbg.location(554, 49)
        # Java.g:554:49: ( ',' )?
        alt96 = 2
        begin
          self.attr_dbg.enter_sub_rule(96)
          begin
            self.attr_dbg.enter_decision(96)
            la96_0 = self.attr_input._la(1)
            if (((la96_0).equal?(41)))
              alt96 = 1
            end
          ensure
            self.attr_dbg.exit_decision(96)
          end
          case (alt96)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:554:50: ','
            self.attr_dbg.location(554, 50)
            match(self.attr_input, 41, FOLLOW_41_in_elementValueArrayInitializer2904)
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(96)
        end
        self.attr_dbg.location(554, 56)
        match(self.attr_input, 45, FOLLOW_45_in_elementValueArrayInitializer2908)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 76, element_value_array_initializer_start_index)
        end
      end
      self.attr_dbg.location(555, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "elementValueArrayInitializer")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "elementValueArrayInitializer"
  # $ANTLR start "annotationTypeDeclaration"
  # Java.g:557:1: annotationTypeDeclaration : '@' 'interface' Identifier annotationTypeBody ;
  def annotation_type_declaration
    annotation_type_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationTypeDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(557, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 77))
          return
        end
        # Java.g:558:5: ( '@' 'interface' Identifier annotationTypeBody )
        self.attr_dbg.enter_alt(1)
        # Java.g:558:9: '@' 'interface' Identifier annotationTypeBody
        self.attr_dbg.location(558, 9)
        match(self.attr_input, 73, FOLLOW_73_in_annotationTypeDeclaration2931)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(558, 13)
        match(self.attr_input, 46, FOLLOW_46_in_annotationTypeDeclaration2933)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(558, 25)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_annotationTypeDeclaration2935)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(558, 36)
        push_follow(FOLLOW_annotationTypeBody_in_annotationTypeDeclaration2937)
        annotation_type_body
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 77, annotation_type_declaration_start_index)
        end
      end
      self.attr_dbg.location(559, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationTypeDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationTypeDeclaration"
  # $ANTLR start "annotationTypeBody"
  # Java.g:561:1: annotationTypeBody : '{' ( annotationTypeElementDeclaration )* '}' ;
  def annotation_type_body
    annotation_type_body_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationTypeBody")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(561, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 78))
          return
        end
        # Java.g:562:5: ( '{' ( annotationTypeElementDeclaration )* '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:562:9: '{' ( annotationTypeElementDeclaration )* '}'
        self.attr_dbg.location(562, 9)
        match(self.attr_input, 44, FOLLOW_44_in_annotationTypeBody2960)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(562, 13)
        # Java.g:562:13: ( annotationTypeElementDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(97)
          begin
            alt97 = 2
            begin
              self.attr_dbg.enter_decision(97)
              la97_0 = self.attr_input._la(1)
              if (((la97_0 >= Identifier && la97_0 <= ENUM) || (la97_0).equal?(28) || (la97_0 >= 31 && la97_0 <= 37) || (la97_0).equal?(40) || (la97_0 >= 46 && la97_0 <= 47) || (la97_0 >= 52 && la97_0 <= 63) || (la97_0).equal?(73)))
                alt97 = 1
              end
            ensure
              self.attr_dbg.exit_decision(97)
            end
            case (alt97)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:562:14: annotationTypeElementDeclaration
              self.attr_dbg.location(562, 14)
              push_follow(FOLLOW_annotationTypeElementDeclaration_in_annotationTypeBody2963)
              annotation_type_element_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(97)
        end
        self.attr_dbg.location(562, 49)
        match(self.attr_input, 45, FOLLOW_45_in_annotationTypeBody2967)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 78, annotation_type_body_start_index)
        end
      end
      self.attr_dbg.location(563, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationTypeBody")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationTypeBody"
  # $ANTLR start "annotationTypeElementDeclaration"
  # Java.g:565:1: annotationTypeElementDeclaration : modifiers annotationTypeElementRest ;
  def annotation_type_element_declaration
    annotation_type_element_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationTypeElementDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(565, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 79))
          return
        end
        # Java.g:566:5: ( modifiers annotationTypeElementRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:566:9: modifiers annotationTypeElementRest
        self.attr_dbg.location(566, 9)
        push_follow(FOLLOW_modifiers_in_annotationTypeElementDeclaration2990)
        modifiers
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(566, 19)
        push_follow(FOLLOW_annotationTypeElementRest_in_annotationTypeElementDeclaration2992)
        annotation_type_element_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 79, annotation_type_element_declaration_start_index)
        end
      end
      self.attr_dbg.location(567, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationTypeElementDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationTypeElementDeclaration"
  # $ANTLR start "annotationTypeElementRest"
  # Java.g:569:1: annotationTypeElementRest : ( type annotationMethodOrConstantRest ';' | normalClassDeclaration ( ';' )? | normalInterfaceDeclaration ( ';' )? | enumDeclaration ( ';' )? | annotationTypeDeclaration ( ';' )? );
  def annotation_type_element_rest
    annotation_type_element_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationTypeElementRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(569, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 80))
          return
        end
        # Java.g:570:5: ( type annotationMethodOrConstantRest ';' | normalClassDeclaration ( ';' )? | normalInterfaceDeclaration ( ';' )? | enumDeclaration ( ';' )? | annotationTypeDeclaration ( ';' )? )
        alt102 = 5
        begin
          self.attr_dbg.enter_decision(102)
          case (self.attr_input._la(1))
          when Identifier, 56, 57, 58, 59, 60, 61, 62, 63
            alt102 = 1
          when 37
            alt102 = 2
          when 46
            alt102 = 3
          when ENUM
            alt102 = 4
          when 73
            alt102 = 5
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 102, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(102)
        end
        case (alt102)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:570:9: type annotationMethodOrConstantRest ';'
          self.attr_dbg.location(570, 9)
          push_follow(FOLLOW_type_in_annotationTypeElementRest3015)
          type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(570, 14)
          push_follow(FOLLOW_annotationMethodOrConstantRest_in_annotationTypeElementRest3017)
          annotation_method_or_constant_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(570, 45)
          match(self.attr_input, 26, FOLLOW_26_in_annotationTypeElementRest3019)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:571:9: normalClassDeclaration ( ';' )?
          self.attr_dbg.location(571, 9)
          push_follow(FOLLOW_normalClassDeclaration_in_annotationTypeElementRest3029)
          normal_class_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(571, 32)
          # Java.g:571:32: ( ';' )?
          alt98 = 2
          begin
            self.attr_dbg.enter_sub_rule(98)
            begin
              self.attr_dbg.enter_decision(98)
              la98_0 = self.attr_input._la(1)
              if (((la98_0).equal?(26)))
                alt98 = 1
              end
            ensure
              self.attr_dbg.exit_decision(98)
            end
            case (alt98)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: ';'
              self.attr_dbg.location(571, 32)
              match(self.attr_input, 26, FOLLOW_26_in_annotationTypeElementRest3031)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(98)
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:572:9: normalInterfaceDeclaration ( ';' )?
          self.attr_dbg.location(572, 9)
          push_follow(FOLLOW_normalInterfaceDeclaration_in_annotationTypeElementRest3042)
          normal_interface_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(572, 36)
          # Java.g:572:36: ( ';' )?
          alt99 = 2
          begin
            self.attr_dbg.enter_sub_rule(99)
            begin
              self.attr_dbg.enter_decision(99)
              la99_0 = self.attr_input._la(1)
              if (((la99_0).equal?(26)))
                alt99 = 1
              end
            ensure
              self.attr_dbg.exit_decision(99)
            end
            case (alt99)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: ';'
              self.attr_dbg.location(572, 36)
              match(self.attr_input, 26, FOLLOW_26_in_annotationTypeElementRest3044)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(99)
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:573:9: enumDeclaration ( ';' )?
          self.attr_dbg.location(573, 9)
          push_follow(FOLLOW_enumDeclaration_in_annotationTypeElementRest3055)
          enum_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(573, 25)
          # Java.g:573:25: ( ';' )?
          alt100 = 2
          begin
            self.attr_dbg.enter_sub_rule(100)
            begin
              self.attr_dbg.enter_decision(100)
              la100_0 = self.attr_input._la(1)
              if (((la100_0).equal?(26)))
                alt100 = 1
              end
            ensure
              self.attr_dbg.exit_decision(100)
            end
            case (alt100)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: ';'
              self.attr_dbg.location(573, 25)
              match(self.attr_input, 26, FOLLOW_26_in_annotationTypeElementRest3057)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(100)
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:574:9: annotationTypeDeclaration ( ';' )?
          self.attr_dbg.location(574, 9)
          push_follow(FOLLOW_annotationTypeDeclaration_in_annotationTypeElementRest3068)
          annotation_type_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(574, 35)
          # Java.g:574:35: ( ';' )?
          alt101 = 2
          begin
            self.attr_dbg.enter_sub_rule(101)
            begin
              self.attr_dbg.enter_decision(101)
              la101_0 = self.attr_input._la(1)
              if (((la101_0).equal?(26)))
                alt101 = 1
              end
            ensure
              self.attr_dbg.exit_decision(101)
            end
            case (alt101)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: ';'
              self.attr_dbg.location(574, 35)
              match(self.attr_input, 26, FOLLOW_26_in_annotationTypeElementRest3070)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(101)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 80, annotation_type_element_rest_start_index)
        end
      end
      self.attr_dbg.location(575, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationTypeElementRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationTypeElementRest"
  # $ANTLR start "annotationMethodOrConstantRest"
  # Java.g:577:1: annotationMethodOrConstantRest : ( annotationMethodRest | annotationConstantRest );
  def annotation_method_or_constant_rest
    annotation_method_or_constant_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationMethodOrConstantRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(577, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 81))
          return
        end
        # Java.g:578:5: ( annotationMethodRest | annotationConstantRest )
        alt103 = 2
        begin
          self.attr_dbg.enter_decision(103)
          la103_0 = self.attr_input._la(1)
          if (((la103_0).equal?(Identifier)))
            la103_1 = self.attr_input._la(2)
            if (((la103_1).equal?(66)))
              alt103 = 1
            else
              if (((la103_1).equal?(26) || (la103_1).equal?(41) || (la103_1).equal?(48) || (la103_1).equal?(51)))
                alt103 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 103, 1, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 103, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(103)
        end
        case (alt103)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:578:9: annotationMethodRest
          self.attr_dbg.location(578, 9)
          push_follow(FOLLOW_annotationMethodRest_in_annotationMethodOrConstantRest3094)
          annotation_method_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:579:9: annotationConstantRest
          self.attr_dbg.location(579, 9)
          push_follow(FOLLOW_annotationConstantRest_in_annotationMethodOrConstantRest3104)
          annotation_constant_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 81, annotation_method_or_constant_rest_start_index)
        end
      end
      self.attr_dbg.location(580, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationMethodOrConstantRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationMethodOrConstantRest"
  # $ANTLR start "annotationMethodRest"
  # Java.g:582:1: annotationMethodRest : Identifier '(' ')' ( defaultValue )? ;
  def annotation_method_rest
    annotation_method_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationMethodRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(582, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 82))
          return
        end
        # Java.g:583:5: ( Identifier '(' ')' ( defaultValue )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:583:9: Identifier '(' ')' ( defaultValue )?
        self.attr_dbg.location(583, 9)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_annotationMethodRest3127)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(583, 20)
        match(self.attr_input, 66, FOLLOW_66_in_annotationMethodRest3129)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(583, 24)
        match(self.attr_input, 67, FOLLOW_67_in_annotationMethodRest3131)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(583, 28)
        # Java.g:583:28: ( defaultValue )?
        alt104 = 2
        begin
          self.attr_dbg.enter_sub_rule(104)
          begin
            self.attr_dbg.enter_decision(104)
            la104_0 = self.attr_input._la(1)
            if (((la104_0).equal?(74)))
              alt104 = 1
            end
          ensure
            self.attr_dbg.exit_decision(104)
          end
          case (alt104)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: defaultValue
            self.attr_dbg.location(583, 28)
            push_follow(FOLLOW_defaultValue_in_annotationMethodRest3133)
            default_value
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(104)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 82, annotation_method_rest_start_index)
        end
      end
      self.attr_dbg.location(584, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationMethodRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationMethodRest"
  # $ANTLR start "annotationConstantRest"
  # Java.g:586:1: annotationConstantRest : variableDeclarators ;
  def annotation_constant_rest
    annotation_constant_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "annotationConstantRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(586, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 83))
          return
        end
        # Java.g:587:5: ( variableDeclarators )
        self.attr_dbg.enter_alt(1)
        # Java.g:587:9: variableDeclarators
        self.attr_dbg.location(587, 9)
        push_follow(FOLLOW_variableDeclarators_in_annotationConstantRest3157)
        variable_declarators
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 83, annotation_constant_rest_start_index)
        end
      end
      self.attr_dbg.location(588, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "annotationConstantRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "annotationConstantRest"
  # $ANTLR start "defaultValue"
  # Java.g:590:1: defaultValue : 'default' elementValue ;
  def default_value
    default_value_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "defaultValue")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(590, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 84))
          return
        end
        # Java.g:591:5: ( 'default' elementValue )
        self.attr_dbg.enter_alt(1)
        # Java.g:591:9: 'default' elementValue
        self.attr_dbg.location(591, 9)
        match(self.attr_input, 74, FOLLOW_74_in_defaultValue3180)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(591, 19)
        push_follow(FOLLOW_elementValue_in_defaultValue3182)
        element_value
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 84, default_value_start_index)
        end
      end
      self.attr_dbg.location(592, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "defaultValue")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "defaultValue"
  # $ANTLR start "block"
  # Java.g:596:1: block : '{' ( blockStatement )* '}' ;
  def block
    block_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "block")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(596, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 85))
          return
        end
        # Java.g:597:5: ( '{' ( blockStatement )* '}' )
        self.attr_dbg.enter_alt(1)
        # Java.g:597:9: '{' ( blockStatement )* '}'
        self.attr_dbg.location(597, 9)
        match(self.attr_input, 44, FOLLOW_44_in_block3203)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(597, 13)
        # Java.g:597:13: ( blockStatement )*
        begin
          self.attr_dbg.enter_sub_rule(105)
          begin
            alt105 = 2
            begin
              self.attr_dbg.enter_decision(105)
              la105_0 = self.attr_input._la(1)
              if (((la105_0 >= Identifier && la105_0 <= ASSERT) || (la105_0).equal?(26) || (la105_0).equal?(28) || (la105_0 >= 31 && la105_0 <= 37) || (la105_0).equal?(44) || (la105_0 >= 46 && la105_0 <= 47) || (la105_0).equal?(53) || (la105_0 >= 56 && la105_0 <= 63) || (la105_0 >= 65 && la105_0 <= 66) || (la105_0 >= 69 && la105_0 <= 73) || (la105_0).equal?(76) || (la105_0 >= 78 && la105_0 <= 81) || (la105_0 >= 83 && la105_0 <= 87) || (la105_0 >= 105 && la105_0 <= 106) || (la105_0 >= 109 && la105_0 <= 113)))
                alt105 = 1
              end
            ensure
              self.attr_dbg.exit_decision(105)
            end
            case (alt105)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: blockStatement
              self.attr_dbg.location(597, 13)
              push_follow(FOLLOW_blockStatement_in_block3205)
              block_statement
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(105)
        end
        self.attr_dbg.location(597, 29)
        match(self.attr_input, 45, FOLLOW_45_in_block3208)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 85, block_start_index)
        end
      end
      self.attr_dbg.location(598, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "block")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "block"
  # $ANTLR start "blockStatement"
  # Java.g:600:1: blockStatement : ( localVariableDeclarationStatement | classOrInterfaceDeclaration | statement );
  def block_statement
    block_statement_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "blockStatement")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(600, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 86))
          return
        end
        # Java.g:601:5: ( localVariableDeclarationStatement | classOrInterfaceDeclaration | statement )
        alt106 = 3
        begin
          self.attr_dbg.enter_decision(106)
          begin
            self.attr_is_cyclic_decision = true
            alt106 = @dfa106.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(106)
        end
        case (alt106)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:601:9: localVariableDeclarationStatement
          self.attr_dbg.location(601, 9)
          push_follow(FOLLOW_localVariableDeclarationStatement_in_blockStatement3231)
          local_variable_declaration_statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:602:9: classOrInterfaceDeclaration
          self.attr_dbg.location(602, 9)
          push_follow(FOLLOW_classOrInterfaceDeclaration_in_blockStatement3241)
          class_or_interface_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:603:9: statement
          self.attr_dbg.location(603, 9)
          push_follow(FOLLOW_statement_in_blockStatement3251)
          statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 86, block_statement_start_index)
        end
      end
      self.attr_dbg.location(604, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "blockStatement")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "blockStatement"
  # $ANTLR start "localVariableDeclarationStatement"
  # Java.g:606:1: localVariableDeclarationStatement : localVariableDeclaration ';' ;
  def local_variable_declaration_statement
    local_variable_declaration_statement_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "localVariableDeclarationStatement")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(606, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 87))
          return
        end
        # Java.g:607:5: ( localVariableDeclaration ';' )
        self.attr_dbg.enter_alt(1)
        # Java.g:607:10: localVariableDeclaration ';'
        self.attr_dbg.location(607, 10)
        push_follow(FOLLOW_localVariableDeclaration_in_localVariableDeclarationStatement3275)
        local_variable_declaration
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(607, 35)
        match(self.attr_input, 26, FOLLOW_26_in_localVariableDeclarationStatement3277)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 87, local_variable_declaration_statement_start_index)
        end
      end
      self.attr_dbg.location(608, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "localVariableDeclarationStatement")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "localVariableDeclarationStatement"
  # $ANTLR start "localVariableDeclaration"
  # Java.g:610:1: localVariableDeclaration : variableModifiers type variableDeclarators ;
  def local_variable_declaration
    local_variable_declaration_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "localVariableDeclaration")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(610, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 88))
          return
        end
        # Java.g:611:5: ( variableModifiers type variableDeclarators )
        self.attr_dbg.enter_alt(1)
        # Java.g:611:9: variableModifiers type variableDeclarators
        self.attr_dbg.location(611, 9)
        push_follow(FOLLOW_variableModifiers_in_localVariableDeclaration3296)
        variable_modifiers
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(611, 27)
        push_follow(FOLLOW_type_in_localVariableDeclaration3298)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(611, 32)
        push_follow(FOLLOW_variableDeclarators_in_localVariableDeclaration3300)
        variable_declarators
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 88, local_variable_declaration_start_index)
        end
      end
      self.attr_dbg.location(612, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "localVariableDeclaration")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "localVariableDeclaration"
  # $ANTLR start "variableModifiers"
  # Java.g:614:1: variableModifiers : ( variableModifier )* ;
  def variable_modifiers
    variable_modifiers_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "variableModifiers")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(614, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 89))
          return
        end
        # Java.g:615:5: ( ( variableModifier )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:615:9: ( variableModifier )*
        self.attr_dbg.location(615, 9)
        # Java.g:615:9: ( variableModifier )*
        begin
          self.attr_dbg.enter_sub_rule(107)
          begin
            alt107 = 2
            begin
              self.attr_dbg.enter_decision(107)
              la107_0 = self.attr_input._la(1)
              if (((la107_0).equal?(35) || (la107_0).equal?(73)))
                alt107 = 1
              end
            ensure
              self.attr_dbg.exit_decision(107)
            end
            case (alt107)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: variableModifier
              self.attr_dbg.location(615, 9)
              push_follow(FOLLOW_variableModifier_in_variableModifiers3323)
              variable_modifier
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(107)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 89, variable_modifiers_start_index)
        end
      end
      self.attr_dbg.location(616, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "variableModifiers")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "variableModifiers"
  # $ANTLR start "statement"
  # Java.g:618:1: statement : ( block | ASSERT expression ( ':' expression )? ';' | 'if' parExpression statement ( options {k=1; } : 'else' statement )? | 'for' '(' forControl ')' statement | 'while' parExpression statement | 'do' statement 'while' parExpression ';' | 'try' block ( catches 'finally' block | catches | 'finally' block ) | 'switch' parExpression '{' switchBlockStatementGroups '}' | 'synchronized' parExpression block | 'return' ( expression )? ';' | 'throw' expression ';' | 'break' ( Identifier )? ';' | 'continue' ( Identifier )? ';' | ';' | statementExpression ';' | Identifier ':' statement );
  def statement
    statement_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "statement")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(618, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 90))
          return
        end
        # Java.g:619:5: ( block | ASSERT expression ( ':' expression )? ';' | 'if' parExpression statement ( options {k=1; } : 'else' statement )? | 'for' '(' forControl ')' statement | 'while' parExpression statement | 'do' statement 'while' parExpression ';' | 'try' block ( catches 'finally' block | catches | 'finally' block ) | 'switch' parExpression '{' switchBlockStatementGroups '}' | 'synchronized' parExpression block | 'return' ( expression )? ';' | 'throw' expression ';' | 'break' ( Identifier )? ';' | 'continue' ( Identifier )? ';' | ';' | statementExpression ';' | Identifier ':' statement )
        alt114 = 16
        begin
          self.attr_dbg.enter_decision(114)
          begin
            self.attr_is_cyclic_decision = true
            alt114 = @dfa114.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(114)
        end
        case (alt114)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:619:7: block
          self.attr_dbg.location(619, 7)
          push_follow(FOLLOW_block_in_statement3341)
          block
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:620:9: ASSERT expression ( ':' expression )? ';'
          self.attr_dbg.location(620, 9)
          match(self.attr_input, ASSERT, FOLLOW_ASSERT_in_statement3351)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(620, 16)
          push_follow(FOLLOW_expression_in_statement3353)
          expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(620, 27)
          # Java.g:620:27: ( ':' expression )?
          alt108 = 2
          begin
            self.attr_dbg.enter_sub_rule(108)
            begin
              self.attr_dbg.enter_decision(108)
              la108_0 = self.attr_input._la(1)
              if (((la108_0).equal?(75)))
                alt108 = 1
              end
            ensure
              self.attr_dbg.exit_decision(108)
            end
            case (alt108)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:620:28: ':' expression
              self.attr_dbg.location(620, 28)
              match(self.attr_input, 75, FOLLOW_75_in_statement3356)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(620, 32)
              push_follow(FOLLOW_expression_in_statement3358)
              expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(108)
          end
          self.attr_dbg.location(620, 45)
          match(self.attr_input, 26, FOLLOW_26_in_statement3362)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:621:9: 'if' parExpression statement ( options {k=1; } : 'else' statement )?
          self.attr_dbg.location(621, 9)
          match(self.attr_input, 76, FOLLOW_76_in_statement3372)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(621, 14)
          push_follow(FOLLOW_parExpression_in_statement3374)
          par_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(621, 28)
          push_follow(FOLLOW_statement_in_statement3376)
          statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(621, 38)
          # Java.g:621:38: ( options {k=1; } : 'else' statement )?
          alt109 = 2
          begin
            self.attr_dbg.enter_sub_rule(109)
            begin
              self.attr_dbg.enter_decision(109)
              la109_0 = self.attr_input._la(1)
              if (((la109_0).equal?(77)))
                la109_1 = self.attr_input._la(2)
                if ((synpred157__java))
                  alt109 = 1
                end
              end
            ensure
              self.attr_dbg.exit_decision(109)
            end
            case (alt109)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:621:54: 'else' statement
              self.attr_dbg.location(621, 54)
              match(self.attr_input, 77, FOLLOW_77_in_statement3386)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(621, 61)
              push_follow(FOLLOW_statement_in_statement3388)
              statement
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(109)
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:622:9: 'for' '(' forControl ')' statement
          self.attr_dbg.location(622, 9)
          match(self.attr_input, 78, FOLLOW_78_in_statement3400)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(622, 15)
          match(self.attr_input, 66, FOLLOW_66_in_statement3402)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(622, 19)
          push_follow(FOLLOW_forControl_in_statement3404)
          for_control
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(622, 30)
          match(self.attr_input, 67, FOLLOW_67_in_statement3406)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(622, 34)
          push_follow(FOLLOW_statement_in_statement3408)
          statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:623:9: 'while' parExpression statement
          self.attr_dbg.location(623, 9)
          match(self.attr_input, 79, FOLLOW_79_in_statement3418)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(623, 17)
          push_follow(FOLLOW_parExpression_in_statement3420)
          par_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(623, 31)
          push_follow(FOLLOW_statement_in_statement3422)
          statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:624:9: 'do' statement 'while' parExpression ';'
          self.attr_dbg.location(624, 9)
          match(self.attr_input, 80, FOLLOW_80_in_statement3432)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(624, 14)
          push_follow(FOLLOW_statement_in_statement3434)
          statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(624, 24)
          match(self.attr_input, 79, FOLLOW_79_in_statement3436)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(624, 32)
          push_follow(FOLLOW_parExpression_in_statement3438)
          par_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(624, 46)
          match(self.attr_input, 26, FOLLOW_26_in_statement3440)
          if (self.attr_state.attr_failed)
            return
          end
        when 7
          self.attr_dbg.enter_alt(7)
          # Java.g:625:9: 'try' block ( catches 'finally' block | catches | 'finally' block )
          self.attr_dbg.location(625, 9)
          match(self.attr_input, 81, FOLLOW_81_in_statement3450)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(625, 15)
          push_follow(FOLLOW_block_in_statement3452)
          block
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(626, 9)
          # Java.g:626:9: ( catches 'finally' block | catches | 'finally' block )
          alt110 = 3
          begin
            self.attr_dbg.enter_sub_rule(110)
            begin
              self.attr_dbg.enter_decision(110)
              la110_0 = self.attr_input._la(1)
              if (((la110_0).equal?(88)))
                la110_1 = self.attr_input._la(2)
                if ((synpred162__java))
                  alt110 = 1
                else
                  if ((synpred163__java))
                    alt110 = 2
                  else
                    if (self.attr_state.attr_backtracking > 0)
                      self.attr_state.attr_failed = true
                      return
                    end
                    nvae = NoViableAltException.new("", 110, 1, self.attr_input)
                    self.attr_dbg.recognition_exception(nvae)
                    raise nvae
                  end
                end
              else
                if (((la110_0).equal?(82)))
                  alt110 = 3
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 110, 0, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            ensure
              self.attr_dbg.exit_decision(110)
            end
            case (alt110)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:626:11: catches 'finally' block
              self.attr_dbg.location(626, 11)
              push_follow(FOLLOW_catches_in_statement3464)
              catches
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(626, 19)
              match(self.attr_input, 82, FOLLOW_82_in_statement3466)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(626, 29)
              push_follow(FOLLOW_block_in_statement3468)
              block
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            when 2
              self.attr_dbg.enter_alt(2)
              # Java.g:627:11: catches
              self.attr_dbg.location(627, 11)
              push_follow(FOLLOW_catches_in_statement3480)
              catches
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            when 3
              self.attr_dbg.enter_alt(3)
              # Java.g:628:13: 'finally' block
              self.attr_dbg.location(628, 13)
              match(self.attr_input, 82, FOLLOW_82_in_statement3494)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(628, 23)
              push_follow(FOLLOW_block_in_statement3496)
              block
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(110)
          end
        when 8
          self.attr_dbg.enter_alt(8)
          # Java.g:630:9: 'switch' parExpression '{' switchBlockStatementGroups '}'
          self.attr_dbg.location(630, 9)
          match(self.attr_input, 83, FOLLOW_83_in_statement3516)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(630, 18)
          push_follow(FOLLOW_parExpression_in_statement3518)
          par_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(630, 32)
          match(self.attr_input, 44, FOLLOW_44_in_statement3520)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(630, 36)
          push_follow(FOLLOW_switchBlockStatementGroups_in_statement3522)
          switch_block_statement_groups
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(630, 63)
          match(self.attr_input, 45, FOLLOW_45_in_statement3524)
          if (self.attr_state.attr_failed)
            return
          end
        when 9
          self.attr_dbg.enter_alt(9)
          # Java.g:631:9: 'synchronized' parExpression block
          self.attr_dbg.location(631, 9)
          match(self.attr_input, 53, FOLLOW_53_in_statement3534)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(631, 24)
          push_follow(FOLLOW_parExpression_in_statement3536)
          par_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(631, 38)
          push_follow(FOLLOW_block_in_statement3538)
          block
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 10
          self.attr_dbg.enter_alt(10)
          # Java.g:632:9: 'return' ( expression )? ';'
          self.attr_dbg.location(632, 9)
          match(self.attr_input, 84, FOLLOW_84_in_statement3548)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(632, 18)
          # Java.g:632:18: ( expression )?
          alt111 = 2
          begin
            self.attr_dbg.enter_sub_rule(111)
            begin
              self.attr_dbg.enter_decision(111)
              la111_0 = self.attr_input._la(1)
              if (((la111_0).equal?(Identifier) || (la111_0 >= FloatingPointLiteral && la111_0 <= DecimalLiteral) || (la111_0).equal?(47) || (la111_0 >= 56 && la111_0 <= 63) || (la111_0 >= 65 && la111_0 <= 66) || (la111_0 >= 69 && la111_0 <= 72) || (la111_0 >= 105 && la111_0 <= 106) || (la111_0 >= 109 && la111_0 <= 113)))
                alt111 = 1
              end
            ensure
              self.attr_dbg.exit_decision(111)
            end
            case (alt111)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: expression
              self.attr_dbg.location(632, 18)
              push_follow(FOLLOW_expression_in_statement3550)
              expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(111)
          end
          self.attr_dbg.location(632, 30)
          match(self.attr_input, 26, FOLLOW_26_in_statement3553)
          if (self.attr_state.attr_failed)
            return
          end
        when 11
          self.attr_dbg.enter_alt(11)
          # Java.g:633:9: 'throw' expression ';'
          self.attr_dbg.location(633, 9)
          match(self.attr_input, 85, FOLLOW_85_in_statement3563)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(633, 17)
          push_follow(FOLLOW_expression_in_statement3565)
          expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(633, 28)
          match(self.attr_input, 26, FOLLOW_26_in_statement3567)
          if (self.attr_state.attr_failed)
            return
          end
        when 12
          self.attr_dbg.enter_alt(12)
          # Java.g:634:9: 'break' ( Identifier )? ';'
          self.attr_dbg.location(634, 9)
          match(self.attr_input, 86, FOLLOW_86_in_statement3577)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(634, 17)
          # Java.g:634:17: ( Identifier )?
          alt112 = 2
          begin
            self.attr_dbg.enter_sub_rule(112)
            begin
              self.attr_dbg.enter_decision(112)
              la112_0 = self.attr_input._la(1)
              if (((la112_0).equal?(Identifier)))
                alt112 = 1
              end
            ensure
              self.attr_dbg.exit_decision(112)
            end
            case (alt112)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: Identifier
              self.attr_dbg.location(634, 17)
              match(self.attr_input, Identifier, FOLLOW_Identifier_in_statement3579)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(112)
          end
          self.attr_dbg.location(634, 29)
          match(self.attr_input, 26, FOLLOW_26_in_statement3582)
          if (self.attr_state.attr_failed)
            return
          end
        when 13
          self.attr_dbg.enter_alt(13)
          # Java.g:635:9: 'continue' ( Identifier )? ';'
          self.attr_dbg.location(635, 9)
          match(self.attr_input, 87, FOLLOW_87_in_statement3592)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(635, 20)
          # Java.g:635:20: ( Identifier )?
          alt113 = 2
          begin
            self.attr_dbg.enter_sub_rule(113)
            begin
              self.attr_dbg.enter_decision(113)
              la113_0 = self.attr_input._la(1)
              if (((la113_0).equal?(Identifier)))
                alt113 = 1
              end
            ensure
              self.attr_dbg.exit_decision(113)
            end
            case (alt113)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: Identifier
              self.attr_dbg.location(635, 20)
              match(self.attr_input, Identifier, FOLLOW_Identifier_in_statement3594)
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(113)
          end
          self.attr_dbg.location(635, 32)
          match(self.attr_input, 26, FOLLOW_26_in_statement3597)
          if (self.attr_state.attr_failed)
            return
          end
        when 14
          self.attr_dbg.enter_alt(14)
          # Java.g:636:9: ';'
          self.attr_dbg.location(636, 9)
          match(self.attr_input, 26, FOLLOW_26_in_statement3607)
          if (self.attr_state.attr_failed)
            return
          end
        when 15
          self.attr_dbg.enter_alt(15)
          # Java.g:637:9: statementExpression ';'
          self.attr_dbg.location(637, 9)
          push_follow(FOLLOW_statementExpression_in_statement3618)
          statement_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(637, 29)
          match(self.attr_input, 26, FOLLOW_26_in_statement3620)
          if (self.attr_state.attr_failed)
            return
          end
        when 16
          self.attr_dbg.enter_alt(16)
          # Java.g:638:9: Identifier ':' statement
          self.attr_dbg.location(638, 9)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_statement3630)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(638, 20)
          match(self.attr_input, 75, FOLLOW_75_in_statement3632)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(638, 24)
          push_follow(FOLLOW_statement_in_statement3634)
          statement
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 90, statement_start_index)
        end
      end
      self.attr_dbg.location(639, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "statement")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "statement"
  # $ANTLR start "catches"
  # Java.g:641:1: catches : catchClause ( catchClause )* ;
  def catches
    catches_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "catches")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(641, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 91))
          return
        end
        # Java.g:642:5: ( catchClause ( catchClause )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:642:9: catchClause ( catchClause )*
        self.attr_dbg.location(642, 9)
        push_follow(FOLLOW_catchClause_in_catches3657)
        catch_clause
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(642, 21)
        # Java.g:642:21: ( catchClause )*
        begin
          self.attr_dbg.enter_sub_rule(115)
          begin
            alt115 = 2
            begin
              self.attr_dbg.enter_decision(115)
              la115_0 = self.attr_input._la(1)
              if (((la115_0).equal?(88)))
                alt115 = 1
              end
            ensure
              self.attr_dbg.exit_decision(115)
            end
            case (alt115)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:642:22: catchClause
              self.attr_dbg.location(642, 22)
              push_follow(FOLLOW_catchClause_in_catches3660)
              catch_clause
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(115)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 91, catches_start_index)
        end
      end
      self.attr_dbg.location(643, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "catches")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "catches"
  # $ANTLR start "catchClause"
  # Java.g:645:1: catchClause : 'catch' '(' formalParameter ')' block ;
  def catch_clause
    catch_clause_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "catchClause")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(645, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 92))
          return
        end
        # Java.g:646:5: ( 'catch' '(' formalParameter ')' block )
        self.attr_dbg.enter_alt(1)
        # Java.g:646:9: 'catch' '(' formalParameter ')' block
        self.attr_dbg.location(646, 9)
        match(self.attr_input, 88, FOLLOW_88_in_catchClause3685)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(646, 17)
        match(self.attr_input, 66, FOLLOW_66_in_catchClause3687)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(646, 21)
        push_follow(FOLLOW_formalParameter_in_catchClause3689)
        formal_parameter
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(646, 37)
        match(self.attr_input, 67, FOLLOW_67_in_catchClause3691)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(646, 41)
        push_follow(FOLLOW_block_in_catchClause3693)
        block
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 92, catch_clause_start_index)
        end
      end
      self.attr_dbg.location(647, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "catchClause")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "catchClause"
  # $ANTLR start "formalParameter"
  # Java.g:649:1: formalParameter : variableModifiers type variableDeclaratorId ;
  def formal_parameter
    formal_parameter_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "formalParameter")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(649, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 93))
          return
        end
        # Java.g:650:5: ( variableModifiers type variableDeclaratorId )
        self.attr_dbg.enter_alt(1)
        # Java.g:650:9: variableModifiers type variableDeclaratorId
        self.attr_dbg.location(650, 9)
        push_follow(FOLLOW_variableModifiers_in_formalParameter3712)
        variable_modifiers
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(650, 27)
        push_follow(FOLLOW_type_in_formalParameter3714)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(650, 32)
        push_follow(FOLLOW_variableDeclaratorId_in_formalParameter3716)
        variable_declarator_id
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 93, formal_parameter_start_index)
        end
      end
      self.attr_dbg.location(651, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "formalParameter")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "formalParameter"
  # $ANTLR start "switchBlockStatementGroups"
  # Java.g:653:1: switchBlockStatementGroups : ( switchBlockStatementGroup )* ;
  def switch_block_statement_groups
    switch_block_statement_groups_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "switchBlockStatementGroups")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(653, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 94))
          return
        end
        # Java.g:654:5: ( ( switchBlockStatementGroup )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:654:9: ( switchBlockStatementGroup )*
        self.attr_dbg.location(654, 9)
        # Java.g:654:9: ( switchBlockStatementGroup )*
        begin
          self.attr_dbg.enter_sub_rule(116)
          begin
            alt116 = 2
            begin
              self.attr_dbg.enter_decision(116)
              la116_0 = self.attr_input._la(1)
              if (((la116_0).equal?(74) || (la116_0).equal?(89)))
                alt116 = 1
              end
            ensure
              self.attr_dbg.exit_decision(116)
            end
            case (alt116)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:654:10: switchBlockStatementGroup
              self.attr_dbg.location(654, 10)
              push_follow(FOLLOW_switchBlockStatementGroup_in_switchBlockStatementGroups3744)
              switch_block_statement_group
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(116)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 94, switch_block_statement_groups_start_index)
        end
      end
      self.attr_dbg.location(655, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "switchBlockStatementGroups")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "switchBlockStatementGroups"
  # $ANTLR start "switchBlockStatementGroup"
  # Java.g:661:1: switchBlockStatementGroup : ( switchLabel )+ ( blockStatement )* ;
  def switch_block_statement_group
    switch_block_statement_group_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "switchBlockStatementGroup")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(661, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 95))
          return
        end
        # Java.g:662:5: ( ( switchLabel )+ ( blockStatement )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:662:9: ( switchLabel )+ ( blockStatement )*
        self.attr_dbg.location(662, 9)
        # Java.g:662:9: ( switchLabel )+
        cnt117 = 0
        begin
          self.attr_dbg.enter_sub_rule(117)
          begin
            alt117 = 2
            begin
              self.attr_dbg.enter_decision(117)
              la117_0 = self.attr_input._la(1)
              if (((la117_0).equal?(89)))
                la117_2 = self.attr_input._la(2)
                if ((synpred178__java))
                  alt117 = 1
                end
              else
                if (((la117_0).equal?(74)))
                  la117_3 = self.attr_input._la(2)
                  if ((synpred178__java))
                    alt117 = 1
                  end
                end
              end
            ensure
              self.attr_dbg.exit_decision(117)
            end
            case (alt117)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: switchLabel
              self.attr_dbg.location(662, 9)
              push_follow(FOLLOW_switchLabel_in_switchBlockStatementGroup3771)
              switch_label
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              if (cnt117 >= 1)
                break
              end
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              eee = EarlyExitException.new(117, self.attr_input)
              self.attr_dbg.recognition_exception(eee)
              raise eee
            end
            cnt117 += 1
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(117)
        end
        self.attr_dbg.location(662, 22)
        # Java.g:662:22: ( blockStatement )*
        begin
          self.attr_dbg.enter_sub_rule(118)
          begin
            alt118 = 2
            begin
              self.attr_dbg.enter_decision(118)
              la118_0 = self.attr_input._la(1)
              if (((la118_0 >= Identifier && la118_0 <= ASSERT) || (la118_0).equal?(26) || (la118_0).equal?(28) || (la118_0 >= 31 && la118_0 <= 37) || (la118_0).equal?(44) || (la118_0 >= 46 && la118_0 <= 47) || (la118_0).equal?(53) || (la118_0 >= 56 && la118_0 <= 63) || (la118_0 >= 65 && la118_0 <= 66) || (la118_0 >= 69 && la118_0 <= 73) || (la118_0).equal?(76) || (la118_0 >= 78 && la118_0 <= 81) || (la118_0 >= 83 && la118_0 <= 87) || (la118_0 >= 105 && la118_0 <= 106) || (la118_0 >= 109 && la118_0 <= 113)))
                alt118 = 1
              end
            ensure
              self.attr_dbg.exit_decision(118)
            end
            case (alt118)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: blockStatement
              self.attr_dbg.location(662, 22)
              push_follow(FOLLOW_blockStatement_in_switchBlockStatementGroup3774)
              block_statement
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(118)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 95, switch_block_statement_group_start_index)
        end
      end
      self.attr_dbg.location(663, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "switchBlockStatementGroup")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "switchBlockStatementGroup"
  # $ANTLR start "switchLabel"
  # Java.g:665:1: switchLabel : ( 'case' constantExpression ':' | 'case' enumConstantName ':' | 'default' ':' );
  def switch_label
    switch_label_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "switchLabel")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(665, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 96))
          return
        end
        # Java.g:666:5: ( 'case' constantExpression ':' | 'case' enumConstantName ':' | 'default' ':' )
        alt119 = 3
        begin
          self.attr_dbg.enter_decision(119)
          la119_0 = self.attr_input._la(1)
          if (((la119_0).equal?(89)))
            la119_1 = self.attr_input._la(2)
            if (((la119_1).equal?(Identifier)))
              la119_3 = self.attr_input._la(3)
              if (((la119_3).equal?(75)))
                la119_5 = self.attr_input._la(4)
                if ((synpred180__java))
                  alt119 = 1
                else
                  if ((synpred181__java))
                    alt119 = 2
                  else
                    if (self.attr_state.attr_backtracking > 0)
                      self.attr_state.attr_failed = true
                      return
                    end
                    nvae = NoViableAltException.new("", 119, 5, self.attr_input)
                    self.attr_dbg.recognition_exception(nvae)
                    raise nvae
                  end
                end
              else
                if (((la119_3 >= 29 && la119_3 <= 30) || (la119_3).equal?(40) || (la119_3 >= 42 && la119_3 <= 43) || (la119_3).equal?(48) || (la119_3).equal?(51) || (la119_3).equal?(64) || (la119_3).equal?(66) || (la119_3 >= 90 && la119_3 <= 110)))
                  alt119 = 1
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 119, 3, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            else
              if (((la119_1 >= FloatingPointLiteral && la119_1 <= DecimalLiteral) || (la119_1).equal?(47) || (la119_1 >= 56 && la119_1 <= 63) || (la119_1 >= 65 && la119_1 <= 66) || (la119_1 >= 69 && la119_1 <= 72) || (la119_1 >= 105 && la119_1 <= 106) || (la119_1 >= 109 && la119_1 <= 113)))
                alt119 = 1
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 119, 1, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          else
            if (((la119_0).equal?(74)))
              alt119 = 3
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 119, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(119)
        end
        case (alt119)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:666:9: 'case' constantExpression ':'
          self.attr_dbg.location(666, 9)
          match(self.attr_input, 89, FOLLOW_89_in_switchLabel3798)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(666, 16)
          push_follow(FOLLOW_constantExpression_in_switchLabel3800)
          constant_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(666, 35)
          match(self.attr_input, 75, FOLLOW_75_in_switchLabel3802)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:667:9: 'case' enumConstantName ':'
          self.attr_dbg.location(667, 9)
          match(self.attr_input, 89, FOLLOW_89_in_switchLabel3812)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(667, 16)
          push_follow(FOLLOW_enumConstantName_in_switchLabel3814)
          enum_constant_name
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(667, 33)
          match(self.attr_input, 75, FOLLOW_75_in_switchLabel3816)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:668:9: 'default' ':'
          self.attr_dbg.location(668, 9)
          match(self.attr_input, 74, FOLLOW_74_in_switchLabel3826)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(668, 19)
          match(self.attr_input, 75, FOLLOW_75_in_switchLabel3828)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 96, switch_label_start_index)
        end
      end
      self.attr_dbg.location(669, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "switchLabel")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "switchLabel"
  # $ANTLR start "forControl"
  # Java.g:671:1: forControl options {k=3; } : ( enhancedForControl | ( forInit )? ';' ( expression )? ';' ( forUpdate )? );
  def for_control
    for_control_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "forControl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(671, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 97))
          return
        end
        # Java.g:673:5: ( enhancedForControl | ( forInit )? ';' ( expression )? ';' ( forUpdate )? )
        alt123 = 2
        begin
          self.attr_dbg.enter_decision(123)
          begin
            self.attr_is_cyclic_decision = true
            alt123 = @dfa123.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(123)
        end
        case (alt123)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:673:9: enhancedForControl
          self.attr_dbg.location(673, 9)
          push_follow(FOLLOW_enhancedForControl_in_forControl3859)
          enhanced_for_control
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:674:9: ( forInit )? ';' ( expression )? ';' ( forUpdate )?
          self.attr_dbg.location(674, 9)
          # Java.g:674:9: ( forInit )?
          alt120 = 2
          begin
            self.attr_dbg.enter_sub_rule(120)
            begin
              self.attr_dbg.enter_decision(120)
              la120_0 = self.attr_input._la(1)
              if (((la120_0).equal?(Identifier) || (la120_0 >= FloatingPointLiteral && la120_0 <= DecimalLiteral) || (la120_0).equal?(35) || (la120_0).equal?(47) || (la120_0 >= 56 && la120_0 <= 63) || (la120_0 >= 65 && la120_0 <= 66) || (la120_0 >= 69 && la120_0 <= 73) || (la120_0 >= 105 && la120_0 <= 106) || (la120_0 >= 109 && la120_0 <= 113)))
                alt120 = 1
              end
            ensure
              self.attr_dbg.exit_decision(120)
            end
            case (alt120)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: forInit
              self.attr_dbg.location(674, 9)
              push_follow(FOLLOW_forInit_in_forControl3869)
              for_init
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(120)
          end
          self.attr_dbg.location(674, 18)
          match(self.attr_input, 26, FOLLOW_26_in_forControl3872)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(674, 22)
          # Java.g:674:22: ( expression )?
          alt121 = 2
          begin
            self.attr_dbg.enter_sub_rule(121)
            begin
              self.attr_dbg.enter_decision(121)
              la121_0 = self.attr_input._la(1)
              if (((la121_0).equal?(Identifier) || (la121_0 >= FloatingPointLiteral && la121_0 <= DecimalLiteral) || (la121_0).equal?(47) || (la121_0 >= 56 && la121_0 <= 63) || (la121_0 >= 65 && la121_0 <= 66) || (la121_0 >= 69 && la121_0 <= 72) || (la121_0 >= 105 && la121_0 <= 106) || (la121_0 >= 109 && la121_0 <= 113)))
                alt121 = 1
              end
            ensure
              self.attr_dbg.exit_decision(121)
            end
            case (alt121)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: expression
              self.attr_dbg.location(674, 22)
              push_follow(FOLLOW_expression_in_forControl3874)
              expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(121)
          end
          self.attr_dbg.location(674, 34)
          match(self.attr_input, 26, FOLLOW_26_in_forControl3877)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(674, 38)
          # Java.g:674:38: ( forUpdate )?
          alt122 = 2
          begin
            self.attr_dbg.enter_sub_rule(122)
            begin
              self.attr_dbg.enter_decision(122)
              la122_0 = self.attr_input._la(1)
              if (((la122_0).equal?(Identifier) || (la122_0 >= FloatingPointLiteral && la122_0 <= DecimalLiteral) || (la122_0).equal?(47) || (la122_0 >= 56 && la122_0 <= 63) || (la122_0 >= 65 && la122_0 <= 66) || (la122_0 >= 69 && la122_0 <= 72) || (la122_0 >= 105 && la122_0 <= 106) || (la122_0 >= 109 && la122_0 <= 113)))
                alt122 = 1
              end
            ensure
              self.attr_dbg.exit_decision(122)
            end
            case (alt122)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: forUpdate
              self.attr_dbg.location(674, 38)
              push_follow(FOLLOW_forUpdate_in_forControl3879)
              for_update
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(122)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 97, for_control_start_index)
        end
      end
      self.attr_dbg.location(675, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "forControl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "forControl"
  # $ANTLR start "forInit"
  # Java.g:677:1: forInit : ( localVariableDeclaration | expressionList );
  def for_init
    for_init_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "forInit")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(677, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 98))
          return
        end
        # Java.g:678:5: ( localVariableDeclaration | expressionList )
        alt124 = 2
        begin
          self.attr_dbg.enter_decision(124)
          begin
            self.attr_is_cyclic_decision = true
            alt124 = @dfa124.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(124)
        end
        case (alt124)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:678:9: localVariableDeclaration
          self.attr_dbg.location(678, 9)
          push_follow(FOLLOW_localVariableDeclaration_in_forInit3899)
          local_variable_declaration
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:679:9: expressionList
          self.attr_dbg.location(679, 9)
          push_follow(FOLLOW_expressionList_in_forInit3909)
          expression_list
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 98, for_init_start_index)
        end
      end
      self.attr_dbg.location(680, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "forInit")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "forInit"
  # $ANTLR start "enhancedForControl"
  # Java.g:682:1: enhancedForControl : variableModifiers type Identifier ':' expression ;
  def enhanced_for_control
    enhanced_for_control_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "enhancedForControl")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(682, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 99))
          return
        end
        # Java.g:683:5: ( variableModifiers type Identifier ':' expression )
        self.attr_dbg.enter_alt(1)
        # Java.g:683:9: variableModifiers type Identifier ':' expression
        self.attr_dbg.location(683, 9)
        push_follow(FOLLOW_variableModifiers_in_enhancedForControl3932)
        variable_modifiers
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(683, 27)
        push_follow(FOLLOW_type_in_enhancedForControl3934)
        type
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(683, 32)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_enhancedForControl3936)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(683, 43)
        match(self.attr_input, 75, FOLLOW_75_in_enhancedForControl3938)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(683, 47)
        push_follow(FOLLOW_expression_in_enhancedForControl3940)
        expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 99, enhanced_for_control_start_index)
        end
      end
      self.attr_dbg.location(684, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "enhancedForControl")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "enhancedForControl"
  # $ANTLR start "forUpdate"
  # Java.g:686:1: forUpdate : expressionList ;
  def for_update
    for_update_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "forUpdate")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(686, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 100))
          return
        end
        # Java.g:687:5: ( expressionList )
        self.attr_dbg.enter_alt(1)
        # Java.g:687:9: expressionList
        self.attr_dbg.location(687, 9)
        push_follow(FOLLOW_expressionList_in_forUpdate3959)
        expression_list
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 100, for_update_start_index)
        end
      end
      self.attr_dbg.location(688, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "forUpdate")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "forUpdate"
  # $ANTLR start "parExpression"
  # Java.g:692:1: parExpression : '(' expression ')' ;
  def par_expression
    par_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "parExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(692, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 101))
          return
        end
        # Java.g:693:5: ( '(' expression ')' )
        self.attr_dbg.enter_alt(1)
        # Java.g:693:9: '(' expression ')'
        self.attr_dbg.location(693, 9)
        match(self.attr_input, 66, FOLLOW_66_in_parExpression3980)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(693, 13)
        push_follow(FOLLOW_expression_in_parExpression3982)
        expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(693, 24)
        match(self.attr_input, 67, FOLLOW_67_in_parExpression3984)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 101, par_expression_start_index)
        end
      end
      self.attr_dbg.location(694, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "parExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "parExpression"
  # $ANTLR start "expressionList"
  # Java.g:696:1: expressionList : expression ( ',' expression )* ;
  def expression_list
    expression_list_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "expressionList")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(696, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 102))
          return
        end
        # Java.g:697:5: ( expression ( ',' expression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:697:9: expression ( ',' expression )*
        self.attr_dbg.location(697, 9)
        push_follow(FOLLOW_expression_in_expressionList4007)
        expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(697, 20)
        # Java.g:697:20: ( ',' expression )*
        begin
          self.attr_dbg.enter_sub_rule(125)
          begin
            alt125 = 2
            begin
              self.attr_dbg.enter_decision(125)
              la125_0 = self.attr_input._la(1)
              if (((la125_0).equal?(41)))
                alt125 = 1
              end
            ensure
              self.attr_dbg.exit_decision(125)
            end
            case (alt125)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:697:21: ',' expression
              self.attr_dbg.location(697, 21)
              match(self.attr_input, 41, FOLLOW_41_in_expressionList4010)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(697, 25)
              push_follow(FOLLOW_expression_in_expressionList4012)
              expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(125)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 102, expression_list_start_index)
        end
      end
      self.attr_dbg.location(698, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "expressionList")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "expressionList"
  # $ANTLR start "statementExpression"
  # Java.g:700:1: statementExpression : expression ;
  def statement_expression
    statement_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "statementExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(700, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 103))
          return
        end
        # Java.g:701:5: ( expression )
        self.attr_dbg.enter_alt(1)
        # Java.g:701:9: expression
        self.attr_dbg.location(701, 9)
        push_follow(FOLLOW_expression_in_statementExpression4033)
        expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 103, statement_expression_start_index)
        end
      end
      self.attr_dbg.location(702, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "statementExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "statementExpression"
  # $ANTLR start "constantExpression"
  # Java.g:704:1: constantExpression : expression ;
  def constant_expression
    constant_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "constantExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(704, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 104))
          return
        end
        # Java.g:705:5: ( expression )
        self.attr_dbg.enter_alt(1)
        # Java.g:705:9: expression
        self.attr_dbg.location(705, 9)
        push_follow(FOLLOW_expression_in_constantExpression4056)
        expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 104, constant_expression_start_index)
        end
      end
      self.attr_dbg.location(706, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "constantExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "constantExpression"
  # $ANTLR start "expression"
  # Java.g:708:1: expression : conditionalExpression ( assignmentOperator expression )? ;
  def expression
    expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "expression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(708, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 105))
          return
        end
        # Java.g:709:5: ( conditionalExpression ( assignmentOperator expression )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:709:9: conditionalExpression ( assignmentOperator expression )?
        self.attr_dbg.location(709, 9)
        push_follow(FOLLOW_conditionalExpression_in_expression4079)
        conditional_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(709, 31)
        # Java.g:709:31: ( assignmentOperator expression )?
        alt126 = 2
        begin
          self.attr_dbg.enter_sub_rule(126)
          begin
            self.attr_dbg.enter_decision(126)
            begin
              self.attr_is_cyclic_decision = true
              alt126 = @dfa126.predict(self.attr_input)
            rescue NoViableAltException => nvae
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          ensure
            self.attr_dbg.exit_decision(126)
          end
          case (alt126)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:709:32: assignmentOperator expression
            self.attr_dbg.location(709, 32)
            push_follow(FOLLOW_assignmentOperator_in_expression4082)
            assignment_operator
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(709, 51)
            push_follow(FOLLOW_expression_in_expression4084)
            expression
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(126)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 105, expression_start_index)
        end
      end
      self.attr_dbg.location(710, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "expression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "expression"
  # $ANTLR start "assignmentOperator"
  # Java.g:712:1: assignmentOperator : ( '=' | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '^=' | '%=' | ( '<' '<' '=' )=>t1= '<' t2= '<' t3= '=' {...}? | ( '>' '>' '>' '=' )=>t1= '>' t2= '>' t3= '>' t4= '=' {...}? | ( '>' '>' '=' )=>t1= '>' t2= '>' t3= '=' {...}?);
  def assignment_operator
    assignment_operator_start_index = self.attr_input.index
    t1 = nil
    t2 = nil
    t3 = nil
    t4 = nil
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "assignmentOperator")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(712, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 106))
          return
        end
        # Java.g:713:5: ( '=' | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '^=' | '%=' | ( '<' '<' '=' )=>t1= '<' t2= '<' t3= '=' {...}? | ( '>' '>' '>' '=' )=>t1= '>' t2= '>' t3= '>' t4= '=' {...}? | ( '>' '>' '=' )=>t1= '>' t2= '>' t3= '=' {...}?)
        alt127 = 12
        begin
          self.attr_dbg.enter_decision(127)
          begin
            self.attr_is_cyclic_decision = true
            alt127 = @dfa127.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(127)
        end
        case (alt127)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:713:9: '='
          self.attr_dbg.location(713, 9)
          match(self.attr_input, 51, FOLLOW_51_in_assignmentOperator4109)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:714:9: '+='
          self.attr_dbg.location(714, 9)
          match(self.attr_input, 90, FOLLOW_90_in_assignmentOperator4119)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:715:9: '-='
          self.attr_dbg.location(715, 9)
          match(self.attr_input, 91, FOLLOW_91_in_assignmentOperator4129)
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:716:9: '*='
          self.attr_dbg.location(716, 9)
          match(self.attr_input, 92, FOLLOW_92_in_assignmentOperator4139)
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:717:9: '/='
          self.attr_dbg.location(717, 9)
          match(self.attr_input, 93, FOLLOW_93_in_assignmentOperator4149)
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:718:9: '&='
          self.attr_dbg.location(718, 9)
          match(self.attr_input, 94, FOLLOW_94_in_assignmentOperator4159)
          if (self.attr_state.attr_failed)
            return
          end
        when 7
          self.attr_dbg.enter_alt(7)
          # Java.g:719:9: '|='
          self.attr_dbg.location(719, 9)
          match(self.attr_input, 95, FOLLOW_95_in_assignmentOperator4169)
          if (self.attr_state.attr_failed)
            return
          end
        when 8
          self.attr_dbg.enter_alt(8)
          # Java.g:720:9: '^='
          self.attr_dbg.location(720, 9)
          match(self.attr_input, 96, FOLLOW_96_in_assignmentOperator4179)
          if (self.attr_state.attr_failed)
            return
          end
        when 9
          self.attr_dbg.enter_alt(9)
          # Java.g:721:9: '%='
          self.attr_dbg.location(721, 9)
          match(self.attr_input, 97, FOLLOW_97_in_assignmentOperator4189)
          if (self.attr_state.attr_failed)
            return
          end
        when 10
          self.attr_dbg.enter_alt(10)
          # Java.g:722:9: ( '<' '<' '=' )=>t1= '<' t2= '<' t3= '=' {...}?
          self.attr_dbg.location(722, 27)
          t1 = match(self.attr_input, 40, FOLLOW_40_in_assignmentOperator4210)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(722, 34)
          t2 = match(self.attr_input, 40, FOLLOW_40_in_assignmentOperator4214)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(722, 41)
          t3 = match(self.attr_input, 51, FOLLOW_51_in_assignmentOperator4218)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(723, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line) && (t2.get_line).equal?(t3.get_line) && (t2.get_char_position_in_line + 1).equal?(t3.get_char_position_in_line), " $t1.getLine() == $t2.getLine() &&\n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() && \n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "assignmentOperator", " $t1.getLine() == $t2.getLine() &&\n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() && \n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() ")
          end
        when 11
          self.attr_dbg.enter_alt(11)
          # Java.g:727:9: ( '>' '>' '>' '=' )=>t1= '>' t2= '>' t3= '>' t4= '=' {...}?
          self.attr_dbg.location(727, 31)
          t1 = match(self.attr_input, 42, FOLLOW_42_in_assignmentOperator4252)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(727, 38)
          t2 = match(self.attr_input, 42, FOLLOW_42_in_assignmentOperator4256)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(727, 45)
          t3 = match(self.attr_input, 42, FOLLOW_42_in_assignmentOperator4260)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(727, 52)
          t4 = match(self.attr_input, 51, FOLLOW_51_in_assignmentOperator4264)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(728, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line) && (t2.get_line).equal?(t3.get_line) && (t2.get_char_position_in_line + 1).equal?(t3.get_char_position_in_line) && (t3.get_line).equal?(t4.get_line) && (t3.get_char_position_in_line + 1).equal?(t4.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() &&\n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() &&\n          $t3.getLine() == $t4.getLine() && \n          $t3.getCharPositionInLine() + 1 == $t4.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "assignmentOperator", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() &&\n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() &&\n          $t3.getLine() == $t4.getLine() && \n          $t3.getCharPositionInLine() + 1 == $t4.getCharPositionInLine() ")
          end
        when 12
          self.attr_dbg.enter_alt(12)
          # Java.g:734:9: ( '>' '>' '=' )=>t1= '>' t2= '>' t3= '=' {...}?
          self.attr_dbg.location(734, 27)
          t1 = match(self.attr_input, 42, FOLLOW_42_in_assignmentOperator4295)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(734, 34)
          t2 = match(self.attr_input, 42, FOLLOW_42_in_assignmentOperator4299)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(734, 41)
          t3 = match(self.attr_input, 51, FOLLOW_51_in_assignmentOperator4303)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(735, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line) && (t2.get_line).equal?(t3.get_line) && (t2.get_char_position_in_line + 1).equal?(t3.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() && \n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "assignmentOperator", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() && \n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() ")
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 106, assignment_operator_start_index)
        end
      end
      self.attr_dbg.location(739, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "assignmentOperator")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "assignmentOperator"
  # $ANTLR start "conditionalExpression"
  # Java.g:741:1: conditionalExpression : conditionalOrExpression ( '?' expression ':' expression )? ;
  def conditional_expression
    conditional_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "conditionalExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(741, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 107))
          return
        end
        # Java.g:742:5: ( conditionalOrExpression ( '?' expression ':' expression )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:742:9: conditionalOrExpression ( '?' expression ':' expression )?
        self.attr_dbg.location(742, 9)
        push_follow(FOLLOW_conditionalOrExpression_in_conditionalExpression4332)
        conditional_or_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(742, 33)
        # Java.g:742:33: ( '?' expression ':' expression )?
        alt128 = 2
        begin
          self.attr_dbg.enter_sub_rule(128)
          begin
            self.attr_dbg.enter_decision(128)
            la128_0 = self.attr_input._la(1)
            if (((la128_0).equal?(64)))
              alt128 = 1
            end
          ensure
            self.attr_dbg.exit_decision(128)
          end
          case (alt128)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:742:35: '?' expression ':' expression
            self.attr_dbg.location(742, 35)
            match(self.attr_input, 64, FOLLOW_64_in_conditionalExpression4336)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(742, 39)
            push_follow(FOLLOW_expression_in_conditionalExpression4338)
            expression
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(742, 50)
            match(self.attr_input, 75, FOLLOW_75_in_conditionalExpression4340)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(742, 54)
            push_follow(FOLLOW_expression_in_conditionalExpression4342)
            expression
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(128)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 107, conditional_expression_start_index)
        end
      end
      self.attr_dbg.location(743, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "conditionalExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "conditionalExpression"
  # $ANTLR start "conditionalOrExpression"
  # Java.g:745:1: conditionalOrExpression : conditionalAndExpression ( '||' conditionalAndExpression )* ;
  def conditional_or_expression
    conditional_or_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "conditionalOrExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(745, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 108))
          return
        end
        # Java.g:746:5: ( conditionalAndExpression ( '||' conditionalAndExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:746:9: conditionalAndExpression ( '||' conditionalAndExpression )*
        self.attr_dbg.location(746, 9)
        push_follow(FOLLOW_conditionalAndExpression_in_conditionalOrExpression4364)
        conditional_and_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(746, 34)
        # Java.g:746:34: ( '||' conditionalAndExpression )*
        begin
          self.attr_dbg.enter_sub_rule(129)
          begin
            alt129 = 2
            begin
              self.attr_dbg.enter_decision(129)
              la129_0 = self.attr_input._la(1)
              if (((la129_0).equal?(98)))
                alt129 = 1
              end
            ensure
              self.attr_dbg.exit_decision(129)
            end
            case (alt129)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:746:36: '||' conditionalAndExpression
              self.attr_dbg.location(746, 36)
              match(self.attr_input, 98, FOLLOW_98_in_conditionalOrExpression4368)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(746, 41)
              push_follow(FOLLOW_conditionalAndExpression_in_conditionalOrExpression4370)
              conditional_and_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(129)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 108, conditional_or_expression_start_index)
        end
      end
      self.attr_dbg.location(747, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "conditionalOrExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "conditionalOrExpression"
  # $ANTLR start "conditionalAndExpression"
  # Java.g:749:1: conditionalAndExpression : inclusiveOrExpression ( '&&' inclusiveOrExpression )* ;
  def conditional_and_expression
    conditional_and_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "conditionalAndExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(749, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 109))
          return
        end
        # Java.g:750:5: ( inclusiveOrExpression ( '&&' inclusiveOrExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:750:9: inclusiveOrExpression ( '&&' inclusiveOrExpression )*
        self.attr_dbg.location(750, 9)
        push_follow(FOLLOW_inclusiveOrExpression_in_conditionalAndExpression4392)
        inclusive_or_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(750, 31)
        # Java.g:750:31: ( '&&' inclusiveOrExpression )*
        begin
          self.attr_dbg.enter_sub_rule(130)
          begin
            alt130 = 2
            begin
              self.attr_dbg.enter_decision(130)
              la130_0 = self.attr_input._la(1)
              if (((la130_0).equal?(99)))
                alt130 = 1
              end
            ensure
              self.attr_dbg.exit_decision(130)
            end
            case (alt130)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:750:33: '&&' inclusiveOrExpression
              self.attr_dbg.location(750, 33)
              match(self.attr_input, 99, FOLLOW_99_in_conditionalAndExpression4396)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(750, 38)
              push_follow(FOLLOW_inclusiveOrExpression_in_conditionalAndExpression4398)
              inclusive_or_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(130)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 109, conditional_and_expression_start_index)
        end
      end
      self.attr_dbg.location(751, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "conditionalAndExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "conditionalAndExpression"
  # $ANTLR start "inclusiveOrExpression"
  # Java.g:753:1: inclusiveOrExpression : exclusiveOrExpression ( '|' exclusiveOrExpression )* ;
  def inclusive_or_expression
    inclusive_or_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "inclusiveOrExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(753, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 110))
          return
        end
        # Java.g:754:5: ( exclusiveOrExpression ( '|' exclusiveOrExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:754:9: exclusiveOrExpression ( '|' exclusiveOrExpression )*
        self.attr_dbg.location(754, 9)
        push_follow(FOLLOW_exclusiveOrExpression_in_inclusiveOrExpression4420)
        exclusive_or_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(754, 31)
        # Java.g:754:31: ( '|' exclusiveOrExpression )*
        begin
          self.attr_dbg.enter_sub_rule(131)
          begin
            alt131 = 2
            begin
              self.attr_dbg.enter_decision(131)
              la131_0 = self.attr_input._la(1)
              if (((la131_0).equal?(100)))
                alt131 = 1
              end
            ensure
              self.attr_dbg.exit_decision(131)
            end
            case (alt131)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:754:33: '|' exclusiveOrExpression
              self.attr_dbg.location(754, 33)
              match(self.attr_input, 100, FOLLOW_100_in_inclusiveOrExpression4424)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(754, 37)
              push_follow(FOLLOW_exclusiveOrExpression_in_inclusiveOrExpression4426)
              exclusive_or_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(131)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 110, inclusive_or_expression_start_index)
        end
      end
      self.attr_dbg.location(755, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "inclusiveOrExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "inclusiveOrExpression"
  # $ANTLR start "exclusiveOrExpression"
  # Java.g:757:1: exclusiveOrExpression : andExpression ( '^' andExpression )* ;
  def exclusive_or_expression
    exclusive_or_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "exclusiveOrExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(757, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 111))
          return
        end
        # Java.g:758:5: ( andExpression ( '^' andExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:758:9: andExpression ( '^' andExpression )*
        self.attr_dbg.location(758, 9)
        push_follow(FOLLOW_andExpression_in_exclusiveOrExpression4448)
        and_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(758, 23)
        # Java.g:758:23: ( '^' andExpression )*
        begin
          self.attr_dbg.enter_sub_rule(132)
          begin
            alt132 = 2
            begin
              self.attr_dbg.enter_decision(132)
              la132_0 = self.attr_input._la(1)
              if (((la132_0).equal?(101)))
                alt132 = 1
              end
            ensure
              self.attr_dbg.exit_decision(132)
            end
            case (alt132)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:758:25: '^' andExpression
              self.attr_dbg.location(758, 25)
              match(self.attr_input, 101, FOLLOW_101_in_exclusiveOrExpression4452)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(758, 29)
              push_follow(FOLLOW_andExpression_in_exclusiveOrExpression4454)
              and_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(132)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 111, exclusive_or_expression_start_index)
        end
      end
      self.attr_dbg.location(759, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "exclusiveOrExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "exclusiveOrExpression"
  # $ANTLR start "andExpression"
  # Java.g:761:1: andExpression : equalityExpression ( '&' equalityExpression )* ;
  def and_expression
    and_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "andExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(761, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 112))
          return
        end
        # Java.g:762:5: ( equalityExpression ( '&' equalityExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:762:9: equalityExpression ( '&' equalityExpression )*
        self.attr_dbg.location(762, 9)
        push_follow(FOLLOW_equalityExpression_in_andExpression4476)
        equality_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(762, 28)
        # Java.g:762:28: ( '&' equalityExpression )*
        begin
          self.attr_dbg.enter_sub_rule(133)
          begin
            alt133 = 2
            begin
              self.attr_dbg.enter_decision(133)
              la133_0 = self.attr_input._la(1)
              if (((la133_0).equal?(43)))
                alt133 = 1
              end
            ensure
              self.attr_dbg.exit_decision(133)
            end
            case (alt133)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:762:30: '&' equalityExpression
              self.attr_dbg.location(762, 30)
              match(self.attr_input, 43, FOLLOW_43_in_andExpression4480)
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(762, 34)
              push_follow(FOLLOW_equalityExpression_in_andExpression4482)
              equality_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(133)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 112, and_expression_start_index)
        end
      end
      self.attr_dbg.location(763, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "andExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "andExpression"
  # $ANTLR start "equalityExpression"
  # Java.g:765:1: equalityExpression : instanceOfExpression ( ( '==' | '!=' ) instanceOfExpression )* ;
  def equality_expression
    equality_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "equalityExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(765, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 113))
          return
        end
        # Java.g:766:5: ( instanceOfExpression ( ( '==' | '!=' ) instanceOfExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:766:9: instanceOfExpression ( ( '==' | '!=' ) instanceOfExpression )*
        self.attr_dbg.location(766, 9)
        push_follow(FOLLOW_instanceOfExpression_in_equalityExpression4504)
        instance_of_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(766, 30)
        # Java.g:766:30: ( ( '==' | '!=' ) instanceOfExpression )*
        begin
          self.attr_dbg.enter_sub_rule(134)
          begin
            alt134 = 2
            begin
              self.attr_dbg.enter_decision(134)
              la134_0 = self.attr_input._la(1)
              if (((la134_0 >= 102 && la134_0 <= 103)))
                alt134 = 1
              end
            ensure
              self.attr_dbg.exit_decision(134)
            end
            case (alt134)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:766:32: ( '==' | '!=' ) instanceOfExpression
              self.attr_dbg.location(766, 32)
              if ((self.attr_input._la(1) >= 102 && self.attr_input._la(1) <= 103))
                self.attr_input.consume
                self.attr_state.attr_error_recovery = false
                self.attr_state.attr_failed = false
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                mse = MismatchedSetException.new(nil, self.attr_input)
                self.attr_dbg.recognition_exception(mse)
                raise mse
              end
              self.attr_dbg.location(766, 46)
              push_follow(FOLLOW_instanceOfExpression_in_equalityExpression4516)
              instance_of_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(134)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 113, equality_expression_start_index)
        end
      end
      self.attr_dbg.location(767, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "equalityExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "equalityExpression"
  # $ANTLR start "instanceOfExpression"
  # Java.g:769:1: instanceOfExpression : relationalExpression ( 'instanceof' type )? ;
  def instance_of_expression
    instance_of_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "instanceOfExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(769, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 114))
          return
        end
        # Java.g:770:5: ( relationalExpression ( 'instanceof' type )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:770:9: relationalExpression ( 'instanceof' type )?
        self.attr_dbg.location(770, 9)
        push_follow(FOLLOW_relationalExpression_in_instanceOfExpression4538)
        relational_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(770, 30)
        # Java.g:770:30: ( 'instanceof' type )?
        alt135 = 2
        begin
          self.attr_dbg.enter_sub_rule(135)
          begin
            self.attr_dbg.enter_decision(135)
            la135_0 = self.attr_input._la(1)
            if (((la135_0).equal?(104)))
              alt135 = 1
            end
          ensure
            self.attr_dbg.exit_decision(135)
          end
          case (alt135)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:770:31: 'instanceof' type
            self.attr_dbg.location(770, 31)
            match(self.attr_input, 104, FOLLOW_104_in_instanceOfExpression4541)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(770, 44)
            push_follow(FOLLOW_type_in_instanceOfExpression4543)
            type
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(135)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 114, instance_of_expression_start_index)
        end
      end
      self.attr_dbg.location(771, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "instanceOfExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "instanceOfExpression"
  # $ANTLR start "relationalExpression"
  # Java.g:773:1: relationalExpression : shiftExpression ( relationalOp shiftExpression )* ;
  def relational_expression
    relational_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "relationalExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(773, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 115))
          return
        end
        # Java.g:774:5: ( shiftExpression ( relationalOp shiftExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:774:9: shiftExpression ( relationalOp shiftExpression )*
        self.attr_dbg.location(774, 9)
        push_follow(FOLLOW_shiftExpression_in_relationalExpression4564)
        shift_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(774, 25)
        # Java.g:774:25: ( relationalOp shiftExpression )*
        begin
          self.attr_dbg.enter_sub_rule(136)
          begin
            alt136 = 2
            begin
              self.attr_dbg.enter_decision(136)
              la136_0 = self.attr_input._la(1)
              if (((la136_0).equal?(40)))
                la136_2 = self.attr_input._la(2)
                if (((la136_2).equal?(Identifier) || (la136_2 >= FloatingPointLiteral && la136_2 <= DecimalLiteral) || (la136_2).equal?(47) || (la136_2).equal?(51) || (la136_2 >= 56 && la136_2 <= 63) || (la136_2 >= 65 && la136_2 <= 66) || (la136_2 >= 69 && la136_2 <= 72) || (la136_2 >= 105 && la136_2 <= 106) || (la136_2 >= 109 && la136_2 <= 113)))
                  alt136 = 1
                end
              else
                if (((la136_0).equal?(42)))
                  la136_3 = self.attr_input._la(2)
                  if (((la136_3).equal?(Identifier) || (la136_3 >= FloatingPointLiteral && la136_3 <= DecimalLiteral) || (la136_3).equal?(47) || (la136_3).equal?(51) || (la136_3 >= 56 && la136_3 <= 63) || (la136_3 >= 65 && la136_3 <= 66) || (la136_3 >= 69 && la136_3 <= 72) || (la136_3 >= 105 && la136_3 <= 106) || (la136_3 >= 109 && la136_3 <= 113)))
                    alt136 = 1
                  end
                end
              end
            ensure
              self.attr_dbg.exit_decision(136)
            end
            case (alt136)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:774:27: relationalOp shiftExpression
              self.attr_dbg.location(774, 27)
              push_follow(FOLLOW_relationalOp_in_relationalExpression4568)
              relational_op
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(774, 40)
              push_follow(FOLLOW_shiftExpression_in_relationalExpression4570)
              shift_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(136)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 115, relational_expression_start_index)
        end
      end
      self.attr_dbg.location(775, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "relationalExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "relationalExpression"
  # $ANTLR start "relationalOp"
  # Java.g:777:1: relationalOp : ( ( '<' '=' )=>t1= '<' t2= '=' {...}? | ( '>' '=' )=>t1= '>' t2= '=' {...}? | '<' | '>' );
  def relational_op
    relational_op_start_index = self.attr_input.index
    t1 = nil
    t2 = nil
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "relationalOp")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(777, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 116))
          return
        end
        # Java.g:778:5: ( ( '<' '=' )=>t1= '<' t2= '=' {...}? | ( '>' '=' )=>t1= '>' t2= '=' {...}? | '<' | '>' )
        alt137 = 4
        begin
          self.attr_dbg.enter_decision(137)
          la137_0 = self.attr_input._la(1)
          if (((la137_0).equal?(40)))
            la137_1 = self.attr_input._la(2)
            if (((la137_1).equal?(51)) && (synpred211__java))
              alt137 = 1
            else
              if (((la137_1).equal?(Identifier) || (la137_1 >= FloatingPointLiteral && la137_1 <= DecimalLiteral) || (la137_1).equal?(47) || (la137_1 >= 56 && la137_1 <= 63) || (la137_1 >= 65 && la137_1 <= 66) || (la137_1 >= 69 && la137_1 <= 72) || (la137_1 >= 105 && la137_1 <= 106) || (la137_1 >= 109 && la137_1 <= 113)))
                alt137 = 3
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 137, 1, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          else
            if (((la137_0).equal?(42)))
              la137_2 = self.attr_input._la(2)
              if (((la137_2).equal?(51)) && (synpred212__java))
                alt137 = 2
              else
                if (((la137_2).equal?(Identifier) || (la137_2 >= FloatingPointLiteral && la137_2 <= DecimalLiteral) || (la137_2).equal?(47) || (la137_2 >= 56 && la137_2 <= 63) || (la137_2 >= 65 && la137_2 <= 66) || (la137_2 >= 69 && la137_2 <= 72) || (la137_2 >= 105 && la137_2 <= 106) || (la137_2 >= 109 && la137_2 <= 113)))
                  alt137 = 4
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 137, 2, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 137, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(137)
        end
        case (alt137)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:778:9: ( '<' '=' )=>t1= '<' t2= '=' {...}?
          self.attr_dbg.location(778, 23)
          t1 = match(self.attr_input, 40, FOLLOW_40_in_relationalOp4605)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(778, 30)
          t2 = match(self.attr_input, 51, FOLLOW_51_in_relationalOp4609)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(779, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "relationalOp", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:781:9: ( '>' '=' )=>t1= '>' t2= '=' {...}?
          self.attr_dbg.location(781, 23)
          t1 = match(self.attr_input, 42, FOLLOW_42_in_relationalOp4639)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(781, 30)
          t2 = match(self.attr_input, 51, FOLLOW_51_in_relationalOp4643)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(782, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "relationalOp", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:784:9: '<'
          self.attr_dbg.location(784, 9)
          match(self.attr_input, 40, FOLLOW_40_in_relationalOp4664)
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:785:9: '>'
          self.attr_dbg.location(785, 9)
          match(self.attr_input, 42, FOLLOW_42_in_relationalOp4675)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 116, relational_op_start_index)
        end
      end
      self.attr_dbg.location(786, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "relationalOp")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "relationalOp"
  # $ANTLR start "shiftExpression"
  # Java.g:788:1: shiftExpression : additiveExpression ( shiftOp additiveExpression )* ;
  def shift_expression
    shift_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "shiftExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(788, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 117))
          return
        end
        # Java.g:789:5: ( additiveExpression ( shiftOp additiveExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:789:9: additiveExpression ( shiftOp additiveExpression )*
        self.attr_dbg.location(789, 9)
        push_follow(FOLLOW_additiveExpression_in_shiftExpression4695)
        additive_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(789, 28)
        # Java.g:789:28: ( shiftOp additiveExpression )*
        begin
          self.attr_dbg.enter_sub_rule(138)
          begin
            alt138 = 2
            begin
              self.attr_dbg.enter_decision(138)
              la138_0 = self.attr_input._la(1)
              if (((la138_0).equal?(40)))
                la138_1 = self.attr_input._la(2)
                if (((la138_1).equal?(40)))
                  la138_4 = self.attr_input._la(3)
                  if (((la138_4).equal?(Identifier) || (la138_4 >= FloatingPointLiteral && la138_4 <= DecimalLiteral) || (la138_4).equal?(47) || (la138_4 >= 56 && la138_4 <= 63) || (la138_4 >= 65 && la138_4 <= 66) || (la138_4 >= 69 && la138_4 <= 72) || (la138_4 >= 105 && la138_4 <= 106) || (la138_4 >= 109 && la138_4 <= 113)))
                    alt138 = 1
                  end
                end
              else
                if (((la138_0).equal?(42)))
                  la138_2 = self.attr_input._la(2)
                  if (((la138_2).equal?(42)))
                    la138_5 = self.attr_input._la(3)
                    if (((la138_5).equal?(42)))
                      la138_7 = self.attr_input._la(4)
                      if (((la138_7).equal?(Identifier) || (la138_7 >= FloatingPointLiteral && la138_7 <= DecimalLiteral) || (la138_7).equal?(47) || (la138_7 >= 56 && la138_7 <= 63) || (la138_7 >= 65 && la138_7 <= 66) || (la138_7 >= 69 && la138_7 <= 72) || (la138_7 >= 105 && la138_7 <= 106) || (la138_7 >= 109 && la138_7 <= 113)))
                        alt138 = 1
                      end
                    else
                      if (((la138_5).equal?(Identifier) || (la138_5 >= FloatingPointLiteral && la138_5 <= DecimalLiteral) || (la138_5).equal?(47) || (la138_5 >= 56 && la138_5 <= 63) || (la138_5 >= 65 && la138_5 <= 66) || (la138_5 >= 69 && la138_5 <= 72) || (la138_5 >= 105 && la138_5 <= 106) || (la138_5 >= 109 && la138_5 <= 113)))
                        alt138 = 1
                      end
                    end
                  end
                end
              end
            ensure
              self.attr_dbg.exit_decision(138)
            end
            case (alt138)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:789:30: shiftOp additiveExpression
              self.attr_dbg.location(789, 30)
              push_follow(FOLLOW_shiftOp_in_shiftExpression4699)
              shift_op
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
              self.attr_dbg.location(789, 38)
              push_follow(FOLLOW_additiveExpression_in_shiftExpression4701)
              additive_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(138)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 117, shift_expression_start_index)
        end
      end
      self.attr_dbg.location(790, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "shiftExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "shiftExpression"
  # $ANTLR start "shiftOp"
  # Java.g:792:1: shiftOp : ( ( '<' '<' )=>t1= '<' t2= '<' {...}? | ( '>' '>' '>' )=>t1= '>' t2= '>' t3= '>' {...}? | ( '>' '>' )=>t1= '>' t2= '>' {...}?);
  def shift_op
    shift_op_start_index = self.attr_input.index
    t1 = nil
    t2 = nil
    t3 = nil
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "shiftOp")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(792, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 118))
          return
        end
        # Java.g:793:5: ( ( '<' '<' )=>t1= '<' t2= '<' {...}? | ( '>' '>' '>' )=>t1= '>' t2= '>' t3= '>' {...}? | ( '>' '>' )=>t1= '>' t2= '>' {...}?)
        alt139 = 3
        begin
          self.attr_dbg.enter_decision(139)
          begin
            self.attr_is_cyclic_decision = true
            alt139 = @dfa139.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(139)
        end
        case (alt139)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:793:9: ( '<' '<' )=>t1= '<' t2= '<' {...}?
          self.attr_dbg.location(793, 23)
          t1 = match(self.attr_input, 40, FOLLOW_40_in_shiftOp4732)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(793, 30)
          t2 = match(self.attr_input, 40, FOLLOW_40_in_shiftOp4736)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(794, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "shiftOp", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:796:9: ( '>' '>' '>' )=>t1= '>' t2= '>' t3= '>' {...}?
          self.attr_dbg.location(796, 27)
          t1 = match(self.attr_input, 42, FOLLOW_42_in_shiftOp4768)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(796, 34)
          t2 = match(self.attr_input, 42, FOLLOW_42_in_shiftOp4772)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(796, 41)
          t3 = match(self.attr_input, 42, FOLLOW_42_in_shiftOp4776)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(797, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line) && (t2.get_line).equal?(t3.get_line) && (t2.get_char_position_in_line + 1).equal?(t3.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() &&\n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "shiftOp", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() &&\n          $t2.getLine() == $t3.getLine() && \n          $t2.getCharPositionInLine() + 1 == $t3.getCharPositionInLine() ")
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:801:9: ( '>' '>' )=>t1= '>' t2= '>' {...}?
          self.attr_dbg.location(801, 23)
          t1 = match(self.attr_input, 42, FOLLOW_42_in_shiftOp4806)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(801, 30)
          t2 = match(self.attr_input, 42, FOLLOW_42_in_shiftOp4810)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(802, 9)
          if (!(eval_predicate((t1.get_line).equal?(t2.get_line) && (t1.get_char_position_in_line + 1).equal?(t2.get_char_position_in_line), " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")))
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            raise FailedPredicateException.new(self.attr_input, "shiftOp", " $t1.getLine() == $t2.getLine() && \n          $t1.getCharPositionInLine() + 1 == $t2.getCharPositionInLine() ")
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 118, shift_op_start_index)
        end
      end
      self.attr_dbg.location(804, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "shiftOp")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "shiftOp"
  # $ANTLR start "additiveExpression"
  # Java.g:807:1: additiveExpression : multiplicativeExpression ( ( '+' | '-' ) multiplicativeExpression )* ;
  def additive_expression
    additive_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "additiveExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(807, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 119))
          return
        end
        # Java.g:808:5: ( multiplicativeExpression ( ( '+' | '-' ) multiplicativeExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:808:9: multiplicativeExpression ( ( '+' | '-' ) multiplicativeExpression )*
        self.attr_dbg.location(808, 9)
        push_follow(FOLLOW_multiplicativeExpression_in_additiveExpression4840)
        multiplicative_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(808, 34)
        # Java.g:808:34: ( ( '+' | '-' ) multiplicativeExpression )*
        begin
          self.attr_dbg.enter_sub_rule(140)
          begin
            alt140 = 2
            begin
              self.attr_dbg.enter_decision(140)
              la140_0 = self.attr_input._la(1)
              if (((la140_0 >= 105 && la140_0 <= 106)))
                alt140 = 1
              end
            ensure
              self.attr_dbg.exit_decision(140)
            end
            case (alt140)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:808:36: ( '+' | '-' ) multiplicativeExpression
              self.attr_dbg.location(808, 36)
              if ((self.attr_input._la(1) >= 105 && self.attr_input._la(1) <= 106))
                self.attr_input.consume
                self.attr_state.attr_error_recovery = false
                self.attr_state.attr_failed = false
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                mse = MismatchedSetException.new(nil, self.attr_input)
                self.attr_dbg.recognition_exception(mse)
                raise mse
              end
              self.attr_dbg.location(808, 48)
              push_follow(FOLLOW_multiplicativeExpression_in_additiveExpression4852)
              multiplicative_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(140)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 119, additive_expression_start_index)
        end
      end
      self.attr_dbg.location(809, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "additiveExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "additiveExpression"
  # $ANTLR start "multiplicativeExpression"
  # Java.g:811:1: multiplicativeExpression : unaryExpression ( ( '*' | '/' | '%' ) unaryExpression )* ;
  def multiplicative_expression
    multiplicative_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "multiplicativeExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(811, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 120))
          return
        end
        # Java.g:812:5: ( unaryExpression ( ( '*' | '/' | '%' ) unaryExpression )* )
        self.attr_dbg.enter_alt(1)
        # Java.g:812:9: unaryExpression ( ( '*' | '/' | '%' ) unaryExpression )*
        self.attr_dbg.location(812, 9)
        push_follow(FOLLOW_unaryExpression_in_multiplicativeExpression4874)
        unary_expression
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(812, 25)
        # Java.g:812:25: ( ( '*' | '/' | '%' ) unaryExpression )*
        begin
          self.attr_dbg.enter_sub_rule(141)
          begin
            alt141 = 2
            begin
              self.attr_dbg.enter_decision(141)
              la141_0 = self.attr_input._la(1)
              if (((la141_0).equal?(30) || (la141_0 >= 107 && la141_0 <= 108)))
                alt141 = 1
              end
            ensure
              self.attr_dbg.exit_decision(141)
            end
            case (alt141)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:812:27: ( '*' | '/' | '%' ) unaryExpression
              self.attr_dbg.location(812, 27)
              if ((self.attr_input._la(1)).equal?(30) || (self.attr_input._la(1) >= 107 && self.attr_input._la(1) <= 108))
                self.attr_input.consume
                self.attr_state.attr_error_recovery = false
                self.attr_state.attr_failed = false
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                mse = MismatchedSetException.new(nil, self.attr_input)
                self.attr_dbg.recognition_exception(mse)
                raise mse
              end
              self.attr_dbg.location(812, 47)
              push_follow(FOLLOW_unaryExpression_in_multiplicativeExpression4892)
              unary_expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(141)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 120, multiplicative_expression_start_index)
        end
      end
      self.attr_dbg.location(813, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "multiplicativeExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "multiplicativeExpression"
  # $ANTLR start "unaryExpression"
  # Java.g:815:1: unaryExpression : ( '+' unaryExpression | '-' unaryExpression | '++' unaryExpression | '--' unaryExpression | unaryExpressionNotPlusMinus );
  def unary_expression
    unary_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "unaryExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(815, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 121))
          return
        end
        # Java.g:816:5: ( '+' unaryExpression | '-' unaryExpression | '++' unaryExpression | '--' unaryExpression | unaryExpressionNotPlusMinus )
        alt142 = 5
        begin
          self.attr_dbg.enter_decision(142)
          case (self.attr_input._la(1))
          when 105
            alt142 = 1
          when 106
            alt142 = 2
          when 109
            alt142 = 3
          when 110
            alt142 = 4
          when Identifier, FloatingPointLiteral, CharacterLiteral, StringLiteral, HexLiteral, OctalLiteral, DecimalLiteral, 47, 56, 57, 58, 59, 60, 61, 62, 63, 65, 66, 69, 70, 71, 72, 111, 112, 113
            alt142 = 5
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 142, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(142)
        end
        case (alt142)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:816:9: '+' unaryExpression
          self.attr_dbg.location(816, 9)
          match(self.attr_input, 105, FOLLOW_105_in_unaryExpression4918)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(816, 13)
          push_follow(FOLLOW_unaryExpression_in_unaryExpression4920)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:817:9: '-' unaryExpression
          self.attr_dbg.location(817, 9)
          match(self.attr_input, 106, FOLLOW_106_in_unaryExpression4930)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(817, 13)
          push_follow(FOLLOW_unaryExpression_in_unaryExpression4932)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:818:9: '++' unaryExpression
          self.attr_dbg.location(818, 9)
          match(self.attr_input, 109, FOLLOW_109_in_unaryExpression4942)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(818, 14)
          push_follow(FOLLOW_unaryExpression_in_unaryExpression4944)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:819:9: '--' unaryExpression
          self.attr_dbg.location(819, 9)
          match(self.attr_input, 110, FOLLOW_110_in_unaryExpression4954)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(819, 14)
          push_follow(FOLLOW_unaryExpression_in_unaryExpression4956)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:820:9: unaryExpressionNotPlusMinus
          self.attr_dbg.location(820, 9)
          push_follow(FOLLOW_unaryExpressionNotPlusMinus_in_unaryExpression4966)
          unary_expression_not_plus_minus
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 121, unary_expression_start_index)
        end
      end
      self.attr_dbg.location(821, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "unaryExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "unaryExpression"
  # $ANTLR start "unaryExpressionNotPlusMinus"
  # Java.g:823:1: unaryExpressionNotPlusMinus : ( '~' unaryExpression | '!' unaryExpression | castExpression | primary ( selector )* ( '++' | '--' )? );
  def unary_expression_not_plus_minus
    unary_expression_not_plus_minus_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "unaryExpressionNotPlusMinus")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(823, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 122))
          return
        end
        # Java.g:824:5: ( '~' unaryExpression | '!' unaryExpression | castExpression | primary ( selector )* ( '++' | '--' )? )
        alt145 = 4
        begin
          self.attr_dbg.enter_decision(145)
          begin
            self.attr_is_cyclic_decision = true
            alt145 = @dfa145.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(145)
        end
        case (alt145)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:824:9: '~' unaryExpression
          self.attr_dbg.location(824, 9)
          match(self.attr_input, 111, FOLLOW_111_in_unaryExpressionNotPlusMinus4985)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(824, 13)
          push_follow(FOLLOW_unaryExpression_in_unaryExpressionNotPlusMinus4987)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:825:9: '!' unaryExpression
          self.attr_dbg.location(825, 9)
          match(self.attr_input, 112, FOLLOW_112_in_unaryExpressionNotPlusMinus4997)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(825, 13)
          push_follow(FOLLOW_unaryExpression_in_unaryExpressionNotPlusMinus4999)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:826:9: castExpression
          self.attr_dbg.location(826, 9)
          push_follow(FOLLOW_castExpression_in_unaryExpressionNotPlusMinus5009)
          cast_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:827:9: primary ( selector )* ( '++' | '--' )?
          self.attr_dbg.location(827, 9)
          push_follow(FOLLOW_primary_in_unaryExpressionNotPlusMinus5019)
          primary
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(827, 17)
          # Java.g:827:17: ( selector )*
          begin
            self.attr_dbg.enter_sub_rule(143)
            begin
              alt143 = 2
              begin
                self.attr_dbg.enter_decision(143)
                la143_0 = self.attr_input._la(1)
                if (((la143_0).equal?(29) || (la143_0).equal?(48)))
                  alt143 = 1
                end
              ensure
                self.attr_dbg.exit_decision(143)
              end
              case (alt143)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:0:0: selector
                self.attr_dbg.location(827, 17)
                push_follow(FOLLOW_selector_in_unaryExpressionNotPlusMinus5021)
                selector
                self.attr_state.attr__fsp -= 1
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(143)
          end
          self.attr_dbg.location(827, 27)
          # Java.g:827:27: ( '++' | '--' )?
          alt144 = 2
          begin
            self.attr_dbg.enter_sub_rule(144)
            begin
              self.attr_dbg.enter_decision(144)
              la144_0 = self.attr_input._la(1)
              if (((la144_0 >= 109 && la144_0 <= 110)))
                alt144 = 1
              end
            ensure
              self.attr_dbg.exit_decision(144)
            end
            case (alt144)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:
              self.attr_dbg.location(827, 27)
              if ((self.attr_input._la(1) >= 109 && self.attr_input._la(1) <= 110))
                self.attr_input.consume
                self.attr_state.attr_error_recovery = false
                self.attr_state.attr_failed = false
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                mse = MismatchedSetException.new(nil, self.attr_input)
                self.attr_dbg.recognition_exception(mse)
                raise mse
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(144)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 122, unary_expression_not_plus_minus_start_index)
        end
      end
      self.attr_dbg.location(828, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "unaryExpressionNotPlusMinus")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "unaryExpressionNotPlusMinus"
  # $ANTLR start "castExpression"
  # Java.g:830:1: castExpression : ( '(' primitiveType ')' unaryExpression | '(' ( type | expression ) ')' unaryExpressionNotPlusMinus );
  def cast_expression
    cast_expression_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "castExpression")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(830, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 123))
          return
        end
        # Java.g:831:5: ( '(' primitiveType ')' unaryExpression | '(' ( type | expression ) ')' unaryExpressionNotPlusMinus )
        alt147 = 2
        begin
          self.attr_dbg.enter_decision(147)
          la147_0 = self.attr_input._la(1)
          if (((la147_0).equal?(66)))
            la147_1 = self.attr_input._la(2)
            if ((synpred233__java))
              alt147 = 1
            else
              if ((true))
                alt147 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 147, 1, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 147, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(147)
        end
        case (alt147)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:831:8: '(' primitiveType ')' unaryExpression
          self.attr_dbg.location(831, 8)
          match(self.attr_input, 66, FOLLOW_66_in_castExpression5047)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(831, 12)
          push_follow(FOLLOW_primitiveType_in_castExpression5049)
          primitive_type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(831, 26)
          match(self.attr_input, 67, FOLLOW_67_in_castExpression5051)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(831, 30)
          push_follow(FOLLOW_unaryExpression_in_castExpression5053)
          unary_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:832:8: '(' ( type | expression ) ')' unaryExpressionNotPlusMinus
          self.attr_dbg.location(832, 8)
          match(self.attr_input, 66, FOLLOW_66_in_castExpression5062)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(832, 12)
          # Java.g:832:12: ( type | expression )
          alt146 = 2
          begin
            self.attr_dbg.enter_sub_rule(146)
            begin
              self.attr_dbg.enter_decision(146)
              begin
                self.attr_is_cyclic_decision = true
                alt146 = @dfa146.predict(self.attr_input)
              rescue NoViableAltException => nvae
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            ensure
              self.attr_dbg.exit_decision(146)
            end
            case (alt146)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:832:13: type
              self.attr_dbg.location(832, 13)
              push_follow(FOLLOW_type_in_castExpression5065)
              type
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            when 2
              self.attr_dbg.enter_alt(2)
              # Java.g:832:20: expression
              self.attr_dbg.location(832, 20)
              push_follow(FOLLOW_expression_in_castExpression5069)
              expression
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(146)
          end
          self.attr_dbg.location(832, 32)
          match(self.attr_input, 67, FOLLOW_67_in_castExpression5072)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(832, 36)
          push_follow(FOLLOW_unaryExpressionNotPlusMinus_in_castExpression5074)
          unary_expression_not_plus_minus
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 123, cast_expression_start_index)
        end
      end
      self.attr_dbg.location(833, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "castExpression")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "castExpression"
  # $ANTLR start "primary"
  # Java.g:835:1: primary : ( parExpression | 'this' ( '.' Identifier )* ( identifierSuffix )? | 'super' superSuffix | literal | 'new' creator | Identifier ( '.' Identifier )* ( identifierSuffix )? | primitiveType ( '[' ']' )* '.' 'class' | 'void' '.' 'class' );
  def primary
    primary_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "primary")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(835, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 124))
          return
        end
        # Java.g:836:5: ( parExpression | 'this' ( '.' Identifier )* ( identifierSuffix )? | 'super' superSuffix | literal | 'new' creator | Identifier ( '.' Identifier )* ( identifierSuffix )? | primitiveType ( '[' ']' )* '.' 'class' | 'void' '.' 'class' )
        alt153 = 8
        begin
          self.attr_dbg.enter_decision(153)
          case (self.attr_input._la(1))
          when 66
            alt153 = 1
          when 69
            alt153 = 2
          when 65
            alt153 = 3
          when FloatingPointLiteral, CharacterLiteral, StringLiteral, HexLiteral, OctalLiteral, DecimalLiteral, 70, 71, 72
            alt153 = 4
          when 113
            alt153 = 5
          when Identifier
            alt153 = 6
          when 56, 57, 58, 59, 60, 61, 62, 63
            alt153 = 7
          when 47
            alt153 = 8
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 153, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(153)
        end
        case (alt153)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:836:9: parExpression
          self.attr_dbg.location(836, 9)
          push_follow(FOLLOW_parExpression_in_primary5093)
          par_expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:837:9: 'this' ( '.' Identifier )* ( identifierSuffix )?
          self.attr_dbg.location(837, 9)
          match(self.attr_input, 69, FOLLOW_69_in_primary5103)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(837, 16)
          # Java.g:837:16: ( '.' Identifier )*
          begin
            self.attr_dbg.enter_sub_rule(148)
            begin
              alt148 = 2
              begin
                self.attr_dbg.enter_decision(148)
                la148_0 = self.attr_input._la(1)
                if (((la148_0).equal?(29)))
                  la148_2 = self.attr_input._la(2)
                  if (((la148_2).equal?(Identifier)))
                    la148_3 = self.attr_input._la(3)
                    if ((synpred236__java))
                      alt148 = 1
                    end
                  end
                end
              ensure
                self.attr_dbg.exit_decision(148)
              end
              case (alt148)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:837:17: '.' Identifier
                self.attr_dbg.location(837, 17)
                match(self.attr_input, 29, FOLLOW_29_in_primary5106)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(837, 21)
                match(self.attr_input, Identifier, FOLLOW_Identifier_in_primary5108)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(148)
          end
          self.attr_dbg.location(837, 34)
          # Java.g:837:34: ( identifierSuffix )?
          alt149 = 2
          begin
            self.attr_dbg.enter_sub_rule(149)
            begin
              self.attr_dbg.enter_decision(149)
              begin
                self.attr_is_cyclic_decision = true
                alt149 = @dfa149.predict(self.attr_input)
              rescue NoViableAltException => nvae
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            ensure
              self.attr_dbg.exit_decision(149)
            end
            case (alt149)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: identifierSuffix
              self.attr_dbg.location(837, 34)
              push_follow(FOLLOW_identifierSuffix_in_primary5112)
              identifier_suffix
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(149)
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:838:9: 'super' superSuffix
          self.attr_dbg.location(838, 9)
          match(self.attr_input, 65, FOLLOW_65_in_primary5123)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(838, 17)
          push_follow(FOLLOW_superSuffix_in_primary5125)
          super_suffix
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:839:9: literal
          self.attr_dbg.location(839, 9)
          push_follow(FOLLOW_literal_in_primary5135)
          literal
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:840:9: 'new' creator
          self.attr_dbg.location(840, 9)
          match(self.attr_input, 113, FOLLOW_113_in_primary5145)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(840, 15)
          push_follow(FOLLOW_creator_in_primary5147)
          creator
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:841:9: Identifier ( '.' Identifier )* ( identifierSuffix )?
          self.attr_dbg.location(841, 9)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_primary5157)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(841, 20)
          # Java.g:841:20: ( '.' Identifier )*
          begin
            self.attr_dbg.enter_sub_rule(150)
            begin
              alt150 = 2
              begin
                self.attr_dbg.enter_decision(150)
                la150_0 = self.attr_input._la(1)
                if (((la150_0).equal?(29)))
                  la150_2 = self.attr_input._la(2)
                  if (((la150_2).equal?(Identifier)))
                    la150_3 = self.attr_input._la(3)
                    if ((synpred242__java))
                      alt150 = 1
                    end
                  end
                end
              ensure
                self.attr_dbg.exit_decision(150)
              end
              case (alt150)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:841:21: '.' Identifier
                self.attr_dbg.location(841, 21)
                match(self.attr_input, 29, FOLLOW_29_in_primary5160)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(841, 25)
                match(self.attr_input, Identifier, FOLLOW_Identifier_in_primary5162)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(150)
          end
          self.attr_dbg.location(841, 38)
          # Java.g:841:38: ( identifierSuffix )?
          alt151 = 2
          begin
            self.attr_dbg.enter_sub_rule(151)
            begin
              self.attr_dbg.enter_decision(151)
              begin
                self.attr_is_cyclic_decision = true
                alt151 = @dfa151.predict(self.attr_input)
              rescue NoViableAltException => nvae
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            ensure
              self.attr_dbg.exit_decision(151)
            end
            case (alt151)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: identifierSuffix
              self.attr_dbg.location(841, 38)
              push_follow(FOLLOW_identifierSuffix_in_primary5166)
              identifier_suffix
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(151)
          end
        when 7
          self.attr_dbg.enter_alt(7)
          # Java.g:842:9: primitiveType ( '[' ']' )* '.' 'class'
          self.attr_dbg.location(842, 9)
          push_follow(FOLLOW_primitiveType_in_primary5177)
          primitive_type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(842, 23)
          # Java.g:842:23: ( '[' ']' )*
          begin
            self.attr_dbg.enter_sub_rule(152)
            begin
              alt152 = 2
              begin
                self.attr_dbg.enter_decision(152)
                la152_0 = self.attr_input._la(1)
                if (((la152_0).equal?(48)))
                  alt152 = 1
                end
              ensure
                self.attr_dbg.exit_decision(152)
              end
              case (alt152)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:842:24: '[' ']'
                self.attr_dbg.location(842, 24)
                match(self.attr_input, 48, FOLLOW_48_in_primary5180)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(842, 28)
                match(self.attr_input, 49, FOLLOW_49_in_primary5182)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                break
              end
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(152)
          end
          self.attr_dbg.location(842, 34)
          match(self.attr_input, 29, FOLLOW_29_in_primary5186)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(842, 38)
          match(self.attr_input, 37, FOLLOW_37_in_primary5188)
          if (self.attr_state.attr_failed)
            return
          end
        when 8
          self.attr_dbg.enter_alt(8)
          # Java.g:843:9: 'void' '.' 'class'
          self.attr_dbg.location(843, 9)
          match(self.attr_input, 47, FOLLOW_47_in_primary5198)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(843, 16)
          match(self.attr_input, 29, FOLLOW_29_in_primary5200)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(843, 20)
          match(self.attr_input, 37, FOLLOW_37_in_primary5202)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 124, primary_start_index)
        end
      end
      self.attr_dbg.location(844, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "primary")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "primary"
  # $ANTLR start "identifierSuffix"
  # Java.g:846:1: identifierSuffix : ( ( '[' ']' )+ '.' 'class' | ( '[' expression ']' )+ | arguments | '.' 'class' | '.' explicitGenericInvocation | '.' 'this' | '.' 'super' arguments | '.' 'new' innerCreator );
  def identifier_suffix
    identifier_suffix_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "identifierSuffix")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(846, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 125))
          return
        end
        # Java.g:847:5: ( ( '[' ']' )+ '.' 'class' | ( '[' expression ']' )+ | arguments | '.' 'class' | '.' explicitGenericInvocation | '.' 'this' | '.' 'super' arguments | '.' 'new' innerCreator )
        alt156 = 8
        begin
          self.attr_dbg.enter_decision(156)
          begin
            self.attr_is_cyclic_decision = true
            alt156 = @dfa156.predict(self.attr_input)
          rescue NoViableAltException => nvae
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        ensure
          self.attr_dbg.exit_decision(156)
        end
        case (alt156)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:847:9: ( '[' ']' )+ '.' 'class'
          self.attr_dbg.location(847, 9)
          # Java.g:847:9: ( '[' ']' )+
          cnt154 = 0
          begin
            self.attr_dbg.enter_sub_rule(154)
            begin
              alt154 = 2
              begin
                self.attr_dbg.enter_decision(154)
                la154_0 = self.attr_input._la(1)
                if (((la154_0).equal?(48)))
                  alt154 = 1
                end
              ensure
                self.attr_dbg.exit_decision(154)
              end
              case (alt154)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:847:10: '[' ']'
                self.attr_dbg.location(847, 10)
                match(self.attr_input, 48, FOLLOW_48_in_identifierSuffix5222)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(847, 14)
                match(self.attr_input, 49, FOLLOW_49_in_identifierSuffix5224)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                if (cnt154 >= 1)
                  break
                end
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                eee = EarlyExitException.new(154, self.attr_input)
                self.attr_dbg.recognition_exception(eee)
                raise eee
              end
              cnt154 += 1
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(154)
          end
          self.attr_dbg.location(847, 20)
          match(self.attr_input, 29, FOLLOW_29_in_identifierSuffix5228)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(847, 24)
          match(self.attr_input, 37, FOLLOW_37_in_identifierSuffix5230)
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:848:9: ( '[' expression ']' )+
          self.attr_dbg.location(848, 9)
          # Java.g:848:9: ( '[' expression ']' )+
          cnt155 = 0
          begin
            self.attr_dbg.enter_sub_rule(155)
            begin
              alt155 = 2
              begin
                self.attr_dbg.enter_decision(155)
                begin
                  self.attr_is_cyclic_decision = true
                  alt155 = @dfa155.predict(self.attr_input)
                rescue NoViableAltException => nvae
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              ensure
                self.attr_dbg.exit_decision(155)
              end
              case (alt155)
              when 1
                self.attr_dbg.enter_alt(1)
                # Java.g:848:10: '[' expression ']'
                self.attr_dbg.location(848, 10)
                match(self.attr_input, 48, FOLLOW_48_in_identifierSuffix5241)
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(848, 14)
                push_follow(FOLLOW_expression_in_identifierSuffix5243)
                expression
                self.attr_state.attr__fsp -= 1
                if (self.attr_state.attr_failed)
                  return
                end
                self.attr_dbg.location(848, 25)
                match(self.attr_input, 49, FOLLOW_49_in_identifierSuffix5245)
                if (self.attr_state.attr_failed)
                  return
                end
              else
                if (cnt155 >= 1)
                  break
                end
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                eee = EarlyExitException.new(155, self.attr_input)
                self.attr_dbg.recognition_exception(eee)
                raise eee
              end
              cnt155 += 1
            end while (true)
          ensure
            self.attr_dbg.exit_sub_rule(155)
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:849:9: arguments
          self.attr_dbg.location(849, 9)
          push_follow(FOLLOW_arguments_in_identifierSuffix5258)
          arguments
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:850:9: '.' 'class'
          self.attr_dbg.location(850, 9)
          match(self.attr_input, 29, FOLLOW_29_in_identifierSuffix5268)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(850, 13)
          match(self.attr_input, 37, FOLLOW_37_in_identifierSuffix5270)
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:851:9: '.' explicitGenericInvocation
          self.attr_dbg.location(851, 9)
          match(self.attr_input, 29, FOLLOW_29_in_identifierSuffix5280)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(851, 13)
          push_follow(FOLLOW_explicitGenericInvocation_in_identifierSuffix5282)
          explicit_generic_invocation
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 6
          self.attr_dbg.enter_alt(6)
          # Java.g:852:9: '.' 'this'
          self.attr_dbg.location(852, 9)
          match(self.attr_input, 29, FOLLOW_29_in_identifierSuffix5292)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(852, 13)
          match(self.attr_input, 69, FOLLOW_69_in_identifierSuffix5294)
          if (self.attr_state.attr_failed)
            return
          end
        when 7
          self.attr_dbg.enter_alt(7)
          # Java.g:853:9: '.' 'super' arguments
          self.attr_dbg.location(853, 9)
          match(self.attr_input, 29, FOLLOW_29_in_identifierSuffix5304)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(853, 13)
          match(self.attr_input, 65, FOLLOW_65_in_identifierSuffix5306)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(853, 21)
          push_follow(FOLLOW_arguments_in_identifierSuffix5308)
          arguments
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 8
          self.attr_dbg.enter_alt(8)
          # Java.g:854:9: '.' 'new' innerCreator
          self.attr_dbg.location(854, 9)
          match(self.attr_input, 29, FOLLOW_29_in_identifierSuffix5318)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(854, 13)
          match(self.attr_input, 113, FOLLOW_113_in_identifierSuffix5320)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(854, 19)
          push_follow(FOLLOW_innerCreator_in_identifierSuffix5322)
          inner_creator
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 125, identifier_suffix_start_index)
        end
      end
      self.attr_dbg.location(855, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "identifierSuffix")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "identifierSuffix"
  # $ANTLR start "creator"
  # Java.g:857:1: creator : ( nonWildcardTypeArguments createdName classCreatorRest | createdName ( arrayCreatorRest | classCreatorRest ) );
  def creator
    creator_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "creator")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(857, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 126))
          return
        end
        # Java.g:858:5: ( nonWildcardTypeArguments createdName classCreatorRest | createdName ( arrayCreatorRest | classCreatorRest ) )
        alt158 = 2
        begin
          self.attr_dbg.enter_decision(158)
          la158_0 = self.attr_input._la(1)
          if (((la158_0).equal?(40)))
            alt158 = 1
          else
            if (((la158_0).equal?(Identifier) || (la158_0 >= 56 && la158_0 <= 63)))
              alt158 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 158, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(158)
        end
        case (alt158)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:858:9: nonWildcardTypeArguments createdName classCreatorRest
          self.attr_dbg.location(858, 9)
          push_follow(FOLLOW_nonWildcardTypeArguments_in_creator5341)
          non_wildcard_type_arguments
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(858, 34)
          push_follow(FOLLOW_createdName_in_creator5343)
          created_name
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(858, 46)
          push_follow(FOLLOW_classCreatorRest_in_creator5345)
          class_creator_rest
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:859:9: createdName ( arrayCreatorRest | classCreatorRest )
          self.attr_dbg.location(859, 9)
          push_follow(FOLLOW_createdName_in_creator5355)
          created_name
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(859, 21)
          # Java.g:859:21: ( arrayCreatorRest | classCreatorRest )
          alt157 = 2
          begin
            self.attr_dbg.enter_sub_rule(157)
            begin
              self.attr_dbg.enter_decision(157)
              la157_0 = self.attr_input._la(1)
              if (((la157_0).equal?(48)))
                alt157 = 1
              else
                if (((la157_0).equal?(66)))
                  alt157 = 2
                else
                  if (self.attr_state.attr_backtracking > 0)
                    self.attr_state.attr_failed = true
                    return
                  end
                  nvae = NoViableAltException.new("", 157, 0, self.attr_input)
                  self.attr_dbg.recognition_exception(nvae)
                  raise nvae
                end
              end
            ensure
              self.attr_dbg.exit_decision(157)
            end
            case (alt157)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:859:22: arrayCreatorRest
              self.attr_dbg.location(859, 22)
              push_follow(FOLLOW_arrayCreatorRest_in_creator5358)
              array_creator_rest
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            when 2
              self.attr_dbg.enter_alt(2)
              # Java.g:859:41: classCreatorRest
              self.attr_dbg.location(859, 41)
              push_follow(FOLLOW_classCreatorRest_in_creator5362)
              class_creator_rest
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(157)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 126, creator_start_index)
        end
      end
      self.attr_dbg.location(860, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "creator")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "creator"
  # $ANTLR start "createdName"
  # Java.g:862:1: createdName : ( classOrInterfaceType | primitiveType );
  def created_name
    created_name_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "createdName")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(862, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 127))
          return
        end
        # Java.g:863:5: ( classOrInterfaceType | primitiveType )
        alt159 = 2
        begin
          self.attr_dbg.enter_decision(159)
          la159_0 = self.attr_input._la(1)
          if (((la159_0).equal?(Identifier)))
            alt159 = 1
          else
            if (((la159_0 >= 56 && la159_0 <= 63)))
              alt159 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 159, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(159)
        end
        case (alt159)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:863:9: classOrInterfaceType
          self.attr_dbg.location(863, 9)
          push_follow(FOLLOW_classOrInterfaceType_in_createdName5382)
          class_or_interface_type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:864:9: primitiveType
          self.attr_dbg.location(864, 9)
          push_follow(FOLLOW_primitiveType_in_createdName5392)
          primitive_type
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 127, created_name_start_index)
        end
      end
      self.attr_dbg.location(865, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "createdName")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "createdName"
  # $ANTLR start "innerCreator"
  # Java.g:867:1: innerCreator : ( nonWildcardTypeArguments )? Identifier classCreatorRest ;
  def inner_creator
    inner_creator_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "innerCreator")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(867, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 128))
          return
        end
        # Java.g:868:5: ( ( nonWildcardTypeArguments )? Identifier classCreatorRest )
        self.attr_dbg.enter_alt(1)
        # Java.g:868:9: ( nonWildcardTypeArguments )? Identifier classCreatorRest
        self.attr_dbg.location(868, 9)
        # Java.g:868:9: ( nonWildcardTypeArguments )?
        alt160 = 2
        begin
          self.attr_dbg.enter_sub_rule(160)
          begin
            self.attr_dbg.enter_decision(160)
            la160_0 = self.attr_input._la(1)
            if (((la160_0).equal?(40)))
              alt160 = 1
            end
          ensure
            self.attr_dbg.exit_decision(160)
          end
          case (alt160)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: nonWildcardTypeArguments
            self.attr_dbg.location(868, 9)
            push_follow(FOLLOW_nonWildcardTypeArguments_in_innerCreator5415)
            non_wildcard_type_arguments
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(160)
        end
        self.attr_dbg.location(868, 35)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_innerCreator5418)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(868, 46)
        push_follow(FOLLOW_classCreatorRest_in_innerCreator5420)
        class_creator_rest
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 128, inner_creator_start_index)
        end
      end
      self.attr_dbg.location(869, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "innerCreator")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "innerCreator"
  # $ANTLR start "arrayCreatorRest"
  # Java.g:871:1: arrayCreatorRest : '[' ( ']' ( '[' ']' )* arrayInitializer | expression ']' ( '[' expression ']' )* ( '[' ']' )* ) ;
  def array_creator_rest
    array_creator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "arrayCreatorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(871, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 129))
          return
        end
        # Java.g:872:5: ( '[' ( ']' ( '[' ']' )* arrayInitializer | expression ']' ( '[' expression ']' )* ( '[' ']' )* ) )
        self.attr_dbg.enter_alt(1)
        # Java.g:872:9: '[' ( ']' ( '[' ']' )* arrayInitializer | expression ']' ( '[' expression ']' )* ( '[' ']' )* )
        self.attr_dbg.location(872, 9)
        match(self.attr_input, 48, FOLLOW_48_in_arrayCreatorRest5439)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(873, 9)
        # Java.g:873:9: ( ']' ( '[' ']' )* arrayInitializer | expression ']' ( '[' expression ']' )* ( '[' ']' )* )
        alt164 = 2
        begin
          self.attr_dbg.enter_sub_rule(164)
          begin
            self.attr_dbg.enter_decision(164)
            la164_0 = self.attr_input._la(1)
            if (((la164_0).equal?(49)))
              alt164 = 1
            else
              if (((la164_0).equal?(Identifier) || (la164_0 >= FloatingPointLiteral && la164_0 <= DecimalLiteral) || (la164_0).equal?(47) || (la164_0 >= 56 && la164_0 <= 63) || (la164_0 >= 65 && la164_0 <= 66) || (la164_0 >= 69 && la164_0 <= 72) || (la164_0 >= 105 && la164_0 <= 106) || (la164_0 >= 109 && la164_0 <= 113)))
                alt164 = 2
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 164, 0, self.attr_input)
                self.attr_dbg.recognition_exception(nvae)
                raise nvae
              end
            end
          ensure
            self.attr_dbg.exit_decision(164)
          end
          case (alt164)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:873:13: ']' ( '[' ']' )* arrayInitializer
            self.attr_dbg.location(873, 13)
            match(self.attr_input, 49, FOLLOW_49_in_arrayCreatorRest5453)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(873, 17)
            # Java.g:873:17: ( '[' ']' )*
            begin
              self.attr_dbg.enter_sub_rule(161)
              begin
                alt161 = 2
                begin
                  self.attr_dbg.enter_decision(161)
                  la161_0 = self.attr_input._la(1)
                  if (((la161_0).equal?(48)))
                    alt161 = 1
                  end
                ensure
                  self.attr_dbg.exit_decision(161)
                end
                case (alt161)
                when 1
                  self.attr_dbg.enter_alt(1)
                  # Java.g:873:18: '[' ']'
                  self.attr_dbg.location(873, 18)
                  match(self.attr_input, 48, FOLLOW_48_in_arrayCreatorRest5456)
                  if (self.attr_state.attr_failed)
                    return
                  end
                  self.attr_dbg.location(873, 22)
                  match(self.attr_input, 49, FOLLOW_49_in_arrayCreatorRest5458)
                  if (self.attr_state.attr_failed)
                    return
                  end
                else
                  break
                end
              end while (true)
            ensure
              self.attr_dbg.exit_sub_rule(161)
            end
            self.attr_dbg.location(873, 28)
            push_follow(FOLLOW_arrayInitializer_in_arrayCreatorRest5462)
            array_initializer
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          when 2
            self.attr_dbg.enter_alt(2)
            # Java.g:874:13: expression ']' ( '[' expression ']' )* ( '[' ']' )*
            self.attr_dbg.location(874, 13)
            push_follow(FOLLOW_expression_in_arrayCreatorRest5476)
            expression
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(874, 24)
            match(self.attr_input, 49, FOLLOW_49_in_arrayCreatorRest5478)
            if (self.attr_state.attr_failed)
              return
            end
            self.attr_dbg.location(874, 28)
            # Java.g:874:28: ( '[' expression ']' )*
            begin
              self.attr_dbg.enter_sub_rule(162)
              begin
                alt162 = 2
                begin
                  self.attr_dbg.enter_decision(162)
                  begin
                    self.attr_is_cyclic_decision = true
                    alt162 = @dfa162.predict(self.attr_input)
                  rescue NoViableAltException => nvae
                    self.attr_dbg.recognition_exception(nvae)
                    raise nvae
                  end
                ensure
                  self.attr_dbg.exit_decision(162)
                end
                case (alt162)
                when 1
                  self.attr_dbg.enter_alt(1)
                  # Java.g:874:29: '[' expression ']'
                  self.attr_dbg.location(874, 29)
                  match(self.attr_input, 48, FOLLOW_48_in_arrayCreatorRest5481)
                  if (self.attr_state.attr_failed)
                    return
                  end
                  self.attr_dbg.location(874, 33)
                  push_follow(FOLLOW_expression_in_arrayCreatorRest5483)
                  expression
                  self.attr_state.attr__fsp -= 1
                  if (self.attr_state.attr_failed)
                    return
                  end
                  self.attr_dbg.location(874, 44)
                  match(self.attr_input, 49, FOLLOW_49_in_arrayCreatorRest5485)
                  if (self.attr_state.attr_failed)
                    return
                  end
                else
                  break
                end
              end while (true)
            ensure
              self.attr_dbg.exit_sub_rule(162)
            end
            self.attr_dbg.location(874, 50)
            # Java.g:874:50: ( '[' ']' )*
            begin
              self.attr_dbg.enter_sub_rule(163)
              begin
                alt163 = 2
                begin
                  self.attr_dbg.enter_decision(163)
                  la163_0 = self.attr_input._la(1)
                  if (((la163_0).equal?(48)))
                    la163_2 = self.attr_input._la(2)
                    if (((la163_2).equal?(49)))
                      alt163 = 1
                    end
                  end
                ensure
                  self.attr_dbg.exit_decision(163)
                end
                case (alt163)
                when 1
                  self.attr_dbg.enter_alt(1)
                  # Java.g:874:51: '[' ']'
                  self.attr_dbg.location(874, 51)
                  match(self.attr_input, 48, FOLLOW_48_in_arrayCreatorRest5490)
                  if (self.attr_state.attr_failed)
                    return
                  end
                  self.attr_dbg.location(874, 55)
                  match(self.attr_input, 49, FOLLOW_49_in_arrayCreatorRest5492)
                  if (self.attr_state.attr_failed)
                    return
                  end
                else
                  break
                end
              end while (true)
            ensure
              self.attr_dbg.exit_sub_rule(163)
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(164)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 129, array_creator_rest_start_index)
        end
      end
      self.attr_dbg.location(876, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "arrayCreatorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "arrayCreatorRest"
  # $ANTLR start "classCreatorRest"
  # Java.g:878:1: classCreatorRest : arguments ( classBody )? ;
  def class_creator_rest
    class_creator_rest_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "classCreatorRest")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(878, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 130))
          return
        end
        # Java.g:879:5: ( arguments ( classBody )? )
        self.attr_dbg.enter_alt(1)
        # Java.g:879:9: arguments ( classBody )?
        self.attr_dbg.location(879, 9)
        push_follow(FOLLOW_arguments_in_classCreatorRest5523)
        arguments
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(879, 19)
        # Java.g:879:19: ( classBody )?
        alt165 = 2
        begin
          self.attr_dbg.enter_sub_rule(165)
          begin
            self.attr_dbg.enter_decision(165)
            la165_0 = self.attr_input._la(1)
            if (((la165_0).equal?(44)))
              alt165 = 1
            end
          ensure
            self.attr_dbg.exit_decision(165)
          end
          case (alt165)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: classBody
            self.attr_dbg.location(879, 19)
            push_follow(FOLLOW_classBody_in_classCreatorRest5525)
            class_body
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(165)
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 130, class_creator_rest_start_index)
        end
      end
      self.attr_dbg.location(880, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "classCreatorRest")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "classCreatorRest"
  # $ANTLR start "explicitGenericInvocation"
  # Java.g:882:1: explicitGenericInvocation : nonWildcardTypeArguments Identifier arguments ;
  def explicit_generic_invocation
    explicit_generic_invocation_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "explicitGenericInvocation")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(882, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 131))
          return
        end
        # Java.g:883:5: ( nonWildcardTypeArguments Identifier arguments )
        self.attr_dbg.enter_alt(1)
        # Java.g:883:9: nonWildcardTypeArguments Identifier arguments
        self.attr_dbg.location(883, 9)
        push_follow(FOLLOW_nonWildcardTypeArguments_in_explicitGenericInvocation5549)
        non_wildcard_type_arguments
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(883, 34)
        match(self.attr_input, Identifier, FOLLOW_Identifier_in_explicitGenericInvocation5551)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(883, 45)
        push_follow(FOLLOW_arguments_in_explicitGenericInvocation5553)
        arguments
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 131, explicit_generic_invocation_start_index)
        end
      end
      self.attr_dbg.location(884, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "explicitGenericInvocation")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "explicitGenericInvocation"
  # $ANTLR start "nonWildcardTypeArguments"
  # Java.g:886:1: nonWildcardTypeArguments : '<' typeList '>' ;
  def non_wildcard_type_arguments
    non_wildcard_type_arguments_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "nonWildcardTypeArguments")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(886, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 132))
          return
        end
        # Java.g:887:5: ( '<' typeList '>' )
        self.attr_dbg.enter_alt(1)
        # Java.g:887:9: '<' typeList '>'
        self.attr_dbg.location(887, 9)
        match(self.attr_input, 40, FOLLOW_40_in_nonWildcardTypeArguments5576)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(887, 13)
        push_follow(FOLLOW_typeList_in_nonWildcardTypeArguments5578)
        type_list
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(887, 22)
        match(self.attr_input, 42, FOLLOW_42_in_nonWildcardTypeArguments5580)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 132, non_wildcard_type_arguments_start_index)
        end
      end
      self.attr_dbg.location(888, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "nonWildcardTypeArguments")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "nonWildcardTypeArguments"
  # $ANTLR start "selector"
  # Java.g:890:1: selector : ( '.' Identifier ( arguments )? | '.' 'this' | '.' 'super' superSuffix | '.' 'new' innerCreator | '[' expression ']' );
  def selector
    selector_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "selector")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(890, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 133))
          return
        end
        # Java.g:891:5: ( '.' Identifier ( arguments )? | '.' 'this' | '.' 'super' superSuffix | '.' 'new' innerCreator | '[' expression ']' )
        alt167 = 5
        begin
          self.attr_dbg.enter_decision(167)
          la167_0 = self.attr_input._la(1)
          if (((la167_0).equal?(29)))
            case (self.attr_input._la(2))
            when Identifier
              alt167 = 1
            when 69
              alt167 = 2
            when 65
              alt167 = 3
            when 113
              alt167 = 4
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 167, 1, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          else
            if (((la167_0).equal?(48)))
              alt167 = 5
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 167, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(167)
        end
        case (alt167)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:891:9: '.' Identifier ( arguments )?
          self.attr_dbg.location(891, 9)
          match(self.attr_input, 29, FOLLOW_29_in_selector5603)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(891, 13)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_selector5605)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(891, 24)
          # Java.g:891:24: ( arguments )?
          alt166 = 2
          begin
            self.attr_dbg.enter_sub_rule(166)
            begin
              self.attr_dbg.enter_decision(166)
              la166_0 = self.attr_input._la(1)
              if (((la166_0).equal?(66)))
                alt166 = 1
              end
            ensure
              self.attr_dbg.exit_decision(166)
            end
            case (alt166)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: arguments
              self.attr_dbg.location(891, 24)
              push_follow(FOLLOW_arguments_in_selector5607)
              arguments
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(166)
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:892:9: '.' 'this'
          self.attr_dbg.location(892, 9)
          match(self.attr_input, 29, FOLLOW_29_in_selector5618)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(892, 13)
          match(self.attr_input, 69, FOLLOW_69_in_selector5620)
          if (self.attr_state.attr_failed)
            return
          end
        when 3
          self.attr_dbg.enter_alt(3)
          # Java.g:893:9: '.' 'super' superSuffix
          self.attr_dbg.location(893, 9)
          match(self.attr_input, 29, FOLLOW_29_in_selector5630)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(893, 13)
          match(self.attr_input, 65, FOLLOW_65_in_selector5632)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(893, 21)
          push_follow(FOLLOW_superSuffix_in_selector5634)
          super_suffix
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 4
          self.attr_dbg.enter_alt(4)
          # Java.g:894:9: '.' 'new' innerCreator
          self.attr_dbg.location(894, 9)
          match(self.attr_input, 29, FOLLOW_29_in_selector5644)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(894, 13)
          match(self.attr_input, 113, FOLLOW_113_in_selector5646)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(894, 19)
          push_follow(FOLLOW_innerCreator_in_selector5648)
          inner_creator
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 5
          self.attr_dbg.enter_alt(5)
          # Java.g:895:9: '[' expression ']'
          self.attr_dbg.location(895, 9)
          match(self.attr_input, 48, FOLLOW_48_in_selector5658)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(895, 13)
          push_follow(FOLLOW_expression_in_selector5660)
          expression
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(895, 24)
          match(self.attr_input, 49, FOLLOW_49_in_selector5662)
          if (self.attr_state.attr_failed)
            return
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 133, selector_start_index)
        end
      end
      self.attr_dbg.location(896, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "selector")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "selector"
  # $ANTLR start "superSuffix"
  # Java.g:898:1: superSuffix : ( arguments | '.' Identifier ( arguments )? );
  def super_suffix
    super_suffix_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "superSuffix")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(898, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 134))
          return
        end
        # Java.g:899:5: ( arguments | '.' Identifier ( arguments )? )
        alt169 = 2
        begin
          self.attr_dbg.enter_decision(169)
          la169_0 = self.attr_input._la(1)
          if (((la169_0).equal?(66)))
            alt169 = 1
          else
            if (((la169_0).equal?(29)))
              alt169 = 2
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("", 169, 0, self.attr_input)
              self.attr_dbg.recognition_exception(nvae)
              raise nvae
            end
          end
        ensure
          self.attr_dbg.exit_decision(169)
        end
        case (alt169)
        when 1
          self.attr_dbg.enter_alt(1)
          # Java.g:899:9: arguments
          self.attr_dbg.location(899, 9)
          push_follow(FOLLOW_arguments_in_superSuffix5685)
          arguments
          self.attr_state.attr__fsp -= 1
          if (self.attr_state.attr_failed)
            return
          end
        when 2
          self.attr_dbg.enter_alt(2)
          # Java.g:900:9: '.' Identifier ( arguments )?
          self.attr_dbg.location(900, 9)
          match(self.attr_input, 29, FOLLOW_29_in_superSuffix5695)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(900, 13)
          match(self.attr_input, Identifier, FOLLOW_Identifier_in_superSuffix5697)
          if (self.attr_state.attr_failed)
            return
          end
          self.attr_dbg.location(900, 24)
          # Java.g:900:24: ( arguments )?
          alt168 = 2
          begin
            self.attr_dbg.enter_sub_rule(168)
            begin
              self.attr_dbg.enter_decision(168)
              la168_0 = self.attr_input._la(1)
              if (((la168_0).equal?(66)))
                alt168 = 1
              end
            ensure
              self.attr_dbg.exit_decision(168)
            end
            case (alt168)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: arguments
              self.attr_dbg.location(900, 24)
              push_follow(FOLLOW_arguments_in_superSuffix5699)
              arguments
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            end
          ensure
            self.attr_dbg.exit_sub_rule(168)
          end
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 134, super_suffix_start_index)
        end
      end
      self.attr_dbg.location(901, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "superSuffix")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "superSuffix"
  # $ANTLR start "arguments"
  # Java.g:903:1: arguments : '(' ( expressionList )? ')' ;
  def arguments
    arguments_start_index = self.attr_input.index
    begin
      self.attr_dbg.enter_rule(get_grammar_file_name, "arguments")
      if ((get_rule_level).equal?(0))
        self.attr_dbg.commence
      end
      inc_rule_level
      self.attr_dbg.location(903, 1)
      begin
        if (self.attr_state.attr_backtracking > 0 && already_parsed_rule(self.attr_input, 135))
          return
        end
        # Java.g:904:5: ( '(' ( expressionList )? ')' )
        self.attr_dbg.enter_alt(1)
        # Java.g:904:9: '(' ( expressionList )? ')'
        self.attr_dbg.location(904, 9)
        match(self.attr_input, 66, FOLLOW_66_in_arguments5719)
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(904, 13)
        # Java.g:904:13: ( expressionList )?
        alt170 = 2
        begin
          self.attr_dbg.enter_sub_rule(170)
          begin
            self.attr_dbg.enter_decision(170)
            la170_0 = self.attr_input._la(1)
            if (((la170_0).equal?(Identifier) || (la170_0 >= FloatingPointLiteral && la170_0 <= DecimalLiteral) || (la170_0).equal?(47) || (la170_0 >= 56 && la170_0 <= 63) || (la170_0 >= 65 && la170_0 <= 66) || (la170_0 >= 69 && la170_0 <= 72) || (la170_0 >= 105 && la170_0 <= 106) || (la170_0 >= 109 && la170_0 <= 113)))
              alt170 = 1
            end
          ensure
            self.attr_dbg.exit_decision(170)
          end
          case (alt170)
          when 1
            self.attr_dbg.enter_alt(1)
            # Java.g:0:0: expressionList
            self.attr_dbg.location(904, 13)
            push_follow(FOLLOW_expressionList_in_arguments5721)
            expression_list
            self.attr_state.attr__fsp -= 1
            if (self.attr_state.attr_failed)
              return
            end
          end
        ensure
          self.attr_dbg.exit_sub_rule(170)
        end
        self.attr_dbg.location(904, 29)
        match(self.attr_input, 67, FOLLOW_67_in_arguments5724)
        if (self.attr_state.attr_failed)
          return
        end
      rescue RecognitionException => re
        report_error(re)
        recover(self.attr_input, re)
      ensure
        if (self.attr_state.attr_backtracking > 0)
          memoize(self.attr_input, 135, arguments_start_index)
        end
      end
      self.attr_dbg.location(905, 5)
    ensure
      self.attr_dbg.exit_rule(get_grammar_file_name, "arguments")
      dec_rule_level
      if ((get_rule_level).equal?(0))
        self.attr_dbg.terminate
      end
    end
    return
  end
  
  typesig { [] }
  # $ANTLR end "arguments"
  # $ANTLR start synpred5_Java
  def synpred5__java_fragment
    # Java.g:178:9: ( annotations ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* ) )
    self.attr_dbg.enter_alt(1)
    # Java.g:178:9: annotations ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* )
    self.attr_dbg.location(178, 9)
    push_follow(FOLLOW_annotations_in_synpred5_Java44)
    annotations
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(179, 9)
    # Java.g:179:9: ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* )
    alt176 = 2
    begin
      self.attr_dbg.enter_sub_rule(176)
      begin
        self.attr_dbg.enter_decision(176)
        la176_0 = self.attr_input._la(1)
        if (((la176_0).equal?(25)))
          alt176 = 1
        else
          if (((la176_0).equal?(ENUM) || (la176_0).equal?(28) || (la176_0 >= 31 && la176_0 <= 37) || (la176_0).equal?(46) || (la176_0).equal?(73)))
            alt176 = 2
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 176, 0, self.attr_input)
            self.attr_dbg.recognition_exception(nvae)
            raise nvae
          end
        end
      ensure
        self.attr_dbg.exit_decision(176)
      end
      case (alt176)
      when 1
        self.attr_dbg.enter_alt(1)
        # Java.g:179:13: packageDeclaration ( importDeclaration )* ( typeDeclaration )*
        self.attr_dbg.location(179, 13)
        push_follow(FOLLOW_packageDeclaration_in_synpred5_Java58)
        package_declaration
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(179, 32)
        # Java.g:179:32: ( importDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(173)
          begin
            alt173 = 2
            begin
              self.attr_dbg.enter_decision(173)
              la173_0 = self.attr_input._la(1)
              if (((la173_0).equal?(27)))
                alt173 = 1
              end
            ensure
              self.attr_dbg.exit_decision(173)
            end
            case (alt173)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: importDeclaration
              self.attr_dbg.location(179, 32)
              push_follow(FOLLOW_importDeclaration_in_synpred5_Java60)
              import_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(173)
        end
        self.attr_dbg.location(179, 51)
        # Java.g:179:51: ( typeDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(174)
          begin
            alt174 = 2
            begin
              self.attr_dbg.enter_decision(174)
              la174_0 = self.attr_input._la(1)
              if (((la174_0).equal?(ENUM) || (la174_0).equal?(26) || (la174_0).equal?(28) || (la174_0 >= 31 && la174_0 <= 37) || (la174_0).equal?(46) || (la174_0).equal?(73)))
                alt174 = 1
              end
            ensure
              self.attr_dbg.exit_decision(174)
            end
            case (alt174)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: typeDeclaration
              self.attr_dbg.location(179, 51)
              push_follow(FOLLOW_typeDeclaration_in_synpred5_Java63)
              type_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(174)
        end
      when 2
        self.attr_dbg.enter_alt(2)
        # Java.g:180:13: classOrInterfaceDeclaration ( typeDeclaration )*
        self.attr_dbg.location(180, 13)
        push_follow(FOLLOW_classOrInterfaceDeclaration_in_synpred5_Java78)
        class_or_interface_declaration
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
        self.attr_dbg.location(180, 41)
        # Java.g:180:41: ( typeDeclaration )*
        begin
          self.attr_dbg.enter_sub_rule(175)
          begin
            alt175 = 2
            begin
              self.attr_dbg.enter_decision(175)
              la175_0 = self.attr_input._la(1)
              if (((la175_0).equal?(ENUM) || (la175_0).equal?(26) || (la175_0).equal?(28) || (la175_0 >= 31 && la175_0 <= 37) || (la175_0).equal?(46) || (la175_0).equal?(73)))
                alt175 = 1
              end
            ensure
              self.attr_dbg.exit_decision(175)
            end
            case (alt175)
            when 1
              self.attr_dbg.enter_alt(1)
              # Java.g:0:0: typeDeclaration
              self.attr_dbg.location(180, 41)
              push_follow(FOLLOW_typeDeclaration_in_synpred5_Java80)
              type_declaration
              self.attr_state.attr__fsp -= 1
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
        ensure
          self.attr_dbg.exit_sub_rule(175)
        end
      end
    ensure
      self.attr_dbg.exit_sub_rule(176)
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred5_Java
  # $ANTLR start synpred113_Java
  def synpred113__java_fragment
    # Java.g:492:13: ( explicitConstructorInvocation )
    self.attr_dbg.enter_alt(1)
    # Java.g:492:13: explicitConstructorInvocation
    self.attr_dbg.location(492, 13)
    push_follow(FOLLOW_explicitConstructorInvocation_in_synpred113_Java2455)
    explicit_constructor_invocation
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred113_Java
  # $ANTLR start synpred117_Java
  def synpred117__java_fragment
    # Java.g:496:9: ( ( nonWildcardTypeArguments )? ( 'this' | 'super' ) arguments ';' )
    self.attr_dbg.enter_alt(1)
    # Java.g:496:9: ( nonWildcardTypeArguments )? ( 'this' | 'super' ) arguments ';'
    self.attr_dbg.location(496, 9)
    # Java.g:496:9: ( nonWildcardTypeArguments )?
    alt184 = 2
    begin
      self.attr_dbg.enter_sub_rule(184)
      begin
        self.attr_dbg.enter_decision(184)
        la184_0 = self.attr_input._la(1)
        if (((la184_0).equal?(40)))
          alt184 = 1
        end
      ensure
        self.attr_dbg.exit_decision(184)
      end
      case (alt184)
      when 1
        self.attr_dbg.enter_alt(1)
        # Java.g:0:0: nonWildcardTypeArguments
        self.attr_dbg.location(496, 9)
        push_follow(FOLLOW_nonWildcardTypeArguments_in_synpred117_Java2480)
        non_wildcard_type_arguments
        self.attr_state.attr__fsp -= 1
        if (self.attr_state.attr_failed)
          return
        end
      end
    ensure
      self.attr_dbg.exit_sub_rule(184)
    end
    self.attr_dbg.location(496, 35)
    if ((self.attr_input._la(1)).equal?(65) || (self.attr_input._la(1)).equal?(69))
      self.attr_input.consume
      self.attr_state.attr_error_recovery = false
      self.attr_state.attr_failed = false
    else
      if (self.attr_state.attr_backtracking > 0)
        self.attr_state.attr_failed = true
        return
      end
      mse = MismatchedSetException.new(nil, self.attr_input)
      self.attr_dbg.recognition_exception(mse)
      raise mse
    end
    self.attr_dbg.location(496, 54)
    push_follow(FOLLOW_arguments_in_synpred117_Java2491)
    arguments
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(496, 64)
    match(self.attr_input, 26, FOLLOW_26_in_synpred117_Java2493)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred117_Java
  # $ANTLR start synpred128_Java
  def synpred128__java_fragment
    # Java.g:528:9: ( annotation )
    self.attr_dbg.enter_alt(1)
    # Java.g:528:9: annotation
    self.attr_dbg.location(528, 9)
    push_follow(FOLLOW_annotation_in_synpred128_Java2704)
    annotation
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred128_Java
  # $ANTLR start synpred151_Java
  def synpred151__java_fragment
    # Java.g:601:9: ( localVariableDeclarationStatement )
    self.attr_dbg.enter_alt(1)
    # Java.g:601:9: localVariableDeclarationStatement
    self.attr_dbg.location(601, 9)
    push_follow(FOLLOW_localVariableDeclarationStatement_in_synpred151_Java3231)
    local_variable_declaration_statement
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred151_Java
  # $ANTLR start synpred152_Java
  def synpred152__java_fragment
    # Java.g:602:9: ( classOrInterfaceDeclaration )
    self.attr_dbg.enter_alt(1)
    # Java.g:602:9: classOrInterfaceDeclaration
    self.attr_dbg.location(602, 9)
    push_follow(FOLLOW_classOrInterfaceDeclaration_in_synpred152_Java3241)
    class_or_interface_declaration
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred152_Java
  # $ANTLR start synpred157_Java
  def synpred157__java_fragment
    # Java.g:621:54: ( 'else' statement )
    self.attr_dbg.enter_alt(1)
    # Java.g:621:54: 'else' statement
    self.attr_dbg.location(621, 54)
    match(self.attr_input, 77, FOLLOW_77_in_synpred157_Java3386)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(621, 61)
    push_follow(FOLLOW_statement_in_synpred157_Java3388)
    statement
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred157_Java
  # $ANTLR start synpred162_Java
  def synpred162__java_fragment
    # Java.g:626:11: ( catches 'finally' block )
    self.attr_dbg.enter_alt(1)
    # Java.g:626:11: catches 'finally' block
    self.attr_dbg.location(626, 11)
    push_follow(FOLLOW_catches_in_synpred162_Java3464)
    catches
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(626, 19)
    match(self.attr_input, 82, FOLLOW_82_in_synpred162_Java3466)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(626, 29)
    push_follow(FOLLOW_block_in_synpred162_Java3468)
    block
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred162_Java
  # $ANTLR start synpred163_Java
  def synpred163__java_fragment
    # Java.g:627:11: ( catches )
    self.attr_dbg.enter_alt(1)
    # Java.g:627:11: catches
    self.attr_dbg.location(627, 11)
    push_follow(FOLLOW_catches_in_synpred163_Java3480)
    catches
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred163_Java
  # $ANTLR start synpred178_Java
  def synpred178__java_fragment
    # Java.g:662:9: ( switchLabel )
    self.attr_dbg.enter_alt(1)
    # Java.g:662:9: switchLabel
    self.attr_dbg.location(662, 9)
    push_follow(FOLLOW_switchLabel_in_synpred178_Java3771)
    switch_label
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred178_Java
  # $ANTLR start synpred180_Java
  def synpred180__java_fragment
    # Java.g:666:9: ( 'case' constantExpression ':' )
    self.attr_dbg.enter_alt(1)
    # Java.g:666:9: 'case' constantExpression ':'
    self.attr_dbg.location(666, 9)
    match(self.attr_input, 89, FOLLOW_89_in_synpred180_Java3798)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(666, 16)
    push_follow(FOLLOW_constantExpression_in_synpred180_Java3800)
    constant_expression
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(666, 35)
    match(self.attr_input, 75, FOLLOW_75_in_synpred180_Java3802)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred180_Java
  # $ANTLR start synpred181_Java
  def synpred181__java_fragment
    # Java.g:667:9: ( 'case' enumConstantName ':' )
    self.attr_dbg.enter_alt(1)
    # Java.g:667:9: 'case' enumConstantName ':'
    self.attr_dbg.location(667, 9)
    match(self.attr_input, 89, FOLLOW_89_in_synpred181_Java3812)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(667, 16)
    push_follow(FOLLOW_enumConstantName_in_synpred181_Java3814)
    enum_constant_name
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(667, 33)
    match(self.attr_input, 75, FOLLOW_75_in_synpred181_Java3816)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred181_Java
  # $ANTLR start synpred182_Java
  def synpred182__java_fragment
    # Java.g:673:9: ( enhancedForControl )
    self.attr_dbg.enter_alt(1)
    # Java.g:673:9: enhancedForControl
    self.attr_dbg.location(673, 9)
    push_follow(FOLLOW_enhancedForControl_in_synpred182_Java3859)
    enhanced_for_control
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred182_Java
  # $ANTLR start synpred186_Java
  def synpred186__java_fragment
    # Java.g:678:9: ( localVariableDeclaration )
    self.attr_dbg.enter_alt(1)
    # Java.g:678:9: localVariableDeclaration
    self.attr_dbg.location(678, 9)
    push_follow(FOLLOW_localVariableDeclaration_in_synpred186_Java3899)
    local_variable_declaration
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred186_Java
  # $ANTLR start synpred188_Java
  def synpred188__java_fragment
    # Java.g:709:32: ( assignmentOperator expression )
    self.attr_dbg.enter_alt(1)
    # Java.g:709:32: assignmentOperator expression
    self.attr_dbg.location(709, 32)
    push_follow(FOLLOW_assignmentOperator_in_synpred188_Java4082)
    assignment_operator
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(709, 51)
    push_follow(FOLLOW_expression_in_synpred188_Java4084)
    expression
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred188_Java
  # $ANTLR start synpred198_Java
  def synpred198__java_fragment
    # Java.g:722:9: ( '<' '<' '=' )
    self.attr_dbg.enter_alt(1)
    # Java.g:722:10: '<' '<' '='
    self.attr_dbg.location(722, 10)
    match(self.attr_input, 40, FOLLOW_40_in_synpred198_Java4200)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(722, 14)
    match(self.attr_input, 40, FOLLOW_40_in_synpred198_Java4202)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(722, 18)
    match(self.attr_input, 51, FOLLOW_51_in_synpred198_Java4204)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred198_Java
  # $ANTLR start synpred199_Java
  def synpred199__java_fragment
    # Java.g:727:9: ( '>' '>' '>' '=' )
    self.attr_dbg.enter_alt(1)
    # Java.g:727:10: '>' '>' '>' '='
    self.attr_dbg.location(727, 10)
    match(self.attr_input, 42, FOLLOW_42_in_synpred199_Java4240)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(727, 14)
    match(self.attr_input, 42, FOLLOW_42_in_synpred199_Java4242)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(727, 18)
    match(self.attr_input, 42, FOLLOW_42_in_synpred199_Java4244)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(727, 22)
    match(self.attr_input, 51, FOLLOW_51_in_synpred199_Java4246)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred199_Java
  # $ANTLR start synpred200_Java
  def synpred200__java_fragment
    # Java.g:734:9: ( '>' '>' '=' )
    self.attr_dbg.enter_alt(1)
    # Java.g:734:10: '>' '>' '='
    self.attr_dbg.location(734, 10)
    match(self.attr_input, 42, FOLLOW_42_in_synpred200_Java4285)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(734, 14)
    match(self.attr_input, 42, FOLLOW_42_in_synpred200_Java4287)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(734, 18)
    match(self.attr_input, 51, FOLLOW_51_in_synpred200_Java4289)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred200_Java
  # $ANTLR start synpred211_Java
  def synpred211__java_fragment
    # Java.g:778:9: ( '<' '=' )
    self.attr_dbg.enter_alt(1)
    # Java.g:778:10: '<' '='
    self.attr_dbg.location(778, 10)
    match(self.attr_input, 40, FOLLOW_40_in_synpred211_Java4597)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(778, 14)
    match(self.attr_input, 51, FOLLOW_51_in_synpred211_Java4599)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred211_Java
  # $ANTLR start synpred212_Java
  def synpred212__java_fragment
    # Java.g:781:9: ( '>' '=' )
    self.attr_dbg.enter_alt(1)
    # Java.g:781:10: '>' '='
    self.attr_dbg.location(781, 10)
    match(self.attr_input, 42, FOLLOW_42_in_synpred212_Java4631)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(781, 14)
    match(self.attr_input, 51, FOLLOW_51_in_synpred212_Java4633)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred212_Java
  # $ANTLR start synpred215_Java
  def synpred215__java_fragment
    # Java.g:793:9: ( '<' '<' )
    self.attr_dbg.enter_alt(1)
    # Java.g:793:10: '<' '<'
    self.attr_dbg.location(793, 10)
    match(self.attr_input, 40, FOLLOW_40_in_synpred215_Java4724)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(793, 14)
    match(self.attr_input, 40, FOLLOW_40_in_synpred215_Java4726)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred215_Java
  # $ANTLR start synpred216_Java
  def synpred216__java_fragment
    # Java.g:796:9: ( '>' '>' '>' )
    self.attr_dbg.enter_alt(1)
    # Java.g:796:10: '>' '>' '>'
    self.attr_dbg.location(796, 10)
    match(self.attr_input, 42, FOLLOW_42_in_synpred216_Java4758)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(796, 14)
    match(self.attr_input, 42, FOLLOW_42_in_synpred216_Java4760)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(796, 18)
    match(self.attr_input, 42, FOLLOW_42_in_synpred216_Java4762)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred216_Java
  # $ANTLR start synpred217_Java
  def synpred217__java_fragment
    # Java.g:801:9: ( '>' '>' )
    self.attr_dbg.enter_alt(1)
    # Java.g:801:10: '>' '>'
    self.attr_dbg.location(801, 10)
    match(self.attr_input, 42, FOLLOW_42_in_synpred217_Java4798)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(801, 14)
    match(self.attr_input, 42, FOLLOW_42_in_synpred217_Java4800)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred217_Java
  # $ANTLR start synpred229_Java
  def synpred229__java_fragment
    # Java.g:826:9: ( castExpression )
    self.attr_dbg.enter_alt(1)
    # Java.g:826:9: castExpression
    self.attr_dbg.location(826, 9)
    push_follow(FOLLOW_castExpression_in_synpred229_Java5009)
    cast_expression
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred229_Java
  # $ANTLR start synpred233_Java
  def synpred233__java_fragment
    # Java.g:831:8: ( '(' primitiveType ')' unaryExpression )
    self.attr_dbg.enter_alt(1)
    # Java.g:831:8: '(' primitiveType ')' unaryExpression
    self.attr_dbg.location(831, 8)
    match(self.attr_input, 66, FOLLOW_66_in_synpred233_Java5047)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(831, 12)
    push_follow(FOLLOW_primitiveType_in_synpred233_Java5049)
    primitive_type
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(831, 26)
    match(self.attr_input, 67, FOLLOW_67_in_synpred233_Java5051)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(831, 30)
    push_follow(FOLLOW_unaryExpression_in_synpred233_Java5053)
    unary_expression
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred233_Java
  # $ANTLR start synpred234_Java
  def synpred234__java_fragment
    # Java.g:832:13: ( type )
    self.attr_dbg.enter_alt(1)
    # Java.g:832:13: type
    self.attr_dbg.location(832, 13)
    push_follow(FOLLOW_type_in_synpred234_Java5065)
    type
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred234_Java
  # $ANTLR start synpred236_Java
  def synpred236__java_fragment
    # Java.g:837:17: ( '.' Identifier )
    self.attr_dbg.enter_alt(1)
    # Java.g:837:17: '.' Identifier
    self.attr_dbg.location(837, 17)
    match(self.attr_input, 29, FOLLOW_29_in_synpred236_Java5106)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(837, 21)
    match(self.attr_input, Identifier, FOLLOW_Identifier_in_synpred236_Java5108)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred236_Java
  # $ANTLR start synpred237_Java
  def synpred237__java_fragment
    # Java.g:837:34: ( identifierSuffix )
    self.attr_dbg.enter_alt(1)
    # Java.g:837:34: identifierSuffix
    self.attr_dbg.location(837, 34)
    push_follow(FOLLOW_identifierSuffix_in_synpred237_Java5112)
    identifier_suffix
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred237_Java
  # $ANTLR start synpred242_Java
  def synpred242__java_fragment
    # Java.g:841:21: ( '.' Identifier )
    self.attr_dbg.enter_alt(1)
    # Java.g:841:21: '.' Identifier
    self.attr_dbg.location(841, 21)
    match(self.attr_input, 29, FOLLOW_29_in_synpred242_Java5160)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(841, 25)
    match(self.attr_input, Identifier, FOLLOW_Identifier_in_synpred242_Java5162)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred242_Java
  # $ANTLR start synpred243_Java
  def synpred243__java_fragment
    # Java.g:841:38: ( identifierSuffix )
    self.attr_dbg.enter_alt(1)
    # Java.g:841:38: identifierSuffix
    self.attr_dbg.location(841, 38)
    push_follow(FOLLOW_identifierSuffix_in_synpred243_Java5166)
    identifier_suffix
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred243_Java
  # $ANTLR start synpred249_Java
  def synpred249__java_fragment
    # Java.g:848:10: ( '[' expression ']' )
    self.attr_dbg.enter_alt(1)
    # Java.g:848:10: '[' expression ']'
    self.attr_dbg.location(848, 10)
    match(self.attr_input, 48, FOLLOW_48_in_synpred249_Java5241)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(848, 14)
    push_follow(FOLLOW_expression_in_synpred249_Java5243)
    expression
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(848, 25)
    match(self.attr_input, 49, FOLLOW_49_in_synpred249_Java5245)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred249_Java
  # $ANTLR start synpred262_Java
  def synpred262__java_fragment
    # Java.g:874:29: ( '[' expression ']' )
    self.attr_dbg.enter_alt(1)
    # Java.g:874:29: '[' expression ']'
    self.attr_dbg.location(874, 29)
    match(self.attr_input, 48, FOLLOW_48_in_synpred262_Java5481)
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(874, 33)
    push_follow(FOLLOW_expression_in_synpred262_Java5483)
    expression
    self.attr_state.attr__fsp -= 1
    if (self.attr_state.attr_failed)
      return
    end
    self.attr_dbg.location(874, 44)
    match(self.attr_input, 49, FOLLOW_49_in_synpred262_Java5485)
    if (self.attr_state.attr_failed)
      return
    end
  end
  
  typesig { [] }
  # $ANTLR end synpred262_Java
  # Delegated rules
  def synpred157__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred157__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred211__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred211__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred249__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred249__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred243__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred243__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred5__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred5__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred229__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred229__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred178__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred178__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred215__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred215__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred113__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred113__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred151__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred151__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred117__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred117__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred162__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred162__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred217__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred217__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred186__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred186__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred188__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred188__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred212__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred212__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred163__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred163__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred152__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred152__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred242__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred242__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred199__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred199__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred216__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred216__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred236__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred236__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred262__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred262__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred198__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred198__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred233__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred233__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred180__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred180__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred128__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred128__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred200__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred200__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred234__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred234__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred182__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred182__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred181__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred181__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  typesig { [] }
  def synpred237__java
    self.attr_state.attr_backtracking += 1
    self.attr_dbg.begin_backtrack(self.attr_state.attr_backtracking)
    start = self.attr_input.mark
    begin
      synpred237__java_fragment # can never throw exception
    rescue RecognitionException => re
      System.err.println("impossible: " + (re).to_s)
    end
    success = !self.attr_state.attr_failed
    self.attr_input.rewind(start)
    self.attr_dbg.end_backtrack(self.attr_state.attr_backtracking, success)
    self.attr_state.attr_backtracking -= 1
    self.attr_state.attr_failed = false
    return success
  end
  
  attr_accessor :dfa8
  alias_method :attr_dfa8, :dfa8
  undef_method :dfa8
  alias_method :attr_dfa8=, :dfa8=
  undef_method :dfa8=
  
  attr_accessor :dfa81
  alias_method :attr_dfa81, :dfa81
  undef_method :dfa81
  alias_method :attr_dfa81=, :dfa81=
  undef_method :dfa81=
  
  attr_accessor :dfa85
  alias_method :attr_dfa85, :dfa85
  undef_method :dfa85
  alias_method :attr_dfa85=, :dfa85=
  undef_method :dfa85=
  
  attr_accessor :dfa106
  alias_method :attr_dfa106, :dfa106
  undef_method :dfa106
  alias_method :attr_dfa106=, :dfa106=
  undef_method :dfa106=
  
  attr_accessor :dfa114
  alias_method :attr_dfa114, :dfa114
  undef_method :dfa114
  alias_method :attr_dfa114=, :dfa114=
  undef_method :dfa114=
  
  attr_accessor :dfa123
  alias_method :attr_dfa123, :dfa123
  undef_method :dfa123
  alias_method :attr_dfa123=, :dfa123=
  undef_method :dfa123=
  
  attr_accessor :dfa124
  alias_method :attr_dfa124, :dfa124
  undef_method :dfa124
  alias_method :attr_dfa124=, :dfa124=
  undef_method :dfa124=
  
  attr_accessor :dfa126
  alias_method :attr_dfa126, :dfa126
  undef_method :dfa126
  alias_method :attr_dfa126=, :dfa126=
  undef_method :dfa126=
  
  attr_accessor :dfa127
  alias_method :attr_dfa127, :dfa127
  undef_method :dfa127
  alias_method :attr_dfa127=, :dfa127=
  undef_method :dfa127=
  
  attr_accessor :dfa139
  alias_method :attr_dfa139, :dfa139
  undef_method :dfa139
  alias_method :attr_dfa139=, :dfa139=
  undef_method :dfa139=
  
  attr_accessor :dfa145
  alias_method :attr_dfa145, :dfa145
  undef_method :dfa145
  alias_method :attr_dfa145=, :dfa145=
  undef_method :dfa145=
  
  attr_accessor :dfa146
  alias_method :attr_dfa146, :dfa146
  undef_method :dfa146
  alias_method :attr_dfa146=, :dfa146=
  undef_method :dfa146=
  
  attr_accessor :dfa149
  alias_method :attr_dfa149, :dfa149
  undef_method :dfa149
  alias_method :attr_dfa149=, :dfa149=
  undef_method :dfa149=
  
  attr_accessor :dfa151
  alias_method :attr_dfa151, :dfa151
  undef_method :dfa151
  alias_method :attr_dfa151=, :dfa151=
  undef_method :dfa151=
  
  attr_accessor :dfa156
  alias_method :attr_dfa156, :dfa156
  undef_method :dfa156
  alias_method :attr_dfa156=, :dfa156=
  undef_method :dfa156=
  
  attr_accessor :dfa155
  alias_method :attr_dfa155, :dfa155
  undef_method :dfa155
  alias_method :attr_dfa155=, :dfa155=
  undef_method :dfa155=
  
  attr_accessor :dfa162
  alias_method :attr_dfa162, :dfa162
  undef_method :dfa162
  alias_method :attr_dfa162=, :dfa162=
  undef_method :dfa162=
  
  class_module.module_eval {
    const_set_lazy(:DFA8_eotS) { ("\21".to_u << 0xffff << "") }
    const_attr_reader  :DFA8_eotS
    
    const_set_lazy(:DFA8_eofS) { ("\1\2\20".to_u << 0xffff << "") }
    const_attr_reader  :DFA8_eofS
    
    const_set_lazy(:DFA8_minS) { ("\1\5\1\0\17".to_u << 0xffff << "") }
    const_attr_reader  :DFA8_minS
    
    const_set_lazy(:DFA8_maxS) { ("\1\111\1\0\17".to_u << 0xffff << "") }
    const_attr_reader  :DFA8_maxS
    
    const_set_lazy(:DFA8_acceptS) { ("\2".to_u << 0xffff << "\1\2\15".to_u << 0xffff << "\1\1") }
    const_attr_reader  :DFA8_acceptS
    
    const_set_lazy(:DFA8_specialS) { ("\1".to_u << 0xffff << "\1\0\17".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA8_specialS
    
    const_set_lazy(:DFA8_transitionS) { Array.typed(String).new([("\1\2\23".to_u << 0xffff << "\4\2\2".to_u << 0xffff << "\7\2\10".to_u << 0xffff << "\1\2\32".to_u << 0xffff << "\1\1"), ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA8_transitionS
    
    const_set_lazy(:DFA8_eot) { DFA.unpack_encoded_string(DFA8_eotS) }
    const_attr_reader  :DFA8_eot
    
    const_set_lazy(:DFA8_eof) { DFA.unpack_encoded_string(DFA8_eofS) }
    const_attr_reader  :DFA8_eof
    
    const_set_lazy(:DFA8_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA8_minS) }
    const_attr_reader  :DFA8_min
    
    const_set_lazy(:DFA8_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA8_maxS) }
    const_attr_reader  :DFA8_max
    
    const_set_lazy(:DFA8_accept) { DFA.unpack_encoded_string(DFA8_acceptS) }
    const_attr_reader  :DFA8_accept
    
    const_set_lazy(:DFA8_special) { DFA.unpack_encoded_string(DFA8_specialS) }
    const_attr_reader  :DFA8_special
    
    when_class_loaded do
      num_states = DFA8_transitionS.attr_length
      const_set :DFA8_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA8_transition[i] = DFA.unpack_encoded_string(DFA8_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA8) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 8
        self.attr_eot = DFA8_eot
        self.attr_eof = DFA8_eof
        self.attr_min = DFA8_min
        self.attr_max = DFA8_max
        self.attr_accept = DFA8_accept
        self.attr_special = DFA8_special
        self.attr_transition = DFA8_transition
      end
      
      typesig { [] }
      def get_description
        return "177:1: compilationUnit : ( annotations ( packageDeclaration ( importDeclaration )* ( typeDeclaration )* | classOrInterfaceDeclaration ( typeDeclaration )* ) | ( packageDeclaration )? ( importDeclaration )* ( typeDeclaration )* );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la8_1 = input._la(1)
          index8_1 = input.index
          input.rewind
          s = -1
          if ((synpred5__java))
            s = 16
          else
            if ((true))
              s = 2
            end
          end
          input.seek(index8_1)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 8, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa8, :initialize
    end }
    
    const_set_lazy(:DFA81_eotS) { ("\57".to_u << 0xffff << "") }
    const_attr_reader  :DFA81_eotS
    
    const_set_lazy(:DFA81_eofS) { ("\57".to_u << 0xffff << "") }
    const_attr_reader  :DFA81_eofS
    
    const_set_lazy(:DFA81_minS) { ("\1\4\1".to_u << 0xffff << "\15\0\40".to_u << 0xffff << "") }
    const_attr_reader  :DFA81_minS
    
    const_set_lazy(:DFA81_maxS) { ("\1\161\1".to_u << 0xffff << "\15\0\40".to_u << 0xffff << "") }
    const_attr_reader  :DFA81_maxS
    
    const_set_lazy(:DFA81_acceptS) { ("\1".to_u << 0xffff << "\1\1\15".to_u << 0xffff << "\1\2\37".to_u << 0xffff << "") }
    const_attr_reader  :DFA81_acceptS
    
    const_set_lazy(:DFA81_specialS) { ("\2".to_u << 0xffff << "\1\0\1\1\1\2\1\3\1\4\1\5\1\6\1\7\1\10\1\11\1\12\1\13\1\14") + ("\40".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA81_specialS
    
    const_set_lazy(:DFA81_transitionS) { Array.typed(String).new([("\1\14\1\17\1\6\1\7\1\10\3\5\1\17\15".to_u << 0xffff << "\1\17\1".to_u << 0xffff << "\1\17") + ("\2".to_u << 0xffff << "\7\17\2".to_u << 0xffff << "\1\1\3".to_u << 0xffff << "\3\17\1\16\5".to_u << 0xffff << "\1\17\2".to_u << 0xffff << "") + ("\10\15\1".to_u << 0xffff << "\1\4\1\3\2".to_u << 0xffff << "\1\2\1\12\2\11\1\17\2".to_u << 0xffff << "\1") + ("\17\1".to_u << 0xffff << "\4\17\1".to_u << 0xffff << "\5\17\21".to_u << 0xffff << "\2\17\2".to_u << 0xffff << "\4\17\1\13"), "", ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA81_transitionS
    
    const_set_lazy(:DFA81_eot) { DFA.unpack_encoded_string(DFA81_eotS) }
    const_attr_reader  :DFA81_eot
    
    const_set_lazy(:DFA81_eof) { DFA.unpack_encoded_string(DFA81_eofS) }
    const_attr_reader  :DFA81_eof
    
    const_set_lazy(:DFA81_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA81_minS) }
    const_attr_reader  :DFA81_min
    
    const_set_lazy(:DFA81_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA81_maxS) }
    const_attr_reader  :DFA81_max
    
    const_set_lazy(:DFA81_accept) { DFA.unpack_encoded_string(DFA81_acceptS) }
    const_attr_reader  :DFA81_accept
    
    const_set_lazy(:DFA81_special) { DFA.unpack_encoded_string(DFA81_specialS) }
    const_attr_reader  :DFA81_special
    
    when_class_loaded do
      num_states = DFA81_transitionS.attr_length
      const_set :DFA81_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA81_transition[i] = DFA.unpack_encoded_string(DFA81_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA81) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 81
        self.attr_eot = DFA81_eot
        self.attr_eof = DFA81_eof
        self.attr_min = DFA81_min
        self.attr_max = DFA81_max
        self.attr_accept = DFA81_accept
        self.attr_special = DFA81_special
        self.attr_transition = DFA81_transition
      end
      
      typesig { [] }
      def get_description
        return "492:13: ( explicitConstructorInvocation )?"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la81_2 = input._la(1)
          index81_2 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_2)
          if (s >= 0)
            return s
          end
        when 1
          la81_3 = input._la(1)
          index81_3 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_3)
          if (s >= 0)
            return s
          end
        when 2
          la81_4 = input._la(1)
          index81_4 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_4)
          if (s >= 0)
            return s
          end
        when 3
          la81_5 = input._la(1)
          index81_5 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_5)
          if (s >= 0)
            return s
          end
        when 4
          la81_6 = input._la(1)
          index81_6 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_6)
          if (s >= 0)
            return s
          end
        when 5
          la81_7 = input._la(1)
          index81_7 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_7)
          if (s >= 0)
            return s
          end
        when 6
          la81_8 = input._la(1)
          index81_8 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_8)
          if (s >= 0)
            return s
          end
        when 7
          la81_9 = input._la(1)
          index81_9 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_9)
          if (s >= 0)
            return s
          end
        when 8
          la81_10 = input._la(1)
          index81_10 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_10)
          if (s >= 0)
            return s
          end
        when 9
          la81_11 = input._la(1)
          index81_11 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_11)
          if (s >= 0)
            return s
          end
        when 10
          la81_12 = input._la(1)
          index81_12 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_12)
          if (s >= 0)
            return s
          end
        when 11
          la81_13 = input._la(1)
          index81_13 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_13)
          if (s >= 0)
            return s
          end
        when 12
          la81_14 = input._la(1)
          index81_14 = input.index
          input.rewind
          s = -1
          if ((synpred113__java))
            s = 1
          else
            if ((true))
              s = 15
            end
          end
          input.seek(index81_14)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 81, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa81, :initialize
    end }
    
    const_set_lazy(:DFA85_eotS) { ("\17".to_u << 0xffff << "") }
    const_attr_reader  :DFA85_eotS
    
    const_set_lazy(:DFA85_eofS) { ("\17".to_u << 0xffff << "") }
    const_attr_reader  :DFA85_eofS
    
    const_set_lazy(:DFA85_minS) { ("\1\4\1".to_u << 0xffff << "\1\0\1".to_u << 0xffff << "\1\0\12".to_u << 0xffff << "") }
    const_attr_reader  :DFA85_minS
    
    const_set_lazy(:DFA85_maxS) { ("\1\161\1".to_u << 0xffff << "\1\0\1".to_u << 0xffff << "\1\0\12".to_u << 0xffff << "") }
    const_attr_reader  :DFA85_maxS
    
    const_set_lazy(:DFA85_acceptS) { ("\1".to_u << 0xffff << "\1\1\1".to_u << 0xffff << "\1\2\13".to_u << 0xffff << "") }
    const_attr_reader  :DFA85_acceptS
    
    const_set_lazy(:DFA85_specialS) { ("\2".to_u << 0xffff << "\1\0\1".to_u << 0xffff << "\1\1\12".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA85_specialS
    
    const_set_lazy(:DFA85_transitionS) { Array.typed(String).new([("\1\3\1".to_u << 0xffff << "\6\3\34".to_u << 0xffff << "\1\1\6".to_u << 0xffff << "\1\3\10".to_u << 0xffff << "\10\3\1".to_u << 0xffff << "") + ("\1\4\1\3\2".to_u << 0xffff << "\1\2\3\3\50".to_u << 0xffff << "\1\3"), "", ("\1".to_u << 0xffff << ""), "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA85_transitionS
    
    const_set_lazy(:DFA85_eot) { DFA.unpack_encoded_string(DFA85_eotS) }
    const_attr_reader  :DFA85_eot
    
    const_set_lazy(:DFA85_eof) { DFA.unpack_encoded_string(DFA85_eofS) }
    const_attr_reader  :DFA85_eof
    
    const_set_lazy(:DFA85_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA85_minS) }
    const_attr_reader  :DFA85_min
    
    const_set_lazy(:DFA85_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA85_maxS) }
    const_attr_reader  :DFA85_max
    
    const_set_lazy(:DFA85_accept) { DFA.unpack_encoded_string(DFA85_acceptS) }
    const_attr_reader  :DFA85_accept
    
    const_set_lazy(:DFA85_special) { DFA.unpack_encoded_string(DFA85_specialS) }
    const_attr_reader  :DFA85_special
    
    when_class_loaded do
      num_states = DFA85_transitionS.attr_length
      const_set :DFA85_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA85_transition[i] = DFA.unpack_encoded_string(DFA85_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA85) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 85
        self.attr_eot = DFA85_eot
        self.attr_eof = DFA85_eof
        self.attr_min = DFA85_min
        self.attr_max = DFA85_max
        self.attr_accept = DFA85_accept
        self.attr_special = DFA85_special
        self.attr_transition = DFA85_transition
      end
      
      typesig { [] }
      def get_description
        return "495:1: explicitConstructorInvocation : ( ( nonWildcardTypeArguments )? ( 'this' | 'super' ) arguments ';' | primary '.' ( nonWildcardTypeArguments )? 'super' arguments ';' );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la85_2 = input._la(1)
          index85_2 = input.index
          input.rewind
          s = -1
          if ((synpred117__java))
            s = 1
          else
            if ((true))
              s = 3
            end
          end
          input.seek(index85_2)
          if (s >= 0)
            return s
          end
        when 1
          la85_4 = input._la(1)
          index85_4 = input.index
          input.rewind
          s = -1
          if ((synpred117__java))
            s = 1
          else
            if ((true))
              s = 3
            end
          end
          input.seek(index85_4)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 85, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa85, :initialize
    end }
    
    const_set_lazy(:DFA106_eotS) { ("\56".to_u << 0xffff << "") }
    const_attr_reader  :DFA106_eotS
    
    const_set_lazy(:DFA106_eofS) { ("\56".to_u << 0xffff << "") }
    const_attr_reader  :DFA106_eofS
    
    const_set_lazy(:DFA106_minS) { ("\1\4\4\0\51".to_u << 0xffff << "") }
    const_attr_reader  :DFA106_minS
    
    const_set_lazy(:DFA106_maxS) { ("\1\161\4\0\51".to_u << 0xffff << "") }
    const_attr_reader  :DFA106_maxS
    
    const_set_lazy(:DFA106_acceptS) { ("\5".to_u << 0xffff << "\1\2\10".to_u << 0xffff << "\1\3\36".to_u << 0xffff << "\1\1") }
    const_attr_reader  :DFA106_acceptS
    
    const_set_lazy(:DFA106_specialS) { ("\1".to_u << 0xffff << "\1\0\1\1\1\2\1\3\51".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA106_specialS
    
    const_set_lazy(:DFA106_transitionS) { Array.typed(String).new([("\1\3\1\5\7\16\15".to_u << 0xffff << "\1\16\1".to_u << 0xffff << "\1\5\2".to_u << 0xffff << "\4\5\1\1\2\5") + ("\6".to_u << 0xffff << "\1\16\1".to_u << 0xffff << "\1\5\1\16\5".to_u << 0xffff << "\1\16\2".to_u << 0xffff << "\10\4\1".to_u << 0xffff << "") + ("\2\16\2".to_u << 0xffff << "\4\16\1\2\2".to_u << 0xffff << "\1\16\1".to_u << 0xffff << "\4\16\1".to_u << 0xffff << "\5\16") + ("\21".to_u << 0xffff << "\2\16\2".to_u << 0xffff << "\5\16"), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA106_transitionS
    
    const_set_lazy(:DFA106_eot) { DFA.unpack_encoded_string(DFA106_eotS) }
    const_attr_reader  :DFA106_eot
    
    const_set_lazy(:DFA106_eof) { DFA.unpack_encoded_string(DFA106_eofS) }
    const_attr_reader  :DFA106_eof
    
    const_set_lazy(:DFA106_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA106_minS) }
    const_attr_reader  :DFA106_min
    
    const_set_lazy(:DFA106_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA106_maxS) }
    const_attr_reader  :DFA106_max
    
    const_set_lazy(:DFA106_accept) { DFA.unpack_encoded_string(DFA106_acceptS) }
    const_attr_reader  :DFA106_accept
    
    const_set_lazy(:DFA106_special) { DFA.unpack_encoded_string(DFA106_specialS) }
    const_attr_reader  :DFA106_special
    
    when_class_loaded do
      num_states = DFA106_transitionS.attr_length
      const_set :DFA106_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA106_transition[i] = DFA.unpack_encoded_string(DFA106_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA106) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 106
        self.attr_eot = DFA106_eot
        self.attr_eof = DFA106_eof
        self.attr_min = DFA106_min
        self.attr_max = DFA106_max
        self.attr_accept = DFA106_accept
        self.attr_special = DFA106_special
        self.attr_transition = DFA106_transition
      end
      
      typesig { [] }
      def get_description
        return "600:1: blockStatement : ( localVariableDeclarationStatement | classOrInterfaceDeclaration | statement );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la106_1 = input._la(1)
          index106_1 = input.index
          input.rewind
          s = -1
          if ((synpred151__java))
            s = 45
          else
            if ((synpred152__java))
              s = 5
            end
          end
          input.seek(index106_1)
          if (s >= 0)
            return s
          end
        when 1
          la106_2 = input._la(1)
          index106_2 = input.index
          input.rewind
          s = -1
          if ((synpred151__java))
            s = 45
          else
            if ((synpred152__java))
              s = 5
            end
          end
          input.seek(index106_2)
          if (s >= 0)
            return s
          end
        when 2
          la106_3 = input._la(1)
          index106_3 = input.index
          input.rewind
          s = -1
          if ((synpred151__java))
            s = 45
          else
            if ((true))
              s = 14
            end
          end
          input.seek(index106_3)
          if (s >= 0)
            return s
          end
        when 3
          la106_4 = input._la(1)
          index106_4 = input.index
          input.rewind
          s = -1
          if ((synpred151__java))
            s = 45
          else
            if ((true))
              s = 14
            end
          end
          input.seek(index106_4)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 106, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa106, :initialize
    end }
    
    const_set_lazy(:DFA114_eotS) { ("\22".to_u << 0xffff << "") }
    const_attr_reader  :DFA114_eotS
    
    const_set_lazy(:DFA114_eofS) { ("\22".to_u << 0xffff << "") }
    const_attr_reader  :DFA114_eofS
    
    const_set_lazy(:DFA114_minS) { ("\1\4\17".to_u << 0xffff << "\1\32\1".to_u << 0xffff << "") }
    const_attr_reader  :DFA114_minS
    
    const_set_lazy(:DFA114_maxS) { ("\1\161\17".to_u << 0xffff << "\1\156\1".to_u << 0xffff << "") }
    const_attr_reader  :DFA114_maxS
    
    const_set_lazy(:DFA114_acceptS) { ("\1".to_u << 0xffff << "\1\1\1\2\1\3\1\4\1\5\1\6\1\7\1\10\1\11\1\12\1\13\1\14\1") + ("\15\1\16\1\17\1".to_u << 0xffff << "\1\20") }
    const_attr_reader  :DFA114_acceptS
    
    const_set_lazy(:DFA114_specialS) { ("\22".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA114_specialS
    
    const_set_lazy(:DFA114_transitionS) { Array.typed(String).new([("\1\20\1".to_u << 0xffff << "\6\17\1\2\15".to_u << 0xffff << "\1\16\21".to_u << 0xffff << "\1\1\2".to_u << 0xffff << "\1") + ("\17\5".to_u << 0xffff << "\1\11\2".to_u << 0xffff << "\10\17\1".to_u << 0xffff << "\2\17\2".to_u << 0xffff << "\4\17\3".to_u << 0xffff << "") + ("\1\3\1".to_u << 0xffff << "\1\4\1\5\1\6\1\7\1".to_u << 0xffff << "\1\10\1\12\1\13\1\14\1\15") + ("\21".to_u << 0xffff << "\2\17\2".to_u << 0xffff << "\5\17"), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ("\1\17\2".to_u << 0xffff << "\2\17\11".to_u << 0xffff << "\1\17\1".to_u << 0xffff << "\2\17\4".to_u << 0xffff << "\1\17") + ("\2".to_u << 0xffff << "\1\17\14".to_u << 0xffff << "\1\17\1".to_u << 0xffff << "\1\17\10".to_u << 0xffff << "\1\21\16".to_u << 0xffff << "") + "\25\17", ""]) }
    const_attr_reader  :DFA114_transitionS
    
    const_set_lazy(:DFA114_eot) { DFA.unpack_encoded_string(DFA114_eotS) }
    const_attr_reader  :DFA114_eot
    
    const_set_lazy(:DFA114_eof) { DFA.unpack_encoded_string(DFA114_eofS) }
    const_attr_reader  :DFA114_eof
    
    const_set_lazy(:DFA114_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA114_minS) }
    const_attr_reader  :DFA114_min
    
    const_set_lazy(:DFA114_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA114_maxS) }
    const_attr_reader  :DFA114_max
    
    const_set_lazy(:DFA114_accept) { DFA.unpack_encoded_string(DFA114_acceptS) }
    const_attr_reader  :DFA114_accept
    
    const_set_lazy(:DFA114_special) { DFA.unpack_encoded_string(DFA114_specialS) }
    const_attr_reader  :DFA114_special
    
    when_class_loaded do
      num_states = DFA114_transitionS.attr_length
      const_set :DFA114_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA114_transition[i] = DFA.unpack_encoded_string(DFA114_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA114) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 114
        self.attr_eot = DFA114_eot
        self.attr_eof = DFA114_eof
        self.attr_min = DFA114_min
        self.attr_max = DFA114_max
        self.attr_accept = DFA114_accept
        self.attr_special = DFA114_special
        self.attr_transition = DFA114_transition
      end
      
      typesig { [] }
      def get_description
        return "618:1: statement : ( block | ASSERT expression ( ':' expression )? ';' | 'if' parExpression statement ( options {k=1; } : 'else' statement )? | 'for' '(' forControl ')' statement | 'while' parExpression statement | 'do' statement 'while' parExpression ';' | 'try' block ( catches 'finally' block | catches | 'finally' block ) | 'switch' parExpression '{' switchBlockStatementGroups '}' | 'synchronized' parExpression block | 'return' ( expression )? ';' | 'throw' expression ';' | 'break' ( Identifier )? ';' | 'continue' ( Identifier )? ';' | ';' | statementExpression ';' | Identifier ':' statement );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      private
      alias_method :initialize__dfa114, :initialize
    end }
    
    const_set_lazy(:DFA123_eotS) { ("".to_u << 0x0087 << "".to_u << 0xffff << "") }
    const_attr_reader  :DFA123_eotS
    
    const_set_lazy(:DFA123_eofS) { ("".to_u << 0x0087 << "".to_u << 0xffff << "") }
    const_attr_reader  :DFA123_eofS
    
    const_set_lazy(:DFA123_minS) { ("\5\4\22".to_u << 0xffff << "\10\4\1\32\30".to_u << 0xffff << "\1\61\1".to_u << 0xffff << "\1\32\21\0\2".to_u << 0xffff << "") + ("\3\0\21".to_u << 0xffff << "\1\0\5".to_u << 0xffff << "\1\0\30".to_u << 0xffff << "\1\0\5".to_u << 0xffff << "") }
    const_attr_reader  :DFA123_minS
    
    const_set_lazy(:DFA123_maxS) { ("\1\161\1\111\1\4\1\156\1\60\22".to_u << 0xffff << "\2\60\1\111\1\4\1\111\3\161") + ("\1\113\30".to_u << 0xffff << "\1\61\1".to_u << 0xffff << "\1\113\21\0\2".to_u << 0xffff << "\3\0\21".to_u << 0xffff << "\1\0") + ("\5".to_u << 0xffff << "\1\0\30".to_u << 0xffff << "\1\0\5".to_u << 0xffff << "") }
    const_attr_reader  :DFA123_maxS
    
    const_set_lazy(:DFA123_acceptS) { ("\5".to_u << 0xffff << "\1\2\166".to_u << 0xffff << "\1\1\12".to_u << 0xffff << "") }
    const_attr_reader  :DFA123_acceptS
    
    const_set_lazy(:DFA123_specialS) { ("\73".to_u << 0xffff << "\1\0\1\1\1\2\1\3\1\4\1\5\1\6\1\7\1\10\1\11\1\12\1\13\1") + ("\14\1\15\1\16\1\17\1\20\2".to_u << 0xffff << "\1\21\1\22\1\23\21".to_u << 0xffff << "\1\24\5".to_u << 0xffff << "") + ("\1\25\30".to_u << 0xffff << "\1\26\5".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA123_specialS
    
    const_set_lazy(:DFA123_transitionS) { Array.typed(String).new([("\1\3\1".to_u << 0xffff << "\6\5\16".to_u << 0xffff << "\1\5\10".to_u << 0xffff << "\1\1\13".to_u << 0xffff << "\1\5\10".to_u << 0xffff << "") + ("\10\4\1".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\4\5\1\2\37".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\5\5"), ("\1\27\36".to_u << 0xffff << "\1\31\24".to_u << 0xffff << "\10\30\11".to_u << 0xffff << "\1\32"), "\1\33", ("\1\37\25".to_u << 0xffff << "\1\5\2".to_u << 0xffff << "\1\35\1\5\11".to_u << 0xffff << "\1\34\3\5\4".to_u << 0xffff << "") + ("\1\36\2".to_u << 0xffff << "\1\5\14".to_u << 0xffff << "\1\5\1".to_u << 0xffff << "\1\5\27".to_u << 0xffff << "\25\5"), ("\1\72\30".to_u << 0xffff << "\1\5\22".to_u << 0xffff << "\1\70"), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ("\1\76\30".to_u << 0xffff << "\1\74\12".to_u << 0xffff << "\1\73\7".to_u << 0xffff << "\1\75"), ("\1\100\53".to_u << 0xffff << "\1\77"), ("\1\101\36".to_u << 0xffff << "\1\103\24".to_u << 0xffff << "\10\102\11".to_u << 0xffff << "\1\104"), "\1\105", ("\1\110\30".to_u << 0xffff << "\1\106\5".to_u << 0xffff << "\1\112\24".to_u << 0xffff << "\10\111\2".to_u << 0xffff << "") + ("\1\107\6".to_u << 0xffff << "\1\113"), ("\1\116\1".to_u << 0xffff << "\6\5\34".to_u << 0xffff << "\1\5\6".to_u << 0xffff << "\1\5\3".to_u << 0xffff << "\1\5\4".to_u << 0xffff << "") + ("\10\117\1\120\2\5\2".to_u << 0xffff << "\4\5\40".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\5\5"), ("\1\142\40".to_u << 0xffff << "\1\5\2".to_u << 0xffff << "\1\5\30".to_u << 0xffff << "\1\5\3".to_u << 0xffff << "\1\5\53") + ("".to_u << 0xffff << "\1\5"), ("\1\5\1".to_u << 0xffff << "\6\5\43".to_u << 0xffff << "\1\5\1".to_u << 0xffff << "\1\150\6".to_u << 0xffff << "\10\5\1") + ("".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\4\5\40".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\5\5"), ("\1\5\16".to_u << 0xffff << "\1\5\6".to_u << 0xffff << "\1\5\2".to_u << 0xffff << "\1\5\27".to_u << 0xffff << "\1\174"), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ("\1".to_u << 0x0081 << ""), "", ("\1\5\16".to_u << 0xffff << "\1\5\6".to_u << 0xffff << "\1\5\2".to_u << 0xffff << "\1\5\27".to_u << 0xffff << "\1\174"), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), "", "", ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ("\1".to_u << 0xffff << ""), "", "", "", "", ""]) }
    const_attr_reader  :DFA123_transitionS
    
    const_set_lazy(:DFA123_eot) { DFA.unpack_encoded_string(DFA123_eotS) }
    const_attr_reader  :DFA123_eot
    
    const_set_lazy(:DFA123_eof) { DFA.unpack_encoded_string(DFA123_eofS) }
    const_attr_reader  :DFA123_eof
    
    const_set_lazy(:DFA123_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA123_minS) }
    const_attr_reader  :DFA123_min
    
    const_set_lazy(:DFA123_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA123_maxS) }
    const_attr_reader  :DFA123_max
    
    const_set_lazy(:DFA123_accept) { DFA.unpack_encoded_string(DFA123_acceptS) }
    const_attr_reader  :DFA123_accept
    
    const_set_lazy(:DFA123_special) { DFA.unpack_encoded_string(DFA123_specialS) }
    const_attr_reader  :DFA123_special
    
    when_class_loaded do
      num_states = DFA123_transitionS.attr_length
      const_set :DFA123_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA123_transition[i] = DFA.unpack_encoded_string(DFA123_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA123) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 123
        self.attr_eot = DFA123_eot
        self.attr_eof = DFA123_eof
        self.attr_min = DFA123_min
        self.attr_max = DFA123_max
        self.attr_accept = DFA123_accept
        self.attr_special = DFA123_special
        self.attr_transition = DFA123_transition
      end
      
      typesig { [] }
      def get_description
        return "671:1: forControl options {k=3; } : ( enhancedForControl | ( forInit )? ';' ( expression )? ';' ( forUpdate )? );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la123_59 = input._la(1)
          index123_59 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_59)
          if (s >= 0)
            return s
          end
        when 1
          la123_60 = input._la(1)
          index123_60 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_60)
          if (s >= 0)
            return s
          end
        when 2
          la123_61 = input._la(1)
          index123_61 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_61)
          if (s >= 0)
            return s
          end
        when 3
          la123_62 = input._la(1)
          index123_62 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_62)
          if (s >= 0)
            return s
          end
        when 4
          la123_63 = input._la(1)
          index123_63 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_63)
          if (s >= 0)
            return s
          end
        when 5
          la123_64 = input._la(1)
          index123_64 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_64)
          if (s >= 0)
            return s
          end
        when 6
          la123_65 = input._la(1)
          index123_65 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_65)
          if (s >= 0)
            return s
          end
        when 7
          la123_66 = input._la(1)
          index123_66 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_66)
          if (s >= 0)
            return s
          end
        when 8
          la123_67 = input._la(1)
          index123_67 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_67)
          if (s >= 0)
            return s
          end
        when 9
          la123_68 = input._la(1)
          index123_68 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_68)
          if (s >= 0)
            return s
          end
        when 10
          la123_69 = input._la(1)
          index123_69 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_69)
          if (s >= 0)
            return s
          end
        when 11
          la123_70 = input._la(1)
          index123_70 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_70)
          if (s >= 0)
            return s
          end
        when 12
          la123_71 = input._la(1)
          index123_71 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_71)
          if (s >= 0)
            return s
          end
        when 13
          la123_72 = input._la(1)
          index123_72 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_72)
          if (s >= 0)
            return s
          end
        when 14
          la123_73 = input._la(1)
          index123_73 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_73)
          if (s >= 0)
            return s
          end
        when 15
          la123_74 = input._la(1)
          index123_74 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_74)
          if (s >= 0)
            return s
          end
        when 16
          la123_75 = input._la(1)
          index123_75 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_75)
          if (s >= 0)
            return s
          end
        when 17
          la123_78 = input._la(1)
          index123_78 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_78)
          if (s >= 0)
            return s
          end
        when 18
          la123_79 = input._la(1)
          index123_79 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_79)
          if (s >= 0)
            return s
          end
        when 19
          la123_80 = input._la(1)
          index123_80 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_80)
          if (s >= 0)
            return s
          end
        when 20
          la123_98 = input._la(1)
          index123_98 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_98)
          if (s >= 0)
            return s
          end
        when 21
          la123_104 = input._la(1)
          index123_104 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_104)
          if (s >= 0)
            return s
          end
        when 22
          la123_129 = input._la(1)
          index123_129 = input.index
          input.rewind
          s = -1
          if ((synpred182__java))
            s = 124
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index123_129)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 123, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa123, :initialize
    end }
    
    const_set_lazy(:DFA124_eotS) { ("\26".to_u << 0xffff << "") }
    const_attr_reader  :DFA124_eotS
    
    const_set_lazy(:DFA124_eofS) { ("\26".to_u << 0xffff << "") }
    const_attr_reader  :DFA124_eofS
    
    const_set_lazy(:DFA124_minS) { ("\1\4\2".to_u << 0xffff << "\2\0\21".to_u << 0xffff << "") }
    const_attr_reader  :DFA124_minS
    
    const_set_lazy(:DFA124_maxS) { ("\1\161\2".to_u << 0xffff << "\2\0\21".to_u << 0xffff << "") }
    const_attr_reader  :DFA124_maxS
    
    const_set_lazy(:DFA124_acceptS) { ("\1".to_u << 0xffff << "\1\1\3".to_u << 0xffff << "\1\2\20".to_u << 0xffff << "") }
    const_attr_reader  :DFA124_acceptS
    
    const_set_lazy(:DFA124_specialS) { ("\3".to_u << 0xffff << "\1\0\1\1\21".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA124_specialS
    
    const_set_lazy(:DFA124_transitionS) { Array.typed(String).new([("\1\3\1".to_u << 0xffff << "\6\5\27".to_u << 0xffff << "\1\1\13".to_u << 0xffff << "\1\5\10".to_u << 0xffff << "\10\4\1".to_u << 0xffff << "") + ("\2\5\2".to_u << 0xffff << "\4\5\1\1\37".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\5\5"), "", "", ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA124_transitionS
    
    const_set_lazy(:DFA124_eot) { DFA.unpack_encoded_string(DFA124_eotS) }
    const_attr_reader  :DFA124_eot
    
    const_set_lazy(:DFA124_eof) { DFA.unpack_encoded_string(DFA124_eofS) }
    const_attr_reader  :DFA124_eof
    
    const_set_lazy(:DFA124_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA124_minS) }
    const_attr_reader  :DFA124_min
    
    const_set_lazy(:DFA124_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA124_maxS) }
    const_attr_reader  :DFA124_max
    
    const_set_lazy(:DFA124_accept) { DFA.unpack_encoded_string(DFA124_acceptS) }
    const_attr_reader  :DFA124_accept
    
    const_set_lazy(:DFA124_special) { DFA.unpack_encoded_string(DFA124_specialS) }
    const_attr_reader  :DFA124_special
    
    when_class_loaded do
      num_states = DFA124_transitionS.attr_length
      const_set :DFA124_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA124_transition[i] = DFA.unpack_encoded_string(DFA124_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA124) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 124
        self.attr_eot = DFA124_eot
        self.attr_eof = DFA124_eof
        self.attr_min = DFA124_min
        self.attr_max = DFA124_max
        self.attr_accept = DFA124_accept
        self.attr_special = DFA124_special
        self.attr_transition = DFA124_transition
      end
      
      typesig { [] }
      def get_description
        return "677:1: forInit : ( localVariableDeclaration | expressionList );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la124_3 = input._la(1)
          index124_3 = input.index
          input.rewind
          s = -1
          if ((synpred186__java))
            s = 1
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index124_3)
          if (s >= 0)
            return s
          end
        when 1
          la124_4 = input._la(1)
          index124_4 = input.index
          input.rewind
          s = -1
          if ((synpred186__java))
            s = 1
          else
            if ((true))
              s = 5
            end
          end
          input.seek(index124_4)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 124, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa124, :initialize
    end }
    
    const_set_lazy(:DFA126_eotS) { ("\16".to_u << 0xffff << "") }
    const_attr_reader  :DFA126_eotS
    
    const_set_lazy(:DFA126_eofS) { ("\1\14\15".to_u << 0xffff << "") }
    const_attr_reader  :DFA126_eofS
    
    const_set_lazy(:DFA126_minS) { ("\1\32\13\0\2".to_u << 0xffff << "") }
    const_attr_reader  :DFA126_minS
    
    const_set_lazy(:DFA126_maxS) { ("\1\141\13\0\2".to_u << 0xffff << "") }
    const_attr_reader  :DFA126_maxS
    
    const_set_lazy(:DFA126_acceptS) { ("\14".to_u << 0xffff << "\1\2\1\1") }
    const_attr_reader  :DFA126_acceptS
    
    const_set_lazy(:DFA126_specialS) { ("\1".to_u << 0xffff << "\1\5\1\2\1\12\1\10\1\1\1\4\1\7\1\11\1\0\1\6\1\3\2".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA126_specialS
    
    const_set_lazy(:DFA126_transitionS) { Array.typed(String).new([("\1\14\15".to_u << 0xffff << "\1\12\1\14\1\13\2".to_u << 0xffff << "\1\14\3".to_u << 0xffff << "\1\14\1".to_u << 0xffff << "") + ("\1\1\17".to_u << 0xffff << "\1\14\7".to_u << 0xffff << "\1\14\16".to_u << 0xffff << "\1\2\1\3\1\4\1\5\1\6") + "\1\7\1\10\1\11", ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), ("\1".to_u << 0xffff << ""), "", ""]) }
    const_attr_reader  :DFA126_transitionS
    
    const_set_lazy(:DFA126_eot) { DFA.unpack_encoded_string(DFA126_eotS) }
    const_attr_reader  :DFA126_eot
    
    const_set_lazy(:DFA126_eof) { DFA.unpack_encoded_string(DFA126_eofS) }
    const_attr_reader  :DFA126_eof
    
    const_set_lazy(:DFA126_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA126_minS) }
    const_attr_reader  :DFA126_min
    
    const_set_lazy(:DFA126_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA126_maxS) }
    const_attr_reader  :DFA126_max
    
    const_set_lazy(:DFA126_accept) { DFA.unpack_encoded_string(DFA126_acceptS) }
    const_attr_reader  :DFA126_accept
    
    const_set_lazy(:DFA126_special) { DFA.unpack_encoded_string(DFA126_specialS) }
    const_attr_reader  :DFA126_special
    
    when_class_loaded do
      num_states = DFA126_transitionS.attr_length
      const_set :DFA126_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA126_transition[i] = DFA.unpack_encoded_string(DFA126_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA126) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 126
        self.attr_eot = DFA126_eot
        self.attr_eof = DFA126_eof
        self.attr_min = DFA126_min
        self.attr_max = DFA126_max
        self.attr_accept = DFA126_accept
        self.attr_special = DFA126_special
        self.attr_transition = DFA126_transition
      end
      
      typesig { [] }
      def get_description
        return "709:31: ( assignmentOperator expression )?"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la126_9 = input._la(1)
          index126_9 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_9)
          if (s >= 0)
            return s
          end
        when 1
          la126_5 = input._la(1)
          index126_5 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_5)
          if (s >= 0)
            return s
          end
        when 2
          la126_2 = input._la(1)
          index126_2 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_2)
          if (s >= 0)
            return s
          end
        when 3
          la126_11 = input._la(1)
          index126_11 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_11)
          if (s >= 0)
            return s
          end
        when 4
          la126_6 = input._la(1)
          index126_6 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_6)
          if (s >= 0)
            return s
          end
        when 5
          la126_1 = input._la(1)
          index126_1 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_1)
          if (s >= 0)
            return s
          end
        when 6
          la126_10 = input._la(1)
          index126_10 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_10)
          if (s >= 0)
            return s
          end
        when 7
          la126_7 = input._la(1)
          index126_7 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_7)
          if (s >= 0)
            return s
          end
        when 8
          la126_4 = input._la(1)
          index126_4 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_4)
          if (s >= 0)
            return s
          end
        when 9
          la126_8 = input._la(1)
          index126_8 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_8)
          if (s >= 0)
            return s
          end
        when 10
          la126_3 = input._la(1)
          index126_3 = input.index
          input.rewind
          s = -1
          if ((synpred188__java))
            s = 13
          else
            if ((true))
              s = 12
            end
          end
          input.seek(index126_3)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 126, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa126, :initialize
    end }
    
    const_set_lazy(:DFA127_eotS) { ("\17".to_u << 0xffff << "") }
    const_attr_reader  :DFA127_eotS
    
    const_set_lazy(:DFA127_eofS) { ("\17".to_u << 0xffff << "") }
    const_attr_reader  :DFA127_eofS
    
    const_set_lazy(:DFA127_minS) { ("\1\50\12".to_u << 0xffff << "\2\52\2".to_u << 0xffff << "") }
    const_attr_reader  :DFA127_minS
    
    const_set_lazy(:DFA127_maxS) { ("\1\141\12".to_u << 0xffff << "\1\52\1\63\2".to_u << 0xffff << "") }
    const_attr_reader  :DFA127_maxS
    
    const_set_lazy(:DFA127_acceptS) { ("\1".to_u << 0xffff << "\1\1\1\2\1\3\1\4\1\5\1\6\1\7\1\10\1\11\1\12\2".to_u << 0xffff << "\1\13") + "\1\14" }
    const_attr_reader  :DFA127_acceptS
    
    const_set_lazy(:DFA127_specialS) { ("\1\1\13".to_u << 0xffff << "\1\0\2".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA127_specialS
    
    const_set_lazy(:DFA127_transitionS) { Array.typed(String).new([("\1\12\1".to_u << 0xffff << "\1\13\10".to_u << 0xffff << "\1\1\46".to_u << 0xffff << "\1\2\1\3\1\4\1\5\1\6") + "\1\7\1\10\1\11", "", "", "", "", "", "", "", "", "", "", "\1\14", ("\1\15\10".to_u << 0xffff << "\1\16"), "", ""]) }
    const_attr_reader  :DFA127_transitionS
    
    const_set_lazy(:DFA127_eot) { DFA.unpack_encoded_string(DFA127_eotS) }
    const_attr_reader  :DFA127_eot
    
    const_set_lazy(:DFA127_eof) { DFA.unpack_encoded_string(DFA127_eofS) }
    const_attr_reader  :DFA127_eof
    
    const_set_lazy(:DFA127_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA127_minS) }
    const_attr_reader  :DFA127_min
    
    const_set_lazy(:DFA127_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA127_maxS) }
    const_attr_reader  :DFA127_max
    
    const_set_lazy(:DFA127_accept) { DFA.unpack_encoded_string(DFA127_acceptS) }
    const_attr_reader  :DFA127_accept
    
    const_set_lazy(:DFA127_special) { DFA.unpack_encoded_string(DFA127_specialS) }
    const_attr_reader  :DFA127_special
    
    when_class_loaded do
      num_states = DFA127_transitionS.attr_length
      const_set :DFA127_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA127_transition[i] = DFA.unpack_encoded_string(DFA127_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA127) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 127
        self.attr_eot = DFA127_eot
        self.attr_eof = DFA127_eof
        self.attr_min = DFA127_min
        self.attr_max = DFA127_max
        self.attr_accept = DFA127_accept
        self.attr_special = DFA127_special
        self.attr_transition = DFA127_transition
      end
      
      typesig { [] }
      def get_description
        return "712:1: assignmentOperator : ( '=' | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '^=' | '%=' | ( '<' '<' '=' )=>t1= '<' t2= '<' t3= '=' {...}? | ( '>' '>' '>' '=' )=>t1= '>' t2= '>' t3= '>' t4= '=' {...}? | ( '>' '>' '=' )=>t1= '>' t2= '>' t3= '=' {...}?);"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la127_12 = input._la(1)
          index127_12 = input.index
          input.rewind
          s = -1
          if (((la127_12).equal?(42)) && (synpred199__java))
            s = 13
          else
            if (((la127_12).equal?(51)) && (synpred200__java))
              s = 14
            end
          end
          input.seek(index127_12)
          if (s >= 0)
            return s
          end
        when 1
          la127_0 = input._la(1)
          index127_0 = input.index
          input.rewind
          s = -1
          if (((la127_0).equal?(51)))
            s = 1
          else
            if (((la127_0).equal?(90)))
              s = 2
            else
              if (((la127_0).equal?(91)))
                s = 3
              else
                if (((la127_0).equal?(92)))
                  s = 4
                else
                  if (((la127_0).equal?(93)))
                    s = 5
                  else
                    if (((la127_0).equal?(94)))
                      s = 6
                    else
                      if (((la127_0).equal?(95)))
                        s = 7
                      else
                        if (((la127_0).equal?(96)))
                          s = 8
                        else
                          if (((la127_0).equal?(97)))
                            s = 9
                          else
                            if (((la127_0).equal?(40)) && (synpred198__java))
                              s = 10
                            else
                              if (((la127_0).equal?(42)))
                                s = 11
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          input.seek(index127_0)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 127, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa127, :initialize
    end }
    
    const_set_lazy(:DFA139_eotS) { ("\30".to_u << 0xffff << "") }
    const_attr_reader  :DFA139_eotS
    
    const_set_lazy(:DFA139_eofS) { ("\30".to_u << 0xffff << "") }
    const_attr_reader  :DFA139_eofS
    
    const_set_lazy(:DFA139_minS) { ("\1\50\1".to_u << 0xffff << "\1\52\1\4\24".to_u << 0xffff << "") }
    const_attr_reader  :DFA139_minS
    
    const_set_lazy(:DFA139_maxS) { ("\1\52\1".to_u << 0xffff << "\1\52\1\161\24".to_u << 0xffff << "") }
    const_attr_reader  :DFA139_maxS
    
    const_set_lazy(:DFA139_acceptS) { ("\1".to_u << 0xffff << "\1\1\2".to_u << 0xffff << "\1\2\23\3") }
    const_attr_reader  :DFA139_acceptS
    
    const_set_lazy(:DFA139_specialS) { ("\1\0\2".to_u << 0xffff << "\1\1\24".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA139_specialS
    
    const_set_lazy(:DFA139_transitionS) { Array.typed(String).new([("\1\1\1".to_u << 0xffff << "\1\2"), "", "\1\3", ("\1\25\1".to_u << 0xffff << "\1\17\1\20\1\21\3\16\36".to_u << 0xffff << "\1\4\4".to_u << 0xffff << "\1\27") + ("\10".to_u << 0xffff << "\10\26\1".to_u << 0xffff << "\1\15\1\13\2".to_u << 0xffff << "\1\14\1\23\2\22\40") + ("".to_u << 0xffff << "\1\5\1\6\2".to_u << 0xffff << "\1\7\1\10\1\11\1\12\1\24"), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA139_transitionS
    
    const_set_lazy(:DFA139_eot) { DFA.unpack_encoded_string(DFA139_eotS) }
    const_attr_reader  :DFA139_eot
    
    const_set_lazy(:DFA139_eof) { DFA.unpack_encoded_string(DFA139_eofS) }
    const_attr_reader  :DFA139_eof
    
    const_set_lazy(:DFA139_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA139_minS) }
    const_attr_reader  :DFA139_min
    
    const_set_lazy(:DFA139_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA139_maxS) }
    const_attr_reader  :DFA139_max
    
    const_set_lazy(:DFA139_accept) { DFA.unpack_encoded_string(DFA139_acceptS) }
    const_attr_reader  :DFA139_accept
    
    const_set_lazy(:DFA139_special) { DFA.unpack_encoded_string(DFA139_specialS) }
    const_attr_reader  :DFA139_special
    
    when_class_loaded do
      num_states = DFA139_transitionS.attr_length
      const_set :DFA139_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA139_transition[i] = DFA.unpack_encoded_string(DFA139_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA139) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 139
        self.attr_eot = DFA139_eot
        self.attr_eof = DFA139_eof
        self.attr_min = DFA139_min
        self.attr_max = DFA139_max
        self.attr_accept = DFA139_accept
        self.attr_special = DFA139_special
        self.attr_transition = DFA139_transition
      end
      
      typesig { [] }
      def get_description
        return "792:1: shiftOp : ( ( '<' '<' )=>t1= '<' t2= '<' {...}? | ( '>' '>' '>' )=>t1= '>' t2= '>' t3= '>' {...}? | ( '>' '>' )=>t1= '>' t2= '>' {...}?);"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la139_0 = input._la(1)
          index139_0 = input.index
          input.rewind
          s = -1
          if (((la139_0).equal?(40)) && (synpred215__java))
            s = 1
          else
            if (((la139_0).equal?(42)))
              s = 2
            end
          end
          input.seek(index139_0)
          if (s >= 0)
            return s
          end
        when 1
          la139_3 = input._la(1)
          index139_3 = input.index
          input.rewind
          s = -1
          if (((la139_3).equal?(42)) && (synpred216__java))
            s = 4
          else
            if (((la139_3).equal?(105)) && (synpred217__java))
              s = 5
            else
              if (((la139_3).equal?(106)) && (synpred217__java))
                s = 6
              else
                if (((la139_3).equal?(109)) && (synpred217__java))
                  s = 7
                else
                  if (((la139_3).equal?(110)) && (synpred217__java))
                    s = 8
                  else
                    if (((la139_3).equal?(111)) && (synpred217__java))
                      s = 9
                    else
                      if (((la139_3).equal?(112)) && (synpred217__java))
                        s = 10
                      else
                        if (((la139_3).equal?(66)) && (synpred217__java))
                          s = 11
                        else
                          if (((la139_3).equal?(69)) && (synpred217__java))
                            s = 12
                          else
                            if (((la139_3).equal?(65)) && (synpred217__java))
                              s = 13
                            else
                              if (((la139_3 >= HexLiteral && la139_3 <= DecimalLiteral)) && (synpred217__java))
                                s = 14
                              else
                                if (((la139_3).equal?(FloatingPointLiteral)) && (synpred217__java))
                                  s = 15
                                else
                                  if (((la139_3).equal?(CharacterLiteral)) && (synpred217__java))
                                    s = 16
                                  else
                                    if (((la139_3).equal?(StringLiteral)) && (synpred217__java))
                                      s = 17
                                    else
                                      if (((la139_3 >= 71 && la139_3 <= 72)) && (synpred217__java))
                                        s = 18
                                      else
                                        if (((la139_3).equal?(70)) && (synpred217__java))
                                          s = 19
                                        else
                                          if (((la139_3).equal?(113)) && (synpred217__java))
                                            s = 20
                                          else
                                            if (((la139_3).equal?(Identifier)) && (synpred217__java))
                                              s = 21
                                            else
                                              if (((la139_3 >= 56 && la139_3 <= 63)) && (synpred217__java))
                                                s = 22
                                              else
                                                if (((la139_3).equal?(47)) && (synpred217__java))
                                                  s = 23
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          input.seek(index139_3)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 139, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa139, :initialize
    end }
    
    const_set_lazy(:DFA145_eotS) { ("\21".to_u << 0xffff << "") }
    const_attr_reader  :DFA145_eotS
    
    const_set_lazy(:DFA145_eofS) { ("\21".to_u << 0xffff << "") }
    const_attr_reader  :DFA145_eofS
    
    const_set_lazy(:DFA145_minS) { ("\1\4\2".to_u << 0xffff << "\1\0\15".to_u << 0xffff << "") }
    const_attr_reader  :DFA145_minS
    
    const_set_lazy(:DFA145_maxS) { ("\1\161\2".to_u << 0xffff << "\1\0\15".to_u << 0xffff << "") }
    const_attr_reader  :DFA145_maxS
    
    const_set_lazy(:DFA145_acceptS) { ("\1".to_u << 0xffff << "\1\1\1\2\1".to_u << 0xffff << "\1\4\13".to_u << 0xffff << "\1\3") }
    const_attr_reader  :DFA145_acceptS
    
    const_set_lazy(:DFA145_specialS) { ("\3".to_u << 0xffff << "\1\0\15".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA145_specialS
    
    const_set_lazy(:DFA145_transitionS) { Array.typed(String).new([("\1\4\1".to_u << 0xffff << "\6\4\43".to_u << 0xffff << "\1\4\10".to_u << 0xffff << "\10\4\1".to_u << 0xffff << "\1\4\1\3") + ("\2".to_u << 0xffff << "\4\4\46".to_u << 0xffff << "\1\1\1\2\1\4"), "", "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA145_transitionS
    
    const_set_lazy(:DFA145_eot) { DFA.unpack_encoded_string(DFA145_eotS) }
    const_attr_reader  :DFA145_eot
    
    const_set_lazy(:DFA145_eof) { DFA.unpack_encoded_string(DFA145_eofS) }
    const_attr_reader  :DFA145_eof
    
    const_set_lazy(:DFA145_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA145_minS) }
    const_attr_reader  :DFA145_min
    
    const_set_lazy(:DFA145_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA145_maxS) }
    const_attr_reader  :DFA145_max
    
    const_set_lazy(:DFA145_accept) { DFA.unpack_encoded_string(DFA145_acceptS) }
    const_attr_reader  :DFA145_accept
    
    const_set_lazy(:DFA145_special) { DFA.unpack_encoded_string(DFA145_specialS) }
    const_attr_reader  :DFA145_special
    
    when_class_loaded do
      num_states = DFA145_transitionS.attr_length
      const_set :DFA145_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA145_transition[i] = DFA.unpack_encoded_string(DFA145_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA145) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 145
        self.attr_eot = DFA145_eot
        self.attr_eof = DFA145_eof
        self.attr_min = DFA145_min
        self.attr_max = DFA145_max
        self.attr_accept = DFA145_accept
        self.attr_special = DFA145_special
        self.attr_transition = DFA145_transition
      end
      
      typesig { [] }
      def get_description
        return "823:1: unaryExpressionNotPlusMinus : ( '~' unaryExpression | '!' unaryExpression | castExpression | primary ( selector )* ( '++' | '--' )? );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la145_3 = input._la(1)
          index145_3 = input.index
          input.rewind
          s = -1
          if ((synpred229__java))
            s = 16
          else
            if ((true))
              s = 4
            end
          end
          input.seek(index145_3)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 145, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa145, :initialize
    end }
    
    const_set_lazy(:DFA146_eotS) { ("\7".to_u << 0xffff << "") }
    const_attr_reader  :DFA146_eotS
    
    const_set_lazy(:DFA146_eofS) { ("\7".to_u << 0xffff << "") }
    const_attr_reader  :DFA146_eofS
    
    const_set_lazy(:DFA146_minS) { ("\1\4\1\0\1\35\2".to_u << 0xffff << "\1\61\1\35") }
    const_attr_reader  :DFA146_minS
    
    const_set_lazy(:DFA146_maxS) { ("\1\161\1\0\1\103\2".to_u << 0xffff << "\1\61\1\103") }
    const_attr_reader  :DFA146_maxS
    
    const_set_lazy(:DFA146_acceptS) { ("\3".to_u << 0xffff << "\1\2\1\1\2".to_u << 0xffff << "") }
    const_attr_reader  :DFA146_acceptS
    
    const_set_lazy(:DFA146_specialS) { ("\1".to_u << 0xffff << "\1\0\5".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA146_specialS
    
    const_set_lazy(:DFA146_transitionS) { Array.typed(String).new([("\1\1\1".to_u << 0xffff << "\6\3\43".to_u << 0xffff << "\1\3\10".to_u << 0xffff << "\10\2\1".to_u << 0xffff << "\2\3\2".to_u << 0xffff << "") + ("\4\3\40".to_u << 0xffff << "\2\3\2".to_u << 0xffff << "\5\3"), ("\1".to_u << 0xffff << ""), ("\1\3\22".to_u << 0xffff << "\1\5\22".to_u << 0xffff << "\1\4"), "", "", "\1\6", ("\1\3\22".to_u << 0xffff << "\1\5\22".to_u << 0xffff << "\1\4")]) }
    const_attr_reader  :DFA146_transitionS
    
    const_set_lazy(:DFA146_eot) { DFA.unpack_encoded_string(DFA146_eotS) }
    const_attr_reader  :DFA146_eot
    
    const_set_lazy(:DFA146_eof) { DFA.unpack_encoded_string(DFA146_eofS) }
    const_attr_reader  :DFA146_eof
    
    const_set_lazy(:DFA146_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA146_minS) }
    const_attr_reader  :DFA146_min
    
    const_set_lazy(:DFA146_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA146_maxS) }
    const_attr_reader  :DFA146_max
    
    const_set_lazy(:DFA146_accept) { DFA.unpack_encoded_string(DFA146_acceptS) }
    const_attr_reader  :DFA146_accept
    
    const_set_lazy(:DFA146_special) { DFA.unpack_encoded_string(DFA146_specialS) }
    const_attr_reader  :DFA146_special
    
    when_class_loaded do
      num_states = DFA146_transitionS.attr_length
      const_set :DFA146_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA146_transition[i] = DFA.unpack_encoded_string(DFA146_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA146) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 146
        self.attr_eot = DFA146_eot
        self.attr_eof = DFA146_eof
        self.attr_min = DFA146_min
        self.attr_max = DFA146_max
        self.attr_accept = DFA146_accept
        self.attr_special = DFA146_special
        self.attr_transition = DFA146_transition
      end
      
      typesig { [] }
      def get_description
        return "832:12: ( type | expression )"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la146_1 = input._la(1)
          index146_1 = input.index
          input.rewind
          s = -1
          if ((synpred234__java))
            s = 4
          else
            if ((true))
              s = 3
            end
          end
          input.seek(index146_1)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 146, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa146, :initialize
    end }
    
    const_set_lazy(:DFA149_eotS) { ("\41".to_u << 0xffff << "") }
    const_attr_reader  :DFA149_eotS
    
    const_set_lazy(:DFA149_eofS) { ("\1\4\40".to_u << 0xffff << "") }
    const_attr_reader  :DFA149_eofS
    
    const_set_lazy(:DFA149_minS) { ("\1\32\1\0\1".to_u << 0xffff << "\1\0\35".to_u << 0xffff << "") }
    const_attr_reader  :DFA149_minS
    
    const_set_lazy(:DFA149_maxS) { ("\1\156\1\0\1".to_u << 0xffff << "\1\0\35".to_u << 0xffff << "") }
    const_attr_reader  :DFA149_maxS
    
    const_set_lazy(:DFA149_acceptS) { ("\2".to_u << 0xffff << "\1\1\1".to_u << 0xffff << "\1\2\34".to_u << 0xffff << "") }
    const_attr_reader  :DFA149_acceptS
    
    const_set_lazy(:DFA149_specialS) { ("\1".to_u << 0xffff << "\1\0\1".to_u << 0xffff << "\1\1\35".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA149_specialS
    
    const_set_lazy(:DFA149_transitionS) { Array.typed(String).new([("\1\4\2".to_u << 0xffff << "\1\3\1\4\11".to_u << 0xffff << "\4\4\1".to_u << 0xffff << "\1\4\2".to_u << 0xffff << "\1\1\1") + ("\4\1".to_u << 0xffff << "\1\4\14".to_u << 0xffff << "\1\4\1".to_u << 0xffff << "\1\2\1\4\7".to_u << 0xffff << "\1\4\16".to_u << 0xffff << "") + "\25\4", ("\1".to_u << 0xffff << ""), "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA149_transitionS
    
    const_set_lazy(:DFA149_eot) { DFA.unpack_encoded_string(DFA149_eotS) }
    const_attr_reader  :DFA149_eot
    
    const_set_lazy(:DFA149_eof) { DFA.unpack_encoded_string(DFA149_eofS) }
    const_attr_reader  :DFA149_eof
    
    const_set_lazy(:DFA149_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA149_minS) }
    const_attr_reader  :DFA149_min
    
    const_set_lazy(:DFA149_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA149_maxS) }
    const_attr_reader  :DFA149_max
    
    const_set_lazy(:DFA149_accept) { DFA.unpack_encoded_string(DFA149_acceptS) }
    const_attr_reader  :DFA149_accept
    
    const_set_lazy(:DFA149_special) { DFA.unpack_encoded_string(DFA149_specialS) }
    const_attr_reader  :DFA149_special
    
    when_class_loaded do
      num_states = DFA149_transitionS.attr_length
      const_set :DFA149_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA149_transition[i] = DFA.unpack_encoded_string(DFA149_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA149) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 149
        self.attr_eot = DFA149_eot
        self.attr_eof = DFA149_eof
        self.attr_min = DFA149_min
        self.attr_max = DFA149_max
        self.attr_accept = DFA149_accept
        self.attr_special = DFA149_special
        self.attr_transition = DFA149_transition
      end
      
      typesig { [] }
      def get_description
        return "837:34: ( identifierSuffix )?"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la149_1 = input._la(1)
          index149_1 = input.index
          input.rewind
          s = -1
          if ((synpred237__java))
            s = 2
          else
            if ((true))
              s = 4
            end
          end
          input.seek(index149_1)
          if (s >= 0)
            return s
          end
        when 1
          la149_3 = input._la(1)
          index149_3 = input.index
          input.rewind
          s = -1
          if ((synpred237__java))
            s = 2
          else
            if ((true))
              s = 4
            end
          end
          input.seek(index149_3)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 149, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa149, :initialize
    end }
    
    const_set_lazy(:DFA151_eotS) { ("\41".to_u << 0xffff << "") }
    const_attr_reader  :DFA151_eotS
    
    const_set_lazy(:DFA151_eofS) { ("\1\4\40".to_u << 0xffff << "") }
    const_attr_reader  :DFA151_eofS
    
    const_set_lazy(:DFA151_minS) { ("\1\32\1\0\1".to_u << 0xffff << "\1\0\35".to_u << 0xffff << "") }
    const_attr_reader  :DFA151_minS
    
    const_set_lazy(:DFA151_maxS) { ("\1\156\1\0\1".to_u << 0xffff << "\1\0\35".to_u << 0xffff << "") }
    const_attr_reader  :DFA151_maxS
    
    const_set_lazy(:DFA151_acceptS) { ("\2".to_u << 0xffff << "\1\1\1".to_u << 0xffff << "\1\2\34".to_u << 0xffff << "") }
    const_attr_reader  :DFA151_acceptS
    
    const_set_lazy(:DFA151_specialS) { ("\1".to_u << 0xffff << "\1\0\1".to_u << 0xffff << "\1\1\35".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA151_specialS
    
    const_set_lazy(:DFA151_transitionS) { Array.typed(String).new([("\1\4\2".to_u << 0xffff << "\1\3\1\4\11".to_u << 0xffff << "\4\4\1".to_u << 0xffff << "\1\4\2".to_u << 0xffff << "\1\1\1") + ("\4\1".to_u << 0xffff << "\1\4\14".to_u << 0xffff << "\1\4\1".to_u << 0xffff << "\1\2\1\4\7".to_u << 0xffff << "\1\4\16".to_u << 0xffff << "") + "\25\4", ("\1".to_u << 0xffff << ""), "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA151_transitionS
    
    const_set_lazy(:DFA151_eot) { DFA.unpack_encoded_string(DFA151_eotS) }
    const_attr_reader  :DFA151_eot
    
    const_set_lazy(:DFA151_eof) { DFA.unpack_encoded_string(DFA151_eofS) }
    const_attr_reader  :DFA151_eof
    
    const_set_lazy(:DFA151_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA151_minS) }
    const_attr_reader  :DFA151_min
    
    const_set_lazy(:DFA151_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA151_maxS) }
    const_attr_reader  :DFA151_max
    
    const_set_lazy(:DFA151_accept) { DFA.unpack_encoded_string(DFA151_acceptS) }
    const_attr_reader  :DFA151_accept
    
    const_set_lazy(:DFA151_special) { DFA.unpack_encoded_string(DFA151_specialS) }
    const_attr_reader  :DFA151_special
    
    when_class_loaded do
      num_states = DFA151_transitionS.attr_length
      const_set :DFA151_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA151_transition[i] = DFA.unpack_encoded_string(DFA151_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA151) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 151
        self.attr_eot = DFA151_eot
        self.attr_eof = DFA151_eof
        self.attr_min = DFA151_min
        self.attr_max = DFA151_max
        self.attr_accept = DFA151_accept
        self.attr_special = DFA151_special
        self.attr_transition = DFA151_transition
      end
      
      typesig { [] }
      def get_description
        return "841:38: ( identifierSuffix )?"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la151_1 = input._la(1)
          index151_1 = input.index
          input.rewind
          s = -1
          if ((synpred243__java))
            s = 2
          else
            if ((true))
              s = 4
            end
          end
          input.seek(index151_1)
          if (s >= 0)
            return s
          end
        when 1
          la151_3 = input._la(1)
          index151_3 = input.index
          input.rewind
          s = -1
          if ((synpred243__java))
            s = 2
          else
            if ((true))
              s = 4
            end
          end
          input.seek(index151_3)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 151, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa151, :initialize
    end }
    
    const_set_lazy(:DFA156_eotS) { ("\13".to_u << 0xffff << "") }
    const_attr_reader  :DFA156_eotS
    
    const_set_lazy(:DFA156_eofS) { ("\13".to_u << 0xffff << "") }
    const_attr_reader  :DFA156_eofS
    
    const_set_lazy(:DFA156_minS) { ("\1\35\1\4\1".to_u << 0xffff << "\1\45\7".to_u << 0xffff << "") }
    const_attr_reader  :DFA156_minS
    
    const_set_lazy(:DFA156_maxS) { ("\1\102\1\161\1".to_u << 0xffff << "\1\161\7".to_u << 0xffff << "") }
    const_attr_reader  :DFA156_maxS
    
    const_set_lazy(:DFA156_acceptS) { ("\2".to_u << 0xffff << "\1\3\1".to_u << 0xffff << "\1\1\1\2\1\4\1\6\1\7\1\10\1\5") }
    const_attr_reader  :DFA156_acceptS
    
    const_set_lazy(:DFA156_specialS) { ("\13".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA156_specialS
    
    const_set_lazy(:DFA156_transitionS) { Array.typed(String).new([("\1\3\22".to_u << 0xffff << "\1\1\21".to_u << 0xffff << "\1\2"), ("\1\5\1".to_u << 0xffff << "\6\5\43".to_u << 0xffff << "\1\5\1".to_u << 0xffff << "\1\4\6".to_u << 0xffff << "\10\5\1".to_u << 0xffff << "") + ("\2\5\2".to_u << 0xffff << "\4\5\40".to_u << 0xffff << "\2\5\2".to_u << 0xffff << "\5\5"), "", ("\1\6\2".to_u << 0xffff << "\1\12\30".to_u << 0xffff << "\1\10\3".to_u << 0xffff << "\1\7\53".to_u << 0xffff << "\1\11"), "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA156_transitionS
    
    const_set_lazy(:DFA156_eot) { DFA.unpack_encoded_string(DFA156_eotS) }
    const_attr_reader  :DFA156_eot
    
    const_set_lazy(:DFA156_eof) { DFA.unpack_encoded_string(DFA156_eofS) }
    const_attr_reader  :DFA156_eof
    
    const_set_lazy(:DFA156_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA156_minS) }
    const_attr_reader  :DFA156_min
    
    const_set_lazy(:DFA156_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA156_maxS) }
    const_attr_reader  :DFA156_max
    
    const_set_lazy(:DFA156_accept) { DFA.unpack_encoded_string(DFA156_acceptS) }
    const_attr_reader  :DFA156_accept
    
    const_set_lazy(:DFA156_special) { DFA.unpack_encoded_string(DFA156_specialS) }
    const_attr_reader  :DFA156_special
    
    when_class_loaded do
      num_states = DFA156_transitionS.attr_length
      const_set :DFA156_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA156_transition[i] = DFA.unpack_encoded_string(DFA156_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA156) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 156
        self.attr_eot = DFA156_eot
        self.attr_eof = DFA156_eof
        self.attr_min = DFA156_min
        self.attr_max = DFA156_max
        self.attr_accept = DFA156_accept
        self.attr_special = DFA156_special
        self.attr_transition = DFA156_transition
      end
      
      typesig { [] }
      def get_description
        return "846:1: identifierSuffix : ( ( '[' ']' )+ '.' 'class' | ( '[' expression ']' )+ | arguments | '.' 'class' | '.' explicitGenericInvocation | '.' 'this' | '.' 'super' arguments | '.' 'new' innerCreator );"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      private
      alias_method :initialize__dfa156, :initialize
    end }
    
    const_set_lazy(:DFA155_eotS) { ("\41".to_u << 0xffff << "") }
    const_attr_reader  :DFA155_eotS
    
    const_set_lazy(:DFA155_eofS) { ("\1\1\40".to_u << 0xffff << "") }
    const_attr_reader  :DFA155_eofS
    
    const_set_lazy(:DFA155_minS) { ("\1\32\1".to_u << 0xffff << "\1\0\36".to_u << 0xffff << "") }
    const_attr_reader  :DFA155_minS
    
    const_set_lazy(:DFA155_maxS) { ("\1\156\1".to_u << 0xffff << "\1\0\36".to_u << 0xffff << "") }
    const_attr_reader  :DFA155_maxS
    
    const_set_lazy(:DFA155_acceptS) { ("\1".to_u << 0xffff << "\1\2\36".to_u << 0xffff << "\1\1") }
    const_attr_reader  :DFA155_acceptS
    
    const_set_lazy(:DFA155_specialS) { ("\2".to_u << 0xffff << "\1\0\36".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA155_specialS
    
    const_set_lazy(:DFA155_transitionS) { Array.typed(String).new([("\1\1\2".to_u << 0xffff << "\2\1\11".to_u << 0xffff << "\4\1\1".to_u << 0xffff << "\1\1\2".to_u << 0xffff << "\1\2\1\1\1") + ("".to_u << 0xffff << "\1\1\14".to_u << 0xffff << "\1\1\2".to_u << 0xffff << "\1\1\7".to_u << 0xffff << "\1\1\16".to_u << 0xffff << "\25") + "\1", "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA155_transitionS
    
    const_set_lazy(:DFA155_eot) { DFA.unpack_encoded_string(DFA155_eotS) }
    const_attr_reader  :DFA155_eot
    
    const_set_lazy(:DFA155_eof) { DFA.unpack_encoded_string(DFA155_eofS) }
    const_attr_reader  :DFA155_eof
    
    const_set_lazy(:DFA155_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA155_minS) }
    const_attr_reader  :DFA155_min
    
    const_set_lazy(:DFA155_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA155_maxS) }
    const_attr_reader  :DFA155_max
    
    const_set_lazy(:DFA155_accept) { DFA.unpack_encoded_string(DFA155_acceptS) }
    const_attr_reader  :DFA155_accept
    
    const_set_lazy(:DFA155_special) { DFA.unpack_encoded_string(DFA155_specialS) }
    const_attr_reader  :DFA155_special
    
    when_class_loaded do
      num_states = DFA155_transitionS.attr_length
      const_set :DFA155_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA155_transition[i] = DFA.unpack_encoded_string(DFA155_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA155) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 155
        self.attr_eot = DFA155_eot
        self.attr_eof = DFA155_eof
        self.attr_min = DFA155_min
        self.attr_max = DFA155_max
        self.attr_accept = DFA155_accept
        self.attr_special = DFA155_special
        self.attr_transition = DFA155_transition
      end
      
      typesig { [] }
      def get_description
        return "()+ loopback of 848:9: ( '[' expression ']' )+"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la155_2 = input._la(1)
          index155_2 = input.index
          input.rewind
          s = -1
          if ((synpred249__java))
            s = 32
          else
            if ((true))
              s = 1
            end
          end
          input.seek(index155_2)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 155, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa155, :initialize
    end }
    
    const_set_lazy(:DFA162_eotS) { ("\41".to_u << 0xffff << "") }
    const_attr_reader  :DFA162_eotS
    
    const_set_lazy(:DFA162_eofS) { ("\1\2\40".to_u << 0xffff << "") }
    const_attr_reader  :DFA162_eofS
    
    const_set_lazy(:DFA162_minS) { ("\1\32\1\0\37".to_u << 0xffff << "") }
    const_attr_reader  :DFA162_minS
    
    const_set_lazy(:DFA162_maxS) { ("\1\156\1\0\37".to_u << 0xffff << "") }
    const_attr_reader  :DFA162_maxS
    
    const_set_lazy(:DFA162_acceptS) { ("\2".to_u << 0xffff << "\1\2\35".to_u << 0xffff << "\1\1") }
    const_attr_reader  :DFA162_acceptS
    
    const_set_lazy(:DFA162_specialS) { ("\1".to_u << 0xffff << "\1\0\37".to_u << 0xffff << "}>") }
    const_attr_reader  :DFA162_specialS
    
    const_set_lazy(:DFA162_transitionS) { Array.typed(String).new([("\1\2\2".to_u << 0xffff << "\2\2\11".to_u << 0xffff << "\4\2\1".to_u << 0xffff << "\1\2\2".to_u << 0xffff << "\1\1\1\2\1") + ("".to_u << 0xffff << "\1\2\14".to_u << 0xffff << "\1\2\2".to_u << 0xffff << "\1\2\7".to_u << 0xffff << "\1\2\16".to_u << 0xffff << "\25") + "\2", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
    const_attr_reader  :DFA162_transitionS
    
    const_set_lazy(:DFA162_eot) { DFA.unpack_encoded_string(DFA162_eotS) }
    const_attr_reader  :DFA162_eot
    
    const_set_lazy(:DFA162_eof) { DFA.unpack_encoded_string(DFA162_eofS) }
    const_attr_reader  :DFA162_eof
    
    const_set_lazy(:DFA162_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA162_minS) }
    const_attr_reader  :DFA162_min
    
    const_set_lazy(:DFA162_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA162_maxS) }
    const_attr_reader  :DFA162_max
    
    const_set_lazy(:DFA162_accept) { DFA.unpack_encoded_string(DFA162_acceptS) }
    const_attr_reader  :DFA162_accept
    
    const_set_lazy(:DFA162_special) { DFA.unpack_encoded_string(DFA162_specialS) }
    const_attr_reader  :DFA162_special
    
    when_class_loaded do
      num_states = DFA162_transitionS.attr_length
      const_set :DFA162_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
      i = 0
      while i < num_states
        DFA162_transition[i] = DFA.unpack_encoded_string(DFA162_transitionS[i])
        i += 1
      end
    end
    
    const_set_lazy(:DFA162) { Class.new(DFA) do
      extend LocalClass
      include_class_members JavaParser
      
      typesig { [BaseRecognizer] }
      def initialize(recognizer)
        super()
        self.attr_recognizer = recognizer
        self.attr_decision_number = 162
        self.attr_eot = DFA162_eot
        self.attr_eof = DFA162_eof
        self.attr_min = DFA162_min
        self.attr_max = DFA162_max
        self.attr_accept = DFA162_accept
        self.attr_special = DFA162_special
        self.attr_transition = DFA162_transition
      end
      
      typesig { [] }
      def get_description
        return "()* loopback of 874:28: ( '[' expression ']' )*"
      end
      
      typesig { [NoViableAltException] }
      def error(nvae)
        self.attr_dbg.recognition_exception(nvae)
      end
      
      typesig { [::Java::Int, IntStream] }
      def special_state_transition(s, _input)
        input = _input
        _s = s
        case (s)
        when 0
          la162_1 = input._la(1)
          index162_1 = input.index
          input.rewind
          s = -1
          if ((synpred262__java))
            s = 32
          else
            if ((true))
              s = 2
            end
          end
          input.seek(index162_1)
          if (s >= 0)
            return s
          end
        end
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return -1
        end
        nvae = NoViableAltException.new(get_description, 162, _s, input)
        error(nvae)
        raise nvae
      end
      
      private
      alias_method :initialize__dfa162, :initialize
    end }
    
    const_set_lazy(:FOLLOW_annotations_in_compilationUnit44) { BitSet.new(Array.typed(::Java::Long).new([0x403f92000020, 0x200])) }
    const_attr_reader  :FOLLOW_annotations_in_compilationUnit44
    
    const_set_lazy(:FOLLOW_packageDeclaration_in_compilationUnit58) { BitSet.new(Array.typed(::Java::Long).new([0x403f9e000022, 0x200])) }
    const_attr_reader  :FOLLOW_packageDeclaration_in_compilationUnit58
    
    const_set_lazy(:FOLLOW_importDeclaration_in_compilationUnit60) { BitSet.new(Array.typed(::Java::Long).new([0x403f9e000022, 0x200])) }
    const_attr_reader  :FOLLOW_importDeclaration_in_compilationUnit60
    
    const_set_lazy(:FOLLOW_typeDeclaration_in_compilationUnit63) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_typeDeclaration_in_compilationUnit63
    
    const_set_lazy(:FOLLOW_classOrInterfaceDeclaration_in_compilationUnit78) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_classOrInterfaceDeclaration_in_compilationUnit78
    
    const_set_lazy(:FOLLOW_typeDeclaration_in_compilationUnit80) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_typeDeclaration_in_compilationUnit80
    
    const_set_lazy(:FOLLOW_packageDeclaration_in_compilationUnit101) { BitSet.new(Array.typed(::Java::Long).new([0x403f9e000022, 0x200])) }
    const_attr_reader  :FOLLOW_packageDeclaration_in_compilationUnit101
    
    const_set_lazy(:FOLLOW_importDeclaration_in_compilationUnit104) { BitSet.new(Array.typed(::Java::Long).new([0x403f9e000022, 0x200])) }
    const_attr_reader  :FOLLOW_importDeclaration_in_compilationUnit104
    
    const_set_lazy(:FOLLOW_typeDeclaration_in_compilationUnit107) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_typeDeclaration_in_compilationUnit107
    
    const_set_lazy(:FOLLOW_25_in_packageDeclaration127) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_25_in_packageDeclaration127
    
    const_set_lazy(:FOLLOW_qualifiedName_in_packageDeclaration129) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_qualifiedName_in_packageDeclaration129
    
    const_set_lazy(:FOLLOW_26_in_packageDeclaration131) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_packageDeclaration131
    
    const_set_lazy(:FOLLOW_27_in_importDeclaration154) { BitSet.new(Array.typed(::Java::Long).new([0x10000010])) }
    const_attr_reader  :FOLLOW_27_in_importDeclaration154
    
    const_set_lazy(:FOLLOW_28_in_importDeclaration156) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_28_in_importDeclaration156
    
    const_set_lazy(:FOLLOW_qualifiedName_in_importDeclaration159) { BitSet.new(Array.typed(::Java::Long).new([0x24000000])) }
    const_attr_reader  :FOLLOW_qualifiedName_in_importDeclaration159
    
    const_set_lazy(:FOLLOW_29_in_importDeclaration162) { BitSet.new(Array.typed(::Java::Long).new([0x40000000])) }
    const_attr_reader  :FOLLOW_29_in_importDeclaration162
    
    const_set_lazy(:FOLLOW_30_in_importDeclaration164) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_30_in_importDeclaration164
    
    const_set_lazy(:FOLLOW_26_in_importDeclaration168) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_importDeclaration168
    
    const_set_lazy(:FOLLOW_classOrInterfaceDeclaration_in_typeDeclaration191) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classOrInterfaceDeclaration_in_typeDeclaration191
    
    const_set_lazy(:FOLLOW_26_in_typeDeclaration201) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_typeDeclaration201
    
    const_set_lazy(:FOLLOW_classOrInterfaceModifiers_in_classOrInterfaceDeclaration224) { BitSet.new(Array.typed(::Java::Long).new([0x403f92000020, 0x200])) }
    const_attr_reader  :FOLLOW_classOrInterfaceModifiers_in_classOrInterfaceDeclaration224
    
    const_set_lazy(:FOLLOW_classDeclaration_in_classOrInterfaceDeclaration227) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classDeclaration_in_classOrInterfaceDeclaration227
    
    const_set_lazy(:FOLLOW_interfaceDeclaration_in_classOrInterfaceDeclaration231) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceDeclaration_in_classOrInterfaceDeclaration231
    
    const_set_lazy(:FOLLOW_classOrInterfaceModifier_in_classOrInterfaceModifiers255) { BitSet.new(Array.typed(::Java::Long).new([0x1f90000002, 0x200])) }
    const_attr_reader  :FOLLOW_classOrInterfaceModifier_in_classOrInterfaceModifiers255
    
    const_set_lazy(:FOLLOW_annotation_in_classOrInterfaceModifier275) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotation_in_classOrInterfaceModifier275
    
    const_set_lazy(:FOLLOW_31_in_classOrInterfaceModifier288) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_31_in_classOrInterfaceModifier288
    
    const_set_lazy(:FOLLOW_32_in_classOrInterfaceModifier303) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_32_in_classOrInterfaceModifier303
    
    const_set_lazy(:FOLLOW_33_in_classOrInterfaceModifier315) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_33_in_classOrInterfaceModifier315
    
    const_set_lazy(:FOLLOW_34_in_classOrInterfaceModifier329) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_34_in_classOrInterfaceModifier329
    
    const_set_lazy(:FOLLOW_28_in_classOrInterfaceModifier342) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_28_in_classOrInterfaceModifier342
    
    const_set_lazy(:FOLLOW_35_in_classOrInterfaceModifier357) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_35_in_classOrInterfaceModifier357
    
    const_set_lazy(:FOLLOW_36_in_classOrInterfaceModifier373) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_36_in_classOrInterfaceModifier373
    
    const_set_lazy(:FOLLOW_modifier_in_modifiers395) { BitSet.new(Array.typed(::Java::Long).new([0xf0001f90000002, 0x200])) }
    const_attr_reader  :FOLLOW_modifier_in_modifiers395
    
    const_set_lazy(:FOLLOW_normalClassDeclaration_in_classDeclaration415) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_normalClassDeclaration_in_classDeclaration415
    
    const_set_lazy(:FOLLOW_enumDeclaration_in_classDeclaration425) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_enumDeclaration_in_classDeclaration425
    
    const_set_lazy(:FOLLOW_37_in_normalClassDeclaration448) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_37_in_normalClassDeclaration448
    
    const_set_lazy(:FOLLOW_Identifier_in_normalClassDeclaration450) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_normalClassDeclaration450
    
    const_set_lazy(:FOLLOW_typeParameters_in_normalClassDeclaration452) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000000])) }
    const_attr_reader  :FOLLOW_typeParameters_in_normalClassDeclaration452
    
    const_set_lazy(:FOLLOW_38_in_normalClassDeclaration464) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_38_in_normalClassDeclaration464
    
    const_set_lazy(:FOLLOW_type_in_normalClassDeclaration466) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000000])) }
    const_attr_reader  :FOLLOW_type_in_normalClassDeclaration466
    
    const_set_lazy(:FOLLOW_39_in_normalClassDeclaration479) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_39_in_normalClassDeclaration479
    
    const_set_lazy(:FOLLOW_typeList_in_normalClassDeclaration481) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000000])) }
    const_attr_reader  :FOLLOW_typeList_in_normalClassDeclaration481
    
    const_set_lazy(:FOLLOW_classBody_in_normalClassDeclaration493) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classBody_in_normalClassDeclaration493
    
    const_set_lazy(:FOLLOW_40_in_typeParameters516) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_40_in_typeParameters516
    
    const_set_lazy(:FOLLOW_typeParameter_in_typeParameters518) { BitSet.new(Array.typed(::Java::Long).new([0x60000000000])) }
    const_attr_reader  :FOLLOW_typeParameter_in_typeParameters518
    
    const_set_lazy(:FOLLOW_41_in_typeParameters521) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_41_in_typeParameters521
    
    const_set_lazy(:FOLLOW_typeParameter_in_typeParameters523) { BitSet.new(Array.typed(::Java::Long).new([0x60000000000])) }
    const_attr_reader  :FOLLOW_typeParameter_in_typeParameters523
    
    const_set_lazy(:FOLLOW_42_in_typeParameters527) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_typeParameters527
    
    const_set_lazy(:FOLLOW_Identifier_in_typeParameter546) { BitSet.new(Array.typed(::Java::Long).new([0x4000000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_typeParameter546
    
    const_set_lazy(:FOLLOW_38_in_typeParameter549) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_38_in_typeParameter549
    
    const_set_lazy(:FOLLOW_typeBound_in_typeParameter551) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_typeBound_in_typeParameter551
    
    const_set_lazy(:FOLLOW_type_in_typeBound580) { BitSet.new(Array.typed(::Java::Long).new([0x80000000002])) }
    const_attr_reader  :FOLLOW_type_in_typeBound580
    
    const_set_lazy(:FOLLOW_43_in_typeBound583) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_43_in_typeBound583
    
    const_set_lazy(:FOLLOW_type_in_typeBound585) { BitSet.new(Array.typed(::Java::Long).new([0x80000000002])) }
    const_attr_reader  :FOLLOW_type_in_typeBound585
    
    const_set_lazy(:FOLLOW_ENUM_in_enumDeclaration606) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_ENUM_in_enumDeclaration606
    
    const_set_lazy(:FOLLOW_Identifier_in_enumDeclaration608) { BitSet.new(Array.typed(::Java::Long).new([0x108000000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_enumDeclaration608
    
    const_set_lazy(:FOLLOW_39_in_enumDeclaration611) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_39_in_enumDeclaration611
    
    const_set_lazy(:FOLLOW_typeList_in_enumDeclaration613) { BitSet.new(Array.typed(::Java::Long).new([0x108000000000])) }
    const_attr_reader  :FOLLOW_typeList_in_enumDeclaration613
    
    const_set_lazy(:FOLLOW_enumBody_in_enumDeclaration617) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_enumBody_in_enumDeclaration617
    
    const_set_lazy(:FOLLOW_44_in_enumBody636) { BitSet.new(Array.typed(::Java::Long).new([0x220004000010, 0x200])) }
    const_attr_reader  :FOLLOW_44_in_enumBody636
    
    const_set_lazy(:FOLLOW_enumConstants_in_enumBody638) { BitSet.new(Array.typed(::Java::Long).new([0x220004000000])) }
    const_attr_reader  :FOLLOW_enumConstants_in_enumBody638
    
    const_set_lazy(:FOLLOW_41_in_enumBody641) { BitSet.new(Array.typed(::Java::Long).new([0x200004000000])) }
    const_attr_reader  :FOLLOW_41_in_enumBody641
    
    const_set_lazy(:FOLLOW_enumBodyDeclarations_in_enumBody644) { BitSet.new(Array.typed(::Java::Long).new([0x200000000000])) }
    const_attr_reader  :FOLLOW_enumBodyDeclarations_in_enumBody644
    
    const_set_lazy(:FOLLOW_45_in_enumBody647) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_enumBody647
    
    const_set_lazy(:FOLLOW_enumConstant_in_enumConstants666) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_enumConstant_in_enumConstants666
    
    const_set_lazy(:FOLLOW_41_in_enumConstants669) { BitSet.new(Array.typed(::Java::Long).new([0x10, 0x200])) }
    const_attr_reader  :FOLLOW_41_in_enumConstants669
    
    const_set_lazy(:FOLLOW_enumConstant_in_enumConstants671) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_enumConstant_in_enumConstants671
    
    const_set_lazy(:FOLLOW_annotations_in_enumConstant696) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_annotations_in_enumConstant696
    
    const_set_lazy(:FOLLOW_Identifier_in_enumConstant699) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000002, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_enumConstant699
    
    const_set_lazy(:FOLLOW_arguments_in_enumConstant701) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000002])) }
    const_attr_reader  :FOLLOW_arguments_in_enumConstant701
    
    const_set_lazy(:FOLLOW_classBody_in_enumConstant704) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classBody_in_enumConstant704
    
    const_set_lazy(:FOLLOW_26_in_enumBodyDeclarations728) { BitSet.new(Array.typed(::Java::Long).new([0xf0101f94000002, 0x200])) }
    const_attr_reader  :FOLLOW_26_in_enumBodyDeclarations728
    
    const_set_lazy(:FOLLOW_classBodyDeclaration_in_enumBodyDeclarations731) { BitSet.new(Array.typed(::Java::Long).new([0xf0101f94000002, 0x200])) }
    const_attr_reader  :FOLLOW_classBodyDeclaration_in_enumBodyDeclarations731
    
    const_set_lazy(:FOLLOW_normalInterfaceDeclaration_in_interfaceDeclaration756) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_normalInterfaceDeclaration_in_interfaceDeclaration756
    
    const_set_lazy(:FOLLOW_annotationTypeDeclaration_in_interfaceDeclaration766) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotationTypeDeclaration_in_interfaceDeclaration766
    
    const_set_lazy(:FOLLOW_46_in_normalInterfaceDeclaration789) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_46_in_normalInterfaceDeclaration789
    
    const_set_lazy(:FOLLOW_Identifier_in_normalInterfaceDeclaration791) { BitSet.new(Array.typed(::Java::Long).new([0x114000000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_normalInterfaceDeclaration791
    
    const_set_lazy(:FOLLOW_typeParameters_in_normalInterfaceDeclaration793) { BitSet.new(Array.typed(::Java::Long).new([0x114000000000])) }
    const_attr_reader  :FOLLOW_typeParameters_in_normalInterfaceDeclaration793
    
    const_set_lazy(:FOLLOW_38_in_normalInterfaceDeclaration797) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_38_in_normalInterfaceDeclaration797
    
    const_set_lazy(:FOLLOW_typeList_in_normalInterfaceDeclaration799) { BitSet.new(Array.typed(::Java::Long).new([0x114000000000])) }
    const_attr_reader  :FOLLOW_typeList_in_normalInterfaceDeclaration799
    
    const_set_lazy(:FOLLOW_interfaceBody_in_normalInterfaceDeclaration803) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceBody_in_normalInterfaceDeclaration803
    
    const_set_lazy(:FOLLOW_type_in_typeList826) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_type_in_typeList826
    
    const_set_lazy(:FOLLOW_41_in_typeList829) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_41_in_typeList829
    
    const_set_lazy(:FOLLOW_type_in_typeList831) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_type_in_typeList831
    
    const_set_lazy(:FOLLOW_44_in_classBody856) { BitSet.new(Array.typed(::Java::Long).new([0xf0301f94000000, 0x200])) }
    const_attr_reader  :FOLLOW_44_in_classBody856
    
    const_set_lazy(:FOLLOW_classBodyDeclaration_in_classBody858) { BitSet.new(Array.typed(::Java::Long).new([0xf0301f94000000, 0x200])) }
    const_attr_reader  :FOLLOW_classBodyDeclaration_in_classBody858
    
    const_set_lazy(:FOLLOW_45_in_classBody861) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_classBody861
    
    const_set_lazy(:FOLLOW_44_in_interfaceBody884) { BitSet.new(Array.typed(::Java::Long).new([0xf0301f94000000, 0x200])) }
    const_attr_reader  :FOLLOW_44_in_interfaceBody884
    
    const_set_lazy(:FOLLOW_interfaceBodyDeclaration_in_interfaceBody886) { BitSet.new(Array.typed(::Java::Long).new([0xf0301f94000000, 0x200])) }
    const_attr_reader  :FOLLOW_interfaceBodyDeclaration_in_interfaceBody886
    
    const_set_lazy(:FOLLOW_45_in_interfaceBody889) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_interfaceBody889
    
    const_set_lazy(:FOLLOW_26_in_classBodyDeclaration908) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_classBodyDeclaration908
    
    const_set_lazy(:FOLLOW_28_in_classBodyDeclaration918) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_28_in_classBodyDeclaration918
    
    const_set_lazy(:FOLLOW_block_in_classBodyDeclaration921) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_classBodyDeclaration921
    
    const_set_lazy(:FOLLOW_modifiers_in_classBodyDeclaration931) { BitSet.new(Array.typed(::Java::Long).new([-0xff3ec06dffffd0, 0x200])) }
    const_attr_reader  :FOLLOW_modifiers_in_classBodyDeclaration931
    
    const_set_lazy(:FOLLOW_memberDecl_in_classBodyDeclaration933) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_memberDecl_in_classBodyDeclaration933
    
    const_set_lazy(:FOLLOW_genericMethodOrConstructorDecl_in_memberDecl956) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_genericMethodOrConstructorDecl_in_memberDecl956
    
    const_set_lazy(:FOLLOW_memberDeclaration_in_memberDecl966) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_memberDeclaration_in_memberDecl966
    
    const_set_lazy(:FOLLOW_47_in_memberDecl976) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_47_in_memberDecl976
    
    const_set_lazy(:FOLLOW_Identifier_in_memberDecl978) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_memberDecl978
    
    const_set_lazy(:FOLLOW_voidMethodDeclaratorRest_in_memberDecl980) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_voidMethodDeclaratorRest_in_memberDecl980
    
    const_set_lazy(:FOLLOW_Identifier_in_memberDecl990) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_memberDecl990
    
    const_set_lazy(:FOLLOW_constructorDeclaratorRest_in_memberDecl992) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_constructorDeclaratorRest_in_memberDecl992
    
    const_set_lazy(:FOLLOW_interfaceDeclaration_in_memberDecl1002) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceDeclaration_in_memberDecl1002
    
    const_set_lazy(:FOLLOW_classDeclaration_in_memberDecl1012) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classDeclaration_in_memberDecl1012
    
    const_set_lazy(:FOLLOW_type_in_memberDeclaration1035) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_memberDeclaration1035
    
    const_set_lazy(:FOLLOW_methodDeclaration_in_memberDeclaration1038) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_methodDeclaration_in_memberDeclaration1038
    
    const_set_lazy(:FOLLOW_fieldDeclaration_in_memberDeclaration1042) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_fieldDeclaration_in_memberDeclaration1042
    
    const_set_lazy(:FOLLOW_typeParameters_in_genericMethodOrConstructorDecl1062) { BitSet.new(Array.typed(::Java::Long).new([-0xff7ffffffffff0])) }
    const_attr_reader  :FOLLOW_typeParameters_in_genericMethodOrConstructorDecl1062
    
    const_set_lazy(:FOLLOW_genericMethodOrConstructorRest_in_genericMethodOrConstructorDecl1064) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_genericMethodOrConstructorRest_in_genericMethodOrConstructorDecl1064
    
    const_set_lazy(:FOLLOW_type_in_genericMethodOrConstructorRest1088) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_genericMethodOrConstructorRest1088
    
    const_set_lazy(:FOLLOW_47_in_genericMethodOrConstructorRest1092) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_47_in_genericMethodOrConstructorRest1092
    
    const_set_lazy(:FOLLOW_Identifier_in_genericMethodOrConstructorRest1095) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_genericMethodOrConstructorRest1095
    
    const_set_lazy(:FOLLOW_methodDeclaratorRest_in_genericMethodOrConstructorRest1097) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_methodDeclaratorRest_in_genericMethodOrConstructorRest1097
    
    const_set_lazy(:FOLLOW_Identifier_in_genericMethodOrConstructorRest1107) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_genericMethodOrConstructorRest1107
    
    const_set_lazy(:FOLLOW_constructorDeclaratorRest_in_genericMethodOrConstructorRest1109) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_constructorDeclaratorRest_in_genericMethodOrConstructorRest1109
    
    const_set_lazy(:FOLLOW_Identifier_in_methodDeclaration1128) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_methodDeclaration1128
    
    const_set_lazy(:FOLLOW_methodDeclaratorRest_in_methodDeclaration1130) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_methodDeclaratorRest_in_methodDeclaration1130
    
    const_set_lazy(:FOLLOW_variableDeclarators_in_fieldDeclaration1149) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_variableDeclarators_in_fieldDeclaration1149
    
    const_set_lazy(:FOLLOW_26_in_fieldDeclaration1151) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_fieldDeclaration1151
    
    const_set_lazy(:FOLLOW_modifiers_in_interfaceBodyDeclaration1178) { BitSet.new(Array.typed(::Java::Long).new([-0xff3ec06dffffd0, 0x200])) }
    const_attr_reader  :FOLLOW_modifiers_in_interfaceBodyDeclaration1178
    
    const_set_lazy(:FOLLOW_interfaceMemberDecl_in_interfaceBodyDeclaration1180) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceMemberDecl_in_interfaceBodyDeclaration1180
    
    const_set_lazy(:FOLLOW_26_in_interfaceBodyDeclaration1190) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_interfaceBodyDeclaration1190
    
    const_set_lazy(:FOLLOW_interfaceMethodOrFieldDecl_in_interfaceMemberDecl1209) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceMethodOrFieldDecl_in_interfaceMemberDecl1209
    
    const_set_lazy(:FOLLOW_interfaceGenericMethodDecl_in_interfaceMemberDecl1219) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceGenericMethodDecl_in_interfaceMemberDecl1219
    
    const_set_lazy(:FOLLOW_47_in_interfaceMemberDecl1229) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_47_in_interfaceMemberDecl1229
    
    const_set_lazy(:FOLLOW_Identifier_in_interfaceMemberDecl1231) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_interfaceMemberDecl1231
    
    const_set_lazy(:FOLLOW_voidInterfaceMethodDeclaratorRest_in_interfaceMemberDecl1233) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_voidInterfaceMethodDeclaratorRest_in_interfaceMemberDecl1233
    
    const_set_lazy(:FOLLOW_interfaceDeclaration_in_interfaceMemberDecl1243) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceDeclaration_in_interfaceMemberDecl1243
    
    const_set_lazy(:FOLLOW_classDeclaration_in_interfaceMemberDecl1253) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classDeclaration_in_interfaceMemberDecl1253
    
    const_set_lazy(:FOLLOW_type_in_interfaceMethodOrFieldDecl1276) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_interfaceMethodOrFieldDecl1276
    
    const_set_lazy(:FOLLOW_Identifier_in_interfaceMethodOrFieldDecl1278) { BitSet.new(Array.typed(::Java::Long).new([0x9000000000000, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_interfaceMethodOrFieldDecl1278
    
    const_set_lazy(:FOLLOW_interfaceMethodOrFieldRest_in_interfaceMethodOrFieldDecl1280) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceMethodOrFieldRest_in_interfaceMethodOrFieldDecl1280
    
    const_set_lazy(:FOLLOW_constantDeclaratorsRest_in_interfaceMethodOrFieldRest1303) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_constantDeclaratorsRest_in_interfaceMethodOrFieldRest1303
    
    const_set_lazy(:FOLLOW_26_in_interfaceMethodOrFieldRest1305) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_interfaceMethodOrFieldRest1305
    
    const_set_lazy(:FOLLOW_interfaceMethodDeclaratorRest_in_interfaceMethodOrFieldRest1315) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceMethodDeclaratorRest_in_interfaceMethodOrFieldRest1315
    
    const_set_lazy(:FOLLOW_formalParameters_in_methodDeclaratorRest1338) { BitSet.new(Array.typed(::Java::Long).new([0x5100014000000])) }
    const_attr_reader  :FOLLOW_formalParameters_in_methodDeclaratorRest1338
    
    const_set_lazy(:FOLLOW_48_in_methodDeclaratorRest1341) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_methodDeclaratorRest1341
    
    const_set_lazy(:FOLLOW_49_in_methodDeclaratorRest1343) { BitSet.new(Array.typed(::Java::Long).new([0x5100014000000])) }
    const_attr_reader  :FOLLOW_49_in_methodDeclaratorRest1343
    
    const_set_lazy(:FOLLOW_50_in_methodDeclaratorRest1356) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_50_in_methodDeclaratorRest1356
    
    const_set_lazy(:FOLLOW_qualifiedNameList_in_methodDeclaratorRest1358) { BitSet.new(Array.typed(::Java::Long).new([0x100014000000])) }
    const_attr_reader  :FOLLOW_qualifiedNameList_in_methodDeclaratorRest1358
    
    const_set_lazy(:FOLLOW_methodBody_in_methodDeclaratorRest1374) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_methodBody_in_methodDeclaratorRest1374
    
    const_set_lazy(:FOLLOW_26_in_methodDeclaratorRest1388) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_methodDeclaratorRest1388
    
    const_set_lazy(:FOLLOW_formalParameters_in_voidMethodDeclaratorRest1421) { BitSet.new(Array.typed(::Java::Long).new([0x4100014000000])) }
    const_attr_reader  :FOLLOW_formalParameters_in_voidMethodDeclaratorRest1421
    
    const_set_lazy(:FOLLOW_50_in_voidMethodDeclaratorRest1424) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_50_in_voidMethodDeclaratorRest1424
    
    const_set_lazy(:FOLLOW_qualifiedNameList_in_voidMethodDeclaratorRest1426) { BitSet.new(Array.typed(::Java::Long).new([0x100014000000])) }
    const_attr_reader  :FOLLOW_qualifiedNameList_in_voidMethodDeclaratorRest1426
    
    const_set_lazy(:FOLLOW_methodBody_in_voidMethodDeclaratorRest1442) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_methodBody_in_voidMethodDeclaratorRest1442
    
    const_set_lazy(:FOLLOW_26_in_voidMethodDeclaratorRest1456) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_voidMethodDeclaratorRest1456
    
    const_set_lazy(:FOLLOW_formalParameters_in_interfaceMethodDeclaratorRest1489) { BitSet.new(Array.typed(::Java::Long).new([0x5000004000000])) }
    const_attr_reader  :FOLLOW_formalParameters_in_interfaceMethodDeclaratorRest1489
    
    const_set_lazy(:FOLLOW_48_in_interfaceMethodDeclaratorRest1492) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_interfaceMethodDeclaratorRest1492
    
    const_set_lazy(:FOLLOW_49_in_interfaceMethodDeclaratorRest1494) { BitSet.new(Array.typed(::Java::Long).new([0x5000004000000])) }
    const_attr_reader  :FOLLOW_49_in_interfaceMethodDeclaratorRest1494
    
    const_set_lazy(:FOLLOW_50_in_interfaceMethodDeclaratorRest1499) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_50_in_interfaceMethodDeclaratorRest1499
    
    const_set_lazy(:FOLLOW_qualifiedNameList_in_interfaceMethodDeclaratorRest1501) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_qualifiedNameList_in_interfaceMethodDeclaratorRest1501
    
    const_set_lazy(:FOLLOW_26_in_interfaceMethodDeclaratorRest1505) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_interfaceMethodDeclaratorRest1505
    
    const_set_lazy(:FOLLOW_typeParameters_in_interfaceGenericMethodDecl1528) { BitSet.new(Array.typed(::Java::Long).new([-0xff7ffffffffff0])) }
    const_attr_reader  :FOLLOW_typeParameters_in_interfaceGenericMethodDecl1528
    
    const_set_lazy(:FOLLOW_type_in_interfaceGenericMethodDecl1531) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_interfaceGenericMethodDecl1531
    
    const_set_lazy(:FOLLOW_47_in_interfaceGenericMethodDecl1535) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_47_in_interfaceGenericMethodDecl1535
    
    const_set_lazy(:FOLLOW_Identifier_in_interfaceGenericMethodDecl1538) { BitSet.new(Array.typed(::Java::Long).new([0x9000000000000, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_interfaceGenericMethodDecl1538
    
    const_set_lazy(:FOLLOW_interfaceMethodDeclaratorRest_in_interfaceGenericMethodDecl1548) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_interfaceMethodDeclaratorRest_in_interfaceGenericMethodDecl1548
    
    const_set_lazy(:FOLLOW_formalParameters_in_voidInterfaceMethodDeclaratorRest1571) { BitSet.new(Array.typed(::Java::Long).new([0x4000004000000])) }
    const_attr_reader  :FOLLOW_formalParameters_in_voidInterfaceMethodDeclaratorRest1571
    
    const_set_lazy(:FOLLOW_50_in_voidInterfaceMethodDeclaratorRest1574) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_50_in_voidInterfaceMethodDeclaratorRest1574
    
    const_set_lazy(:FOLLOW_qualifiedNameList_in_voidInterfaceMethodDeclaratorRest1576) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_qualifiedNameList_in_voidInterfaceMethodDeclaratorRest1576
    
    const_set_lazy(:FOLLOW_26_in_voidInterfaceMethodDeclaratorRest1580) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_voidInterfaceMethodDeclaratorRest1580
    
    const_set_lazy(:FOLLOW_formalParameters_in_constructorDeclaratorRest1603) { BitSet.new(Array.typed(::Java::Long).new([0x4100000000000])) }
    const_attr_reader  :FOLLOW_formalParameters_in_constructorDeclaratorRest1603
    
    const_set_lazy(:FOLLOW_50_in_constructorDeclaratorRest1606) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_50_in_constructorDeclaratorRest1606
    
    const_set_lazy(:FOLLOW_qualifiedNameList_in_constructorDeclaratorRest1608) { BitSet.new(Array.typed(::Java::Long).new([0x4100000000000])) }
    const_attr_reader  :FOLLOW_qualifiedNameList_in_constructorDeclaratorRest1608
    
    const_set_lazy(:FOLLOW_constructorBody_in_constructorDeclaratorRest1612) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_constructorBody_in_constructorDeclaratorRest1612
    
    const_set_lazy(:FOLLOW_Identifier_in_constantDeclarator1631) { BitSet.new(Array.typed(::Java::Long).new([0x9000000000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_constantDeclarator1631
    
    const_set_lazy(:FOLLOW_constantDeclaratorRest_in_constantDeclarator1633) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_constantDeclaratorRest_in_constantDeclarator1633
    
    const_set_lazy(:FOLLOW_variableDeclarator_in_variableDeclarators1656) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_variableDeclarator_in_variableDeclarators1656
    
    const_set_lazy(:FOLLOW_41_in_variableDeclarators1659) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_41_in_variableDeclarators1659
    
    const_set_lazy(:FOLLOW_variableDeclarator_in_variableDeclarators1661) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_variableDeclarator_in_variableDeclarators1661
    
    const_set_lazy(:FOLLOW_variableDeclaratorId_in_variableDeclarator1682) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000002])) }
    const_attr_reader  :FOLLOW_variableDeclaratorId_in_variableDeclarator1682
    
    const_set_lazy(:FOLLOW_51_in_variableDeclarator1685) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_51_in_variableDeclarator1685
    
    const_set_lazy(:FOLLOW_variableInitializer_in_variableDeclarator1687) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_variableInitializer_in_variableDeclarator1687
    
    const_set_lazy(:FOLLOW_constantDeclaratorRest_in_constantDeclaratorsRest1712) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_constantDeclaratorRest_in_constantDeclaratorsRest1712
    
    const_set_lazy(:FOLLOW_41_in_constantDeclaratorsRest1715) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_41_in_constantDeclaratorsRest1715
    
    const_set_lazy(:FOLLOW_constantDeclarator_in_constantDeclaratorsRest1717) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_constantDeclarator_in_constantDeclaratorsRest1717
    
    const_set_lazy(:FOLLOW_48_in_constantDeclaratorRest1739) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_constantDeclaratorRest1739
    
    const_set_lazy(:FOLLOW_49_in_constantDeclaratorRest1741) { BitSet.new(Array.typed(::Java::Long).new([0x9000000000000])) }
    const_attr_reader  :FOLLOW_49_in_constantDeclaratorRest1741
    
    const_set_lazy(:FOLLOW_51_in_constantDeclaratorRest1745) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_51_in_constantDeclaratorRest1745
    
    const_set_lazy(:FOLLOW_variableInitializer_in_constantDeclaratorRest1747) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_variableInitializer_in_constantDeclaratorRest1747
    
    const_set_lazy(:FOLLOW_Identifier_in_variableDeclaratorId1770) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_variableDeclaratorId1770
    
    const_set_lazy(:FOLLOW_48_in_variableDeclaratorId1773) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_variableDeclaratorId1773
    
    const_set_lazy(:FOLLOW_49_in_variableDeclaratorId1775) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_variableDeclaratorId1775
    
    const_set_lazy(:FOLLOW_arrayInitializer_in_variableInitializer1796) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arrayInitializer_in_variableInitializer1796
    
    const_set_lazy(:FOLLOW_expression_in_variableInitializer1806) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_variableInitializer1806
    
    const_set_lazy(:FOLLOW_44_in_arrayInitializer1833) { BitSet.new(Array.typed(::Java::Long).new([-0xff4ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_44_in_arrayInitializer1833
    
    const_set_lazy(:FOLLOW_variableInitializer_in_arrayInitializer1836) { BitSet.new(Array.typed(::Java::Long).new([0x220000000000])) }
    const_attr_reader  :FOLLOW_variableInitializer_in_arrayInitializer1836
    
    const_set_lazy(:FOLLOW_41_in_arrayInitializer1839) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_41_in_arrayInitializer1839
    
    const_set_lazy(:FOLLOW_variableInitializer_in_arrayInitializer1841) { BitSet.new(Array.typed(::Java::Long).new([0x220000000000])) }
    const_attr_reader  :FOLLOW_variableInitializer_in_arrayInitializer1841
    
    const_set_lazy(:FOLLOW_41_in_arrayInitializer1846) { BitSet.new(Array.typed(::Java::Long).new([0x200000000000])) }
    const_attr_reader  :FOLLOW_41_in_arrayInitializer1846
    
    const_set_lazy(:FOLLOW_45_in_arrayInitializer1853) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_arrayInitializer1853
    
    const_set_lazy(:FOLLOW_annotation_in_modifier1872) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotation_in_modifier1872
    
    const_set_lazy(:FOLLOW_31_in_modifier1882) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_31_in_modifier1882
    
    const_set_lazy(:FOLLOW_32_in_modifier1892) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_32_in_modifier1892
    
    const_set_lazy(:FOLLOW_33_in_modifier1902) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_33_in_modifier1902
    
    const_set_lazy(:FOLLOW_28_in_modifier1912) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_28_in_modifier1912
    
    const_set_lazy(:FOLLOW_34_in_modifier1922) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_34_in_modifier1922
    
    const_set_lazy(:FOLLOW_35_in_modifier1932) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_35_in_modifier1932
    
    const_set_lazy(:FOLLOW_52_in_modifier1942) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_52_in_modifier1942
    
    const_set_lazy(:FOLLOW_53_in_modifier1952) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_53_in_modifier1952
    
    const_set_lazy(:FOLLOW_54_in_modifier1962) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_54_in_modifier1962
    
    const_set_lazy(:FOLLOW_55_in_modifier1972) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_55_in_modifier1972
    
    const_set_lazy(:FOLLOW_36_in_modifier1982) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_36_in_modifier1982
    
    const_set_lazy(:FOLLOW_qualifiedName_in_packageOrTypeName2001) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_qualifiedName_in_packageOrTypeName2001
    
    const_set_lazy(:FOLLOW_Identifier_in_enumConstantName2020) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_Identifier_in_enumConstantName2020
    
    const_set_lazy(:FOLLOW_qualifiedName_in_typeName2039) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_qualifiedName_in_typeName2039
    
    const_set_lazy(:FOLLOW_classOrInterfaceType_in_type2053) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_classOrInterfaceType_in_type2053
    
    const_set_lazy(:FOLLOW_48_in_type2056) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_type2056
    
    const_set_lazy(:FOLLOW_49_in_type2058) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_type2058
    
    const_set_lazy(:FOLLOW_primitiveType_in_type2065) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_primitiveType_in_type2065
    
    const_set_lazy(:FOLLOW_48_in_type2068) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_type2068
    
    const_set_lazy(:FOLLOW_49_in_type2070) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_type2070
    
    const_set_lazy(:FOLLOW_Identifier_in_classOrInterfaceType2083) { BitSet.new(Array.typed(::Java::Long).new([0x10020000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_classOrInterfaceType2083
    
    const_set_lazy(:FOLLOW_typeArguments_in_classOrInterfaceType2085) { BitSet.new(Array.typed(::Java::Long).new([0x20000002])) }
    const_attr_reader  :FOLLOW_typeArguments_in_classOrInterfaceType2085
    
    const_set_lazy(:FOLLOW_29_in_classOrInterfaceType2089) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_classOrInterfaceType2089
    
    const_set_lazy(:FOLLOW_Identifier_in_classOrInterfaceType2091) { BitSet.new(Array.typed(::Java::Long).new([0x10020000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_classOrInterfaceType2091
    
    const_set_lazy(:FOLLOW_typeArguments_in_classOrInterfaceType2093) { BitSet.new(Array.typed(::Java::Long).new([0x20000002])) }
    const_attr_reader  :FOLLOW_typeArguments_in_classOrInterfaceType2093
    
    const_set_lazy(:FOLLOW_set_in_primitiveType0) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_set_in_primitiveType0
    
    const_set_lazy(:FOLLOW_35_in_variableModifier2202) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_35_in_variableModifier2202
    
    const_set_lazy(:FOLLOW_annotation_in_variableModifier2212) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotation_in_variableModifier2212
    
    const_set_lazy(:FOLLOW_40_in_typeArguments2231) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0, 0x1])) }
    const_attr_reader  :FOLLOW_40_in_typeArguments2231
    
    const_set_lazy(:FOLLOW_typeArgument_in_typeArguments2233) { BitSet.new(Array.typed(::Java::Long).new([0x60000000000])) }
    const_attr_reader  :FOLLOW_typeArgument_in_typeArguments2233
    
    const_set_lazy(:FOLLOW_41_in_typeArguments2236) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0, 0x1])) }
    const_attr_reader  :FOLLOW_41_in_typeArguments2236
    
    const_set_lazy(:FOLLOW_typeArgument_in_typeArguments2238) { BitSet.new(Array.typed(::Java::Long).new([0x60000000000])) }
    const_attr_reader  :FOLLOW_typeArgument_in_typeArguments2238
    
    const_set_lazy(:FOLLOW_42_in_typeArguments2242) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_typeArguments2242
    
    const_set_lazy(:FOLLOW_type_in_typeArgument2265) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_type_in_typeArgument2265
    
    const_set_lazy(:FOLLOW_64_in_typeArgument2275) { BitSet.new(Array.typed(::Java::Long).new([0x4000000002, 0x2])) }
    const_attr_reader  :FOLLOW_64_in_typeArgument2275
    
    const_set_lazy(:FOLLOW_set_in_typeArgument2278) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_set_in_typeArgument2278
    
    const_set_lazy(:FOLLOW_type_in_typeArgument2286) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_type_in_typeArgument2286
    
    const_set_lazy(:FOLLOW_qualifiedName_in_qualifiedNameList2311) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_qualifiedName_in_qualifiedNameList2311
    
    const_set_lazy(:FOLLOW_41_in_qualifiedNameList2314) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_41_in_qualifiedNameList2314
    
    const_set_lazy(:FOLLOW_qualifiedName_in_qualifiedNameList2316) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_qualifiedName_in_qualifiedNameList2316
    
    const_set_lazy(:FOLLOW_66_in_formalParameters2337) { BitSet.new(Array.typed(::Java::Long).new([-0xfffff7fffffff0, 0x208])) }
    const_attr_reader  :FOLLOW_66_in_formalParameters2337
    
    const_set_lazy(:FOLLOW_formalParameterDecls_in_formalParameters2339) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_formalParameterDecls_in_formalParameters2339
    
    const_set_lazy(:FOLLOW_67_in_formalParameters2342) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_67_in_formalParameters2342
    
    const_set_lazy(:FOLLOW_variableModifiers_in_formalParameterDecls2365) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_variableModifiers_in_formalParameterDecls2365
    
    const_set_lazy(:FOLLOW_type_in_formalParameterDecls2367) { BitSet.new(Array.typed(::Java::Long).new([0x10, 0x10])) }
    const_attr_reader  :FOLLOW_type_in_formalParameterDecls2367
    
    const_set_lazy(:FOLLOW_formalParameterDeclsRest_in_formalParameterDecls2369) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_formalParameterDeclsRest_in_formalParameterDecls2369
    
    const_set_lazy(:FOLLOW_variableDeclaratorId_in_formalParameterDeclsRest2392) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_variableDeclaratorId_in_formalParameterDeclsRest2392
    
    const_set_lazy(:FOLLOW_41_in_formalParameterDeclsRest2395) { BitSet.new(Array.typed(::Java::Long).new([-0xfffff7fffffff0, 0x200])) }
    const_attr_reader  :FOLLOW_41_in_formalParameterDeclsRest2395
    
    const_set_lazy(:FOLLOW_formalParameterDecls_in_formalParameterDeclsRest2397) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_formalParameterDecls_in_formalParameterDeclsRest2397
    
    const_set_lazy(:FOLLOW_68_in_formalParameterDeclsRest2409) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_68_in_formalParameterDeclsRest2409
    
    const_set_lazy(:FOLLOW_variableDeclaratorId_in_formalParameterDeclsRest2411) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_variableDeclaratorId_in_formalParameterDeclsRest2411
    
    const_set_lazy(:FOLLOW_block_in_methodBody2434) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_methodBody2434
    
    const_set_lazy(:FOLLOW_44_in_constructorBody2453) { BitSet.new(Array.typed(::Java::Long).new([-0xdf0ec069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_44_in_constructorBody2453
    
    const_set_lazy(:FOLLOW_explicitConstructorInvocation_in_constructorBody2455) { BitSet.new(Array.typed(::Java::Long).new([-0xdf0fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_explicitConstructorInvocation_in_constructorBody2455
    
    const_set_lazy(:FOLLOW_blockStatement_in_constructorBody2458) { BitSet.new(Array.typed(::Java::Long).new([-0xdf0fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_blockStatement_in_constructorBody2458
    
    const_set_lazy(:FOLLOW_45_in_constructorBody2461) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_constructorBody2461
    
    const_set_lazy(:FOLLOW_nonWildcardTypeArguments_in_explicitConstructorInvocation2480) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x22])) }
    const_attr_reader  :FOLLOW_nonWildcardTypeArguments_in_explicitConstructorInvocation2480
    
    const_set_lazy(:FOLLOW_set_in_explicitConstructorInvocation2483) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_set_in_explicitConstructorInvocation2483
    
    const_set_lazy(:FOLLOW_arguments_in_explicitConstructorInvocation2491) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_arguments_in_explicitConstructorInvocation2491
    
    const_set_lazy(:FOLLOW_26_in_explicitConstructorInvocation2493) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_explicitConstructorInvocation2493
    
    const_set_lazy(:FOLLOW_primary_in_explicitConstructorInvocation2503) { BitSet.new(Array.typed(::Java::Long).new([0x20000000])) }
    const_attr_reader  :FOLLOW_primary_in_explicitConstructorInvocation2503
    
    const_set_lazy(:FOLLOW_29_in_explicitConstructorInvocation2505) { BitSet.new(Array.typed(::Java::Long).new([0x10000000000, 0x2])) }
    const_attr_reader  :FOLLOW_29_in_explicitConstructorInvocation2505
    
    const_set_lazy(:FOLLOW_nonWildcardTypeArguments_in_explicitConstructorInvocation2507) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x2])) }
    const_attr_reader  :FOLLOW_nonWildcardTypeArguments_in_explicitConstructorInvocation2507
    
    const_set_lazy(:FOLLOW_65_in_explicitConstructorInvocation2510) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_65_in_explicitConstructorInvocation2510
    
    const_set_lazy(:FOLLOW_arguments_in_explicitConstructorInvocation2512) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_arguments_in_explicitConstructorInvocation2512
    
    const_set_lazy(:FOLLOW_26_in_explicitConstructorInvocation2514) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_explicitConstructorInvocation2514
    
    const_set_lazy(:FOLLOW_Identifier_in_qualifiedName2534) { BitSet.new(Array.typed(::Java::Long).new([0x20000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_qualifiedName2534
    
    const_set_lazy(:FOLLOW_29_in_qualifiedName2537) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_qualifiedName2537
    
    const_set_lazy(:FOLLOW_Identifier_in_qualifiedName2539) { BitSet.new(Array.typed(::Java::Long).new([0x20000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_qualifiedName2539
    
    const_set_lazy(:FOLLOW_integerLiteral_in_literal2565) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_integerLiteral_in_literal2565
    
    const_set_lazy(:FOLLOW_FloatingPointLiteral_in_literal2575) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_FloatingPointLiteral_in_literal2575
    
    const_set_lazy(:FOLLOW_CharacterLiteral_in_literal2585) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_CharacterLiteral_in_literal2585
    
    const_set_lazy(:FOLLOW_StringLiteral_in_literal2595) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_StringLiteral_in_literal2595
    
    const_set_lazy(:FOLLOW_booleanLiteral_in_literal2605) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_booleanLiteral_in_literal2605
    
    const_set_lazy(:FOLLOW_70_in_literal2615) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_70_in_literal2615
    
    const_set_lazy(:FOLLOW_set_in_integerLiteral0) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_set_in_integerLiteral0
    
    const_set_lazy(:FOLLOW_set_in_booleanLiteral0) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_set_in_booleanLiteral0
    
    const_set_lazy(:FOLLOW_annotation_in_annotations2704) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x200])) }
    const_attr_reader  :FOLLOW_annotation_in_annotations2704
    
    const_set_lazy(:FOLLOW_73_in_annotation2724) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_73_in_annotation2724
    
    const_set_lazy(:FOLLOW_annotationName_in_annotation2726) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x4])) }
    const_attr_reader  :FOLLOW_annotationName_in_annotation2726
    
    const_set_lazy(:FOLLOW_66_in_annotation2730) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000003ee])) }
    const_attr_reader  :FOLLOW_66_in_annotation2730
    
    const_set_lazy(:FOLLOW_elementValuePairs_in_annotation2734) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_elementValuePairs_in_annotation2734
    
    const_set_lazy(:FOLLOW_elementValue_in_annotation2738) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_elementValue_in_annotation2738
    
    const_set_lazy(:FOLLOW_67_in_annotation2743) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_67_in_annotation2743
    
    const_set_lazy(:FOLLOW_Identifier_in_annotationName2767) { BitSet.new(Array.typed(::Java::Long).new([0x20000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_annotationName2767
    
    const_set_lazy(:FOLLOW_29_in_annotationName2770) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_annotationName2770
    
    const_set_lazy(:FOLLOW_Identifier_in_annotationName2772) { BitSet.new(Array.typed(::Java::Long).new([0x20000002])) }
    const_attr_reader  :FOLLOW_Identifier_in_annotationName2772
    
    const_set_lazy(:FOLLOW_elementValuePair_in_elementValuePairs2793) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_elementValuePair_in_elementValuePairs2793
    
    const_set_lazy(:FOLLOW_41_in_elementValuePairs2796) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_41_in_elementValuePairs2796
    
    const_set_lazy(:FOLLOW_elementValuePair_in_elementValuePairs2798) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_elementValuePair_in_elementValuePairs2798
    
    const_set_lazy(:FOLLOW_Identifier_in_elementValuePair2819) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_elementValuePair2819
    
    const_set_lazy(:FOLLOW_51_in_elementValuePair2821) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000003e6])) }
    const_attr_reader  :FOLLOW_51_in_elementValuePair2821
    
    const_set_lazy(:FOLLOW_elementValue_in_elementValuePair2823) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_elementValue_in_elementValuePair2823
    
    const_set_lazy(:FOLLOW_conditionalExpression_in_elementValue2846) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_conditionalExpression_in_elementValue2846
    
    const_set_lazy(:FOLLOW_annotation_in_elementValue2856) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotation_in_elementValue2856
    
    const_set_lazy(:FOLLOW_elementValueArrayInitializer_in_elementValue2866) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_elementValueArrayInitializer_in_elementValue2866
    
    const_set_lazy(:FOLLOW_44_in_elementValueArrayInitializer2889) { BitSet.new(Array.typed(::Java::Long).new([-0xff4dfffffff030, 0x3e600000003e6])) }
    const_attr_reader  :FOLLOW_44_in_elementValueArrayInitializer2889
    
    const_set_lazy(:FOLLOW_elementValue_in_elementValueArrayInitializer2892) { BitSet.new(Array.typed(::Java::Long).new([0x220000000000])) }
    const_attr_reader  :FOLLOW_elementValue_in_elementValueArrayInitializer2892
    
    const_set_lazy(:FOLLOW_41_in_elementValueArrayInitializer2895) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000003e6])) }
    const_attr_reader  :FOLLOW_41_in_elementValueArrayInitializer2895
    
    const_set_lazy(:FOLLOW_elementValue_in_elementValueArrayInitializer2897) { BitSet.new(Array.typed(::Java::Long).new([0x220000000000])) }
    const_attr_reader  :FOLLOW_elementValue_in_elementValueArrayInitializer2897
    
    const_set_lazy(:FOLLOW_41_in_elementValueArrayInitializer2904) { BitSet.new(Array.typed(::Java::Long).new([0x200000000000])) }
    const_attr_reader  :FOLLOW_41_in_elementValueArrayInitializer2904
    
    const_set_lazy(:FOLLOW_45_in_elementValueArrayInitializer2908) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_elementValueArrayInitializer2908
    
    const_set_lazy(:FOLLOW_73_in_annotationTypeDeclaration2931) { BitSet.new(Array.typed(::Java::Long).new([0x400000000000])) }
    const_attr_reader  :FOLLOW_73_in_annotationTypeDeclaration2931
    
    const_set_lazy(:FOLLOW_46_in_annotationTypeDeclaration2933) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_46_in_annotationTypeDeclaration2933
    
    const_set_lazy(:FOLLOW_Identifier_in_annotationTypeDeclaration2935) { BitSet.new(Array.typed(::Java::Long).new([0x100000000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_annotationTypeDeclaration2935
    
    const_set_lazy(:FOLLOW_annotationTypeBody_in_annotationTypeDeclaration2937) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotationTypeBody_in_annotationTypeDeclaration2937
    
    const_set_lazy(:FOLLOW_44_in_annotationTypeBody2960) { BitSet.new(Array.typed(::Java::Long).new([0xf0301f94000000, 0x200])) }
    const_attr_reader  :FOLLOW_44_in_annotationTypeBody2960
    
    const_set_lazy(:FOLLOW_annotationTypeElementDeclaration_in_annotationTypeBody2963) { BitSet.new(Array.typed(::Java::Long).new([0xf0301f94000000, 0x200])) }
    const_attr_reader  :FOLLOW_annotationTypeElementDeclaration_in_annotationTypeBody2963
    
    const_set_lazy(:FOLLOW_45_in_annotationTypeBody2967) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_annotationTypeBody2967
    
    const_set_lazy(:FOLLOW_modifiers_in_annotationTypeElementDeclaration2990) { BitSet.new(Array.typed(::Java::Long).new([-0xffbfc06dffffd0, 0x200])) }
    const_attr_reader  :FOLLOW_modifiers_in_annotationTypeElementDeclaration2990
    
    const_set_lazy(:FOLLOW_annotationTypeElementRest_in_annotationTypeElementDeclaration2992) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotationTypeElementRest_in_annotationTypeElementDeclaration2992
    
    const_set_lazy(:FOLLOW_type_in_annotationTypeElementRest3015) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_annotationTypeElementRest3015
    
    const_set_lazy(:FOLLOW_annotationMethodOrConstantRest_in_annotationTypeElementRest3017) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_annotationMethodOrConstantRest_in_annotationTypeElementRest3017
    
    const_set_lazy(:FOLLOW_26_in_annotationTypeElementRest3019) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_annotationTypeElementRest3019
    
    const_set_lazy(:FOLLOW_normalClassDeclaration_in_annotationTypeElementRest3029) { BitSet.new(Array.typed(::Java::Long).new([0x4000002])) }
    const_attr_reader  :FOLLOW_normalClassDeclaration_in_annotationTypeElementRest3029
    
    const_set_lazy(:FOLLOW_26_in_annotationTypeElementRest3031) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_annotationTypeElementRest3031
    
    const_set_lazy(:FOLLOW_normalInterfaceDeclaration_in_annotationTypeElementRest3042) { BitSet.new(Array.typed(::Java::Long).new([0x4000002])) }
    const_attr_reader  :FOLLOW_normalInterfaceDeclaration_in_annotationTypeElementRest3042
    
    const_set_lazy(:FOLLOW_26_in_annotationTypeElementRest3044) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_annotationTypeElementRest3044
    
    const_set_lazy(:FOLLOW_enumDeclaration_in_annotationTypeElementRest3055) { BitSet.new(Array.typed(::Java::Long).new([0x4000002])) }
    const_attr_reader  :FOLLOW_enumDeclaration_in_annotationTypeElementRest3055
    
    const_set_lazy(:FOLLOW_26_in_annotationTypeElementRest3057) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_annotationTypeElementRest3057
    
    const_set_lazy(:FOLLOW_annotationTypeDeclaration_in_annotationTypeElementRest3068) { BitSet.new(Array.typed(::Java::Long).new([0x4000002])) }
    const_attr_reader  :FOLLOW_annotationTypeDeclaration_in_annotationTypeElementRest3068
    
    const_set_lazy(:FOLLOW_26_in_annotationTypeElementRest3070) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_annotationTypeElementRest3070
    
    const_set_lazy(:FOLLOW_annotationMethodRest_in_annotationMethodOrConstantRest3094) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotationMethodRest_in_annotationMethodOrConstantRest3094
    
    const_set_lazy(:FOLLOW_annotationConstantRest_in_annotationMethodOrConstantRest3104) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotationConstantRest_in_annotationMethodOrConstantRest3104
    
    const_set_lazy(:FOLLOW_Identifier_in_annotationMethodRest3127) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_annotationMethodRest3127
    
    const_set_lazy(:FOLLOW_66_in_annotationMethodRest3129) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_66_in_annotationMethodRest3129
    
    const_set_lazy(:FOLLOW_67_in_annotationMethodRest3131) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x400])) }
    const_attr_reader  :FOLLOW_67_in_annotationMethodRest3131
    
    const_set_lazy(:FOLLOW_defaultValue_in_annotationMethodRest3133) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_defaultValue_in_annotationMethodRest3133
    
    const_set_lazy(:FOLLOW_variableDeclarators_in_annotationConstantRest3157) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_variableDeclarators_in_annotationConstantRest3157
    
    const_set_lazy(:FOLLOW_74_in_defaultValue3180) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000003e6])) }
    const_attr_reader  :FOLLOW_74_in_defaultValue3180
    
    const_set_lazy(:FOLLOW_elementValue_in_defaultValue3182) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_elementValue_in_defaultValue3182
    
    const_set_lazy(:FOLLOW_44_in_block3203) { BitSet.new(Array.typed(::Java::Long).new([-0xdf0fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_44_in_block3203
    
    const_set_lazy(:FOLLOW_blockStatement_in_block3205) { BitSet.new(Array.typed(::Java::Long).new([-0xdf0fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_blockStatement_in_block3205
    
    const_set_lazy(:FOLLOW_45_in_block3208) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_block3208
    
    const_set_lazy(:FOLLOW_localVariableDeclarationStatement_in_blockStatement3231) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_localVariableDeclarationStatement_in_blockStatement3231
    
    const_set_lazy(:FOLLOW_classOrInterfaceDeclaration_in_blockStatement3241) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classOrInterfaceDeclaration_in_blockStatement3241
    
    const_set_lazy(:FOLLOW_statement_in_blockStatement3251) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_statement_in_blockStatement3251
    
    const_set_lazy(:FOLLOW_localVariableDeclaration_in_localVariableDeclarationStatement3275) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_localVariableDeclaration_in_localVariableDeclarationStatement3275
    
    const_set_lazy(:FOLLOW_26_in_localVariableDeclarationStatement3277) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_localVariableDeclarationStatement3277
    
    const_set_lazy(:FOLLOW_variableModifiers_in_localVariableDeclaration3296) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_variableModifiers_in_localVariableDeclaration3296
    
    const_set_lazy(:FOLLOW_type_in_localVariableDeclaration3298) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_localVariableDeclaration3298
    
    const_set_lazy(:FOLLOW_variableDeclarators_in_localVariableDeclaration3300) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_variableDeclarators_in_localVariableDeclaration3300
    
    const_set_lazy(:FOLLOW_variableModifier_in_variableModifiers3323) { BitSet.new(Array.typed(::Java::Long).new([0x800000002, 0x200])) }
    const_attr_reader  :FOLLOW_variableModifier_in_variableModifiers3323
    
    const_set_lazy(:FOLLOW_block_in_statement3341) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_statement3341
    
    const_set_lazy(:FOLLOW_ASSERT_in_statement3351) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_ASSERT_in_statement3351
    
    const_set_lazy(:FOLLOW_expression_in_statement3353) { BitSet.new(Array.typed(::Java::Long).new([0x4000000, 0x800])) }
    const_attr_reader  :FOLLOW_expression_in_statement3353
    
    const_set_lazy(:FOLLOW_75_in_statement3356) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_75_in_statement3356
    
    const_set_lazy(:FOLLOW_expression_in_statement3358) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_expression_in_statement3358
    
    const_set_lazy(:FOLLOW_26_in_statement3362) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3362
    
    const_set_lazy(:FOLLOW_76_in_statement3372) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_76_in_statement3372
    
    const_set_lazy(:FOLLOW_parExpression_in_statement3374) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_parExpression_in_statement3374
    
    const_set_lazy(:FOLLOW_statement_in_statement3376) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x2000])) }
    const_attr_reader  :FOLLOW_statement_in_statement3376
    
    const_set_lazy(:FOLLOW_77_in_statement3386) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_77_in_statement3386
    
    const_set_lazy(:FOLLOW_statement_in_statement3388) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_statement_in_statement3388
    
    const_set_lazy(:FOLLOW_78_in_statement3400) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_78_in_statement3400
    
    const_set_lazy(:FOLLOW_66_in_statement3402) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ff7fbfff030, 0x3e600000003e6])) }
    const_attr_reader  :FOLLOW_66_in_statement3402
    
    const_set_lazy(:FOLLOW_forControl_in_statement3404) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_forControl_in_statement3404
    
    const_set_lazy(:FOLLOW_67_in_statement3406) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_67_in_statement3406
    
    const_set_lazy(:FOLLOW_statement_in_statement3408) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_statement_in_statement3408
    
    const_set_lazy(:FOLLOW_79_in_statement3418) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_79_in_statement3418
    
    const_set_lazy(:FOLLOW_parExpression_in_statement3420) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_parExpression_in_statement3420
    
    const_set_lazy(:FOLLOW_statement_in_statement3422) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_statement_in_statement3422
    
    const_set_lazy(:FOLLOW_80_in_statement3432) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_80_in_statement3432
    
    const_set_lazy(:FOLLOW_statement_in_statement3434) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8000])) }
    const_attr_reader  :FOLLOW_statement_in_statement3434
    
    const_set_lazy(:FOLLOW_79_in_statement3436) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_79_in_statement3436
    
    const_set_lazy(:FOLLOW_parExpression_in_statement3438) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_parExpression_in_statement3438
    
    const_set_lazy(:FOLLOW_26_in_statement3440) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3440
    
    const_set_lazy(:FOLLOW_81_in_statement3450) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_81_in_statement3450
    
    const_set_lazy(:FOLLOW_block_in_statement3452) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x1040000])) }
    const_attr_reader  :FOLLOW_block_in_statement3452
    
    const_set_lazy(:FOLLOW_catches_in_statement3464) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x40000])) }
    const_attr_reader  :FOLLOW_catches_in_statement3464
    
    const_set_lazy(:FOLLOW_82_in_statement3466) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_82_in_statement3466
    
    const_set_lazy(:FOLLOW_block_in_statement3468) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_statement3468
    
    const_set_lazy(:FOLLOW_catches_in_statement3480) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_catches_in_statement3480
    
    const_set_lazy(:FOLLOW_82_in_statement3494) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_82_in_statement3494
    
    const_set_lazy(:FOLLOW_block_in_statement3496) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_statement3496
    
    const_set_lazy(:FOLLOW_83_in_statement3516) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_83_in_statement3516
    
    const_set_lazy(:FOLLOW_parExpression_in_statement3518) { BitSet.new(Array.typed(::Java::Long).new([0x100000000000])) }
    const_attr_reader  :FOLLOW_parExpression_in_statement3518
    
    const_set_lazy(:FOLLOW_44_in_statement3520) { BitSet.new(Array.typed(::Java::Long).new([0x200000000000, 0x2000400])) }
    const_attr_reader  :FOLLOW_44_in_statement3520
    
    const_set_lazy(:FOLLOW_switchBlockStatementGroups_in_statement3522) { BitSet.new(Array.typed(::Java::Long).new([0x200000000000])) }
    const_attr_reader  :FOLLOW_switchBlockStatementGroups_in_statement3522
    
    const_set_lazy(:FOLLOW_45_in_statement3524) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_45_in_statement3524
    
    const_set_lazy(:FOLLOW_53_in_statement3534) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_53_in_statement3534
    
    const_set_lazy(:FOLLOW_parExpression_in_statement3536) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_parExpression_in_statement3536
    
    const_set_lazy(:FOLLOW_block_in_statement3538) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_statement3538
    
    const_set_lazy(:FOLLOW_84_in_statement3548) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffbfff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_84_in_statement3548
    
    const_set_lazy(:FOLLOW_expression_in_statement3550) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_expression_in_statement3550
    
    const_set_lazy(:FOLLOW_26_in_statement3553) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3553
    
    const_set_lazy(:FOLLOW_85_in_statement3563) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_85_in_statement3563
    
    const_set_lazy(:FOLLOW_expression_in_statement3565) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_expression_in_statement3565
    
    const_set_lazy(:FOLLOW_26_in_statement3567) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3567
    
    const_set_lazy(:FOLLOW_86_in_statement3577) { BitSet.new(Array.typed(::Java::Long).new([0x4000010])) }
    const_attr_reader  :FOLLOW_86_in_statement3577
    
    const_set_lazy(:FOLLOW_Identifier_in_statement3579) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_statement3579
    
    const_set_lazy(:FOLLOW_26_in_statement3582) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3582
    
    const_set_lazy(:FOLLOW_87_in_statement3592) { BitSet.new(Array.typed(::Java::Long).new([0x4000010])) }
    const_attr_reader  :FOLLOW_87_in_statement3592
    
    const_set_lazy(:FOLLOW_Identifier_in_statement3594) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_Identifier_in_statement3594
    
    const_set_lazy(:FOLLOW_26_in_statement3597) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3597
    
    const_set_lazy(:FOLLOW_26_in_statement3607) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3607
    
    const_set_lazy(:FOLLOW_statementExpression_in_statement3618) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_statementExpression_in_statement3618
    
    const_set_lazy(:FOLLOW_26_in_statement3620) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_statement3620
    
    const_set_lazy(:FOLLOW_Identifier_in_statement3630) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_Identifier_in_statement3630
    
    const_set_lazy(:FOLLOW_75_in_statement3632) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_75_in_statement3632
    
    const_set_lazy(:FOLLOW_statement_in_statement3634) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_statement_in_statement3634
    
    const_set_lazy(:FOLLOW_catchClause_in_catches3657) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x1000000])) }
    const_attr_reader  :FOLLOW_catchClause_in_catches3657
    
    const_set_lazy(:FOLLOW_catchClause_in_catches3660) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x1000000])) }
    const_attr_reader  :FOLLOW_catchClause_in_catches3660
    
    const_set_lazy(:FOLLOW_88_in_catchClause3685) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_88_in_catchClause3685
    
    const_set_lazy(:FOLLOW_66_in_catchClause3687) { BitSet.new(Array.typed(::Java::Long).new([-0xfffff7fffffff0, 0x200])) }
    const_attr_reader  :FOLLOW_66_in_catchClause3687
    
    const_set_lazy(:FOLLOW_formalParameter_in_catchClause3689) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_formalParameter_in_catchClause3689
    
    const_set_lazy(:FOLLOW_67_in_catchClause3691) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_67_in_catchClause3691
    
    const_set_lazy(:FOLLOW_block_in_catchClause3693) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_catchClause3693
    
    const_set_lazy(:FOLLOW_variableModifiers_in_formalParameter3712) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_variableModifiers_in_formalParameter3712
    
    const_set_lazy(:FOLLOW_type_in_formalParameter3714) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_formalParameter3714
    
    const_set_lazy(:FOLLOW_variableDeclaratorId_in_formalParameter3716) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_variableDeclaratorId_in_formalParameter3716
    
    const_set_lazy(:FOLLOW_switchBlockStatementGroup_in_switchBlockStatementGroups3744) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x2000400])) }
    const_attr_reader  :FOLLOW_switchBlockStatementGroup_in_switchBlockStatementGroups3744
    
    const_set_lazy(:FOLLOW_switchLabel_in_switchBlockStatementGroup3771) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe00e, 0x3e60002fbd7e6])) }
    const_attr_reader  :FOLLOW_switchLabel_in_switchBlockStatementGroup3771
    
    const_set_lazy(:FOLLOW_blockStatement_in_switchBlockStatementGroup3774) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe00e, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_blockStatement_in_switchBlockStatementGroup3774
    
    const_set_lazy(:FOLLOW_89_in_switchLabel3798) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_89_in_switchLabel3798
    
    const_set_lazy(:FOLLOW_constantExpression_in_switchLabel3800) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_constantExpression_in_switchLabel3800
    
    const_set_lazy(:FOLLOW_75_in_switchLabel3802) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_75_in_switchLabel3802
    
    const_set_lazy(:FOLLOW_89_in_switchLabel3812) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_89_in_switchLabel3812
    
    const_set_lazy(:FOLLOW_enumConstantName_in_switchLabel3814) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_enumConstantName_in_switchLabel3814
    
    const_set_lazy(:FOLLOW_75_in_switchLabel3816) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_75_in_switchLabel3816
    
    const_set_lazy(:FOLLOW_74_in_switchLabel3826) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_74_in_switchLabel3826
    
    const_set_lazy(:FOLLOW_75_in_switchLabel3828) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_75_in_switchLabel3828
    
    const_set_lazy(:FOLLOW_enhancedForControl_in_forControl3859) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_enhancedForControl_in_forControl3859
    
    const_set_lazy(:FOLLOW_forInit_in_forControl3869) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_forInit_in_forControl3869
    
    const_set_lazy(:FOLLOW_26_in_forControl3872) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffbfff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_26_in_forControl3872
    
    const_set_lazy(:FOLLOW_expression_in_forControl3874) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_expression_in_forControl3874
    
    const_set_lazy(:FOLLOW_26_in_forControl3877) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ff7fffff02e, 0x3e600000003e6])) }
    const_attr_reader  :FOLLOW_26_in_forControl3877
    
    const_set_lazy(:FOLLOW_forUpdate_in_forControl3879) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_forUpdate_in_forControl3879
    
    const_set_lazy(:FOLLOW_localVariableDeclaration_in_forInit3899) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_localVariableDeclaration_in_forInit3899
    
    const_set_lazy(:FOLLOW_expressionList_in_forInit3909) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expressionList_in_forInit3909
    
    const_set_lazy(:FOLLOW_variableModifiers_in_enhancedForControl3932) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_variableModifiers_in_enhancedForControl3932
    
    const_set_lazy(:FOLLOW_type_in_enhancedForControl3934) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_type_in_enhancedForControl3934
    
    const_set_lazy(:FOLLOW_Identifier_in_enhancedForControl3936) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_Identifier_in_enhancedForControl3936
    
    const_set_lazy(:FOLLOW_75_in_enhancedForControl3938) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_75_in_enhancedForControl3938
    
    const_set_lazy(:FOLLOW_expression_in_enhancedForControl3940) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_enhancedForControl3940
    
    const_set_lazy(:FOLLOW_expressionList_in_forUpdate3959) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expressionList_in_forUpdate3959
    
    const_set_lazy(:FOLLOW_66_in_parExpression3980) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_66_in_parExpression3980
    
    const_set_lazy(:FOLLOW_expression_in_parExpression3982) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_expression_in_parExpression3982
    
    const_set_lazy(:FOLLOW_67_in_parExpression3984) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_67_in_parExpression3984
    
    const_set_lazy(:FOLLOW_expression_in_expressionList4007) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_expression_in_expressionList4007
    
    const_set_lazy(:FOLLOW_41_in_expressionList4010) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_41_in_expressionList4010
    
    const_set_lazy(:FOLLOW_expression_in_expressionList4012) { BitSet.new(Array.typed(::Java::Long).new([0x20000000002])) }
    const_attr_reader  :FOLLOW_expression_in_expressionList4012
    
    const_set_lazy(:FOLLOW_expression_in_statementExpression4033) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_statementExpression4033
    
    const_set_lazy(:FOLLOW_expression_in_constantExpression4056) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_constantExpression4056
    
    const_set_lazy(:FOLLOW_conditionalExpression_in_expression4079) { BitSet.new(Array.typed(::Java::Long).new([0x8050000000002, 0x3fc000000])) }
    const_attr_reader  :FOLLOW_conditionalExpression_in_expression4079
    
    const_set_lazy(:FOLLOW_assignmentOperator_in_expression4082) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_assignmentOperator_in_expression4082
    
    const_set_lazy(:FOLLOW_expression_in_expression4084) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_expression4084
    
    const_set_lazy(:FOLLOW_51_in_assignmentOperator4109) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_assignmentOperator4109
    
    const_set_lazy(:FOLLOW_90_in_assignmentOperator4119) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_90_in_assignmentOperator4119
    
    const_set_lazy(:FOLLOW_91_in_assignmentOperator4129) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_91_in_assignmentOperator4129
    
    const_set_lazy(:FOLLOW_92_in_assignmentOperator4139) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_92_in_assignmentOperator4139
    
    const_set_lazy(:FOLLOW_93_in_assignmentOperator4149) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_93_in_assignmentOperator4149
    
    const_set_lazy(:FOLLOW_94_in_assignmentOperator4159) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_94_in_assignmentOperator4159
    
    const_set_lazy(:FOLLOW_95_in_assignmentOperator4169) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_95_in_assignmentOperator4169
    
    const_set_lazy(:FOLLOW_96_in_assignmentOperator4179) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_96_in_assignmentOperator4179
    
    const_set_lazy(:FOLLOW_97_in_assignmentOperator4189) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_97_in_assignmentOperator4189
    
    const_set_lazy(:FOLLOW_40_in_assignmentOperator4210) { BitSet.new(Array.typed(::Java::Long).new([0x10000000000])) }
    const_attr_reader  :FOLLOW_40_in_assignmentOperator4210
    
    const_set_lazy(:FOLLOW_40_in_assignmentOperator4214) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_40_in_assignmentOperator4214
    
    const_set_lazy(:FOLLOW_51_in_assignmentOperator4218) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_assignmentOperator4218
    
    const_set_lazy(:FOLLOW_42_in_assignmentOperator4252) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_assignmentOperator4252
    
    const_set_lazy(:FOLLOW_42_in_assignmentOperator4256) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_assignmentOperator4256
    
    const_set_lazy(:FOLLOW_42_in_assignmentOperator4260) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_42_in_assignmentOperator4260
    
    const_set_lazy(:FOLLOW_51_in_assignmentOperator4264) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_assignmentOperator4264
    
    const_set_lazy(:FOLLOW_42_in_assignmentOperator4295) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_assignmentOperator4295
    
    const_set_lazy(:FOLLOW_42_in_assignmentOperator4299) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_42_in_assignmentOperator4299
    
    const_set_lazy(:FOLLOW_51_in_assignmentOperator4303) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_assignmentOperator4303
    
    const_set_lazy(:FOLLOW_conditionalOrExpression_in_conditionalExpression4332) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x1])) }
    const_attr_reader  :FOLLOW_conditionalOrExpression_in_conditionalExpression4332
    
    const_set_lazy(:FOLLOW_64_in_conditionalExpression4336) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_64_in_conditionalExpression4336
    
    const_set_lazy(:FOLLOW_expression_in_conditionalExpression4338) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_expression_in_conditionalExpression4338
    
    const_set_lazy(:FOLLOW_75_in_conditionalExpression4340) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_75_in_conditionalExpression4340
    
    const_set_lazy(:FOLLOW_expression_in_conditionalExpression4342) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_conditionalExpression4342
    
    const_set_lazy(:FOLLOW_conditionalAndExpression_in_conditionalOrExpression4364) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x400000000])) }
    const_attr_reader  :FOLLOW_conditionalAndExpression_in_conditionalOrExpression4364
    
    const_set_lazy(:FOLLOW_98_in_conditionalOrExpression4368) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_98_in_conditionalOrExpression4368
    
    const_set_lazy(:FOLLOW_conditionalAndExpression_in_conditionalOrExpression4370) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x400000000])) }
    const_attr_reader  :FOLLOW_conditionalAndExpression_in_conditionalOrExpression4370
    
    const_set_lazy(:FOLLOW_inclusiveOrExpression_in_conditionalAndExpression4392) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x800000000])) }
    const_attr_reader  :FOLLOW_inclusiveOrExpression_in_conditionalAndExpression4392
    
    const_set_lazy(:FOLLOW_99_in_conditionalAndExpression4396) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_99_in_conditionalAndExpression4396
    
    const_set_lazy(:FOLLOW_inclusiveOrExpression_in_conditionalAndExpression4398) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x800000000])) }
    const_attr_reader  :FOLLOW_inclusiveOrExpression_in_conditionalAndExpression4398
    
    const_set_lazy(:FOLLOW_exclusiveOrExpression_in_inclusiveOrExpression4420) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x1000000000])) }
    const_attr_reader  :FOLLOW_exclusiveOrExpression_in_inclusiveOrExpression4420
    
    const_set_lazy(:FOLLOW_100_in_inclusiveOrExpression4424) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_100_in_inclusiveOrExpression4424
    
    const_set_lazy(:FOLLOW_exclusiveOrExpression_in_inclusiveOrExpression4426) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x1000000000])) }
    const_attr_reader  :FOLLOW_exclusiveOrExpression_in_inclusiveOrExpression4426
    
    const_set_lazy(:FOLLOW_andExpression_in_exclusiveOrExpression4448) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x2000000000])) }
    const_attr_reader  :FOLLOW_andExpression_in_exclusiveOrExpression4448
    
    const_set_lazy(:FOLLOW_101_in_exclusiveOrExpression4452) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_101_in_exclusiveOrExpression4452
    
    const_set_lazy(:FOLLOW_andExpression_in_exclusiveOrExpression4454) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x2000000000])) }
    const_attr_reader  :FOLLOW_andExpression_in_exclusiveOrExpression4454
    
    const_set_lazy(:FOLLOW_equalityExpression_in_andExpression4476) { BitSet.new(Array.typed(::Java::Long).new([0x80000000002])) }
    const_attr_reader  :FOLLOW_equalityExpression_in_andExpression4476
    
    const_set_lazy(:FOLLOW_43_in_andExpression4480) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_43_in_andExpression4480
    
    const_set_lazy(:FOLLOW_equalityExpression_in_andExpression4482) { BitSet.new(Array.typed(::Java::Long).new([0x80000000002])) }
    const_attr_reader  :FOLLOW_equalityExpression_in_andExpression4482
    
    const_set_lazy(:FOLLOW_instanceOfExpression_in_equalityExpression4504) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0xc000000000])) }
    const_attr_reader  :FOLLOW_instanceOfExpression_in_equalityExpression4504
    
    const_set_lazy(:FOLLOW_set_in_equalityExpression4508) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_set_in_equalityExpression4508
    
    const_set_lazy(:FOLLOW_instanceOfExpression_in_equalityExpression4516) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0xc000000000])) }
    const_attr_reader  :FOLLOW_instanceOfExpression_in_equalityExpression4516
    
    const_set_lazy(:FOLLOW_relationalExpression_in_instanceOfExpression4538) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x10000000000])) }
    const_attr_reader  :FOLLOW_relationalExpression_in_instanceOfExpression4538
    
    const_set_lazy(:FOLLOW_104_in_instanceOfExpression4541) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_104_in_instanceOfExpression4541
    
    const_set_lazy(:FOLLOW_type_in_instanceOfExpression4543) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_type_in_instanceOfExpression4543
    
    const_set_lazy(:FOLLOW_shiftExpression_in_relationalExpression4564) { BitSet.new(Array.typed(::Java::Long).new([0x50000000002])) }
    const_attr_reader  :FOLLOW_shiftExpression_in_relationalExpression4564
    
    const_set_lazy(:FOLLOW_relationalOp_in_relationalExpression4568) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_relationalOp_in_relationalExpression4568
    
    const_set_lazy(:FOLLOW_shiftExpression_in_relationalExpression4570) { BitSet.new(Array.typed(::Java::Long).new([0x50000000002])) }
    const_attr_reader  :FOLLOW_shiftExpression_in_relationalExpression4570
    
    const_set_lazy(:FOLLOW_40_in_relationalOp4605) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_40_in_relationalOp4605
    
    const_set_lazy(:FOLLOW_51_in_relationalOp4609) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_relationalOp4609
    
    const_set_lazy(:FOLLOW_42_in_relationalOp4639) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_42_in_relationalOp4639
    
    const_set_lazy(:FOLLOW_51_in_relationalOp4643) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_relationalOp4643
    
    const_set_lazy(:FOLLOW_40_in_relationalOp4664) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_40_in_relationalOp4664
    
    const_set_lazy(:FOLLOW_42_in_relationalOp4675) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_relationalOp4675
    
    const_set_lazy(:FOLLOW_additiveExpression_in_shiftExpression4695) { BitSet.new(Array.typed(::Java::Long).new([0x50000000002])) }
    const_attr_reader  :FOLLOW_additiveExpression_in_shiftExpression4695
    
    const_set_lazy(:FOLLOW_shiftOp_in_shiftExpression4699) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_shiftOp_in_shiftExpression4699
    
    const_set_lazy(:FOLLOW_additiveExpression_in_shiftExpression4701) { BitSet.new(Array.typed(::Java::Long).new([0x50000000002])) }
    const_attr_reader  :FOLLOW_additiveExpression_in_shiftExpression4701
    
    const_set_lazy(:FOLLOW_40_in_shiftOp4732) { BitSet.new(Array.typed(::Java::Long).new([0x10000000000])) }
    const_attr_reader  :FOLLOW_40_in_shiftOp4732
    
    const_set_lazy(:FOLLOW_40_in_shiftOp4736) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_40_in_shiftOp4736
    
    const_set_lazy(:FOLLOW_42_in_shiftOp4768) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_shiftOp4768
    
    const_set_lazy(:FOLLOW_42_in_shiftOp4772) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_shiftOp4772
    
    const_set_lazy(:FOLLOW_42_in_shiftOp4776) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_shiftOp4776
    
    const_set_lazy(:FOLLOW_42_in_shiftOp4806) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_shiftOp4806
    
    const_set_lazy(:FOLLOW_42_in_shiftOp4810) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_shiftOp4810
    
    const_set_lazy(:FOLLOW_multiplicativeExpression_in_additiveExpression4840) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x60000000000])) }
    const_attr_reader  :FOLLOW_multiplicativeExpression_in_additiveExpression4840
    
    const_set_lazy(:FOLLOW_set_in_additiveExpression4844) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_set_in_additiveExpression4844
    
    const_set_lazy(:FOLLOW_multiplicativeExpression_in_additiveExpression4852) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x60000000000])) }
    const_attr_reader  :FOLLOW_multiplicativeExpression_in_additiveExpression4852
    
    const_set_lazy(:FOLLOW_unaryExpression_in_multiplicativeExpression4874) { BitSet.new(Array.typed(::Java::Long).new([0x40000002, 0x180000000000])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_multiplicativeExpression4874
    
    const_set_lazy(:FOLLOW_set_in_multiplicativeExpression4878) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_set_in_multiplicativeExpression4878
    
    const_set_lazy(:FOLLOW_unaryExpression_in_multiplicativeExpression4892) { BitSet.new(Array.typed(::Java::Long).new([0x40000002, 0x180000000000])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_multiplicativeExpression4892
    
    const_set_lazy(:FOLLOW_105_in_unaryExpression4918) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_105_in_unaryExpression4918
    
    const_set_lazy(:FOLLOW_unaryExpression_in_unaryExpression4920) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_unaryExpression4920
    
    const_set_lazy(:FOLLOW_106_in_unaryExpression4930) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_106_in_unaryExpression4930
    
    const_set_lazy(:FOLLOW_unaryExpression_in_unaryExpression4932) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_unaryExpression4932
    
    const_set_lazy(:FOLLOW_109_in_unaryExpression4942) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_109_in_unaryExpression4942
    
    const_set_lazy(:FOLLOW_unaryExpression_in_unaryExpression4944) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_unaryExpression4944
    
    const_set_lazy(:FOLLOW_110_in_unaryExpression4954) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_110_in_unaryExpression4954
    
    const_set_lazy(:FOLLOW_unaryExpression_in_unaryExpression4956) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_unaryExpression4956
    
    const_set_lazy(:FOLLOW_unaryExpressionNotPlusMinus_in_unaryExpression4966) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpressionNotPlusMinus_in_unaryExpression4966
    
    const_set_lazy(:FOLLOW_111_in_unaryExpressionNotPlusMinus4985) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_111_in_unaryExpressionNotPlusMinus4985
    
    const_set_lazy(:FOLLOW_unaryExpression_in_unaryExpressionNotPlusMinus4987) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_unaryExpressionNotPlusMinus4987
    
    const_set_lazy(:FOLLOW_112_in_unaryExpressionNotPlusMinus4997) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_112_in_unaryExpressionNotPlusMinus4997
    
    const_set_lazy(:FOLLOW_unaryExpression_in_unaryExpressionNotPlusMinus4999) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_unaryExpressionNotPlusMinus4999
    
    const_set_lazy(:FOLLOW_castExpression_in_unaryExpressionNotPlusMinus5009) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_castExpression_in_unaryExpressionNotPlusMinus5009
    
    const_set_lazy(:FOLLOW_primary_in_unaryExpressionNotPlusMinus5019) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000002, 0x600000000000])) }
    const_attr_reader  :FOLLOW_primary_in_unaryExpressionNotPlusMinus5019
    
    const_set_lazy(:FOLLOW_selector_in_unaryExpressionNotPlusMinus5021) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000002, 0x600000000000])) }
    const_attr_reader  :FOLLOW_selector_in_unaryExpressionNotPlusMinus5021
    
    const_set_lazy(:FOLLOW_set_in_unaryExpressionNotPlusMinus5024) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_set_in_unaryExpressionNotPlusMinus5024
    
    const_set_lazy(:FOLLOW_66_in_castExpression5047) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_66_in_castExpression5047
    
    const_set_lazy(:FOLLOW_primitiveType_in_castExpression5049) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_primitiveType_in_castExpression5049
    
    const_set_lazy(:FOLLOW_67_in_castExpression5051) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_67_in_castExpression5051
    
    const_set_lazy(:FOLLOW_unaryExpression_in_castExpression5053) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_castExpression5053
    
    const_set_lazy(:FOLLOW_66_in_castExpression5062) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_66_in_castExpression5062
    
    const_set_lazy(:FOLLOW_type_in_castExpression5065) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_type_in_castExpression5065
    
    const_set_lazy(:FOLLOW_expression_in_castExpression5069) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_expression_in_castExpression5069
    
    const_set_lazy(:FOLLOW_67_in_castExpression5072) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_67_in_castExpression5072
    
    const_set_lazy(:FOLLOW_unaryExpressionNotPlusMinus_in_castExpression5074) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpressionNotPlusMinus_in_castExpression5074
    
    const_set_lazy(:FOLLOW_parExpression_in_primary5093) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_parExpression_in_primary5093
    
    const_set_lazy(:FOLLOW_69_in_primary5103) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000002, 0x4])) }
    const_attr_reader  :FOLLOW_69_in_primary5103
    
    const_set_lazy(:FOLLOW_29_in_primary5106) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_primary5106
    
    const_set_lazy(:FOLLOW_Identifier_in_primary5108) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000002, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_primary5108
    
    const_set_lazy(:FOLLOW_identifierSuffix_in_primary5112) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_identifierSuffix_in_primary5112
    
    const_set_lazy(:FOLLOW_65_in_primary5123) { BitSet.new(Array.typed(::Java::Long).new([0x20000000, 0x4])) }
    const_attr_reader  :FOLLOW_65_in_primary5123
    
    const_set_lazy(:FOLLOW_superSuffix_in_primary5125) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_superSuffix_in_primary5125
    
    const_set_lazy(:FOLLOW_literal_in_primary5135) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_literal_in_primary5135
    
    const_set_lazy(:FOLLOW_113_in_primary5145) { BitSet.new(Array.typed(::Java::Long).new([-0xfffefffffffff0])) }
    const_attr_reader  :FOLLOW_113_in_primary5145
    
    const_set_lazy(:FOLLOW_creator_in_primary5147) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_creator_in_primary5147
    
    const_set_lazy(:FOLLOW_Identifier_in_primary5157) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000002, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_primary5157
    
    const_set_lazy(:FOLLOW_29_in_primary5160) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_primary5160
    
    const_set_lazy(:FOLLOW_Identifier_in_primary5162) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000002, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_primary5162
    
    const_set_lazy(:FOLLOW_identifierSuffix_in_primary5166) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_identifierSuffix_in_primary5166
    
    const_set_lazy(:FOLLOW_primitiveType_in_primary5177) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000000])) }
    const_attr_reader  :FOLLOW_primitiveType_in_primary5177
    
    const_set_lazy(:FOLLOW_48_in_primary5180) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_primary5180
    
    const_set_lazy(:FOLLOW_49_in_primary5182) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000000])) }
    const_attr_reader  :FOLLOW_49_in_primary5182
    
    const_set_lazy(:FOLLOW_29_in_primary5186) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000])) }
    const_attr_reader  :FOLLOW_29_in_primary5186
    
    const_set_lazy(:FOLLOW_37_in_primary5188) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_37_in_primary5188
    
    const_set_lazy(:FOLLOW_47_in_primary5198) { BitSet.new(Array.typed(::Java::Long).new([0x20000000])) }
    const_attr_reader  :FOLLOW_47_in_primary5198
    
    const_set_lazy(:FOLLOW_29_in_primary5200) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000])) }
    const_attr_reader  :FOLLOW_29_in_primary5200
    
    const_set_lazy(:FOLLOW_37_in_primary5202) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_37_in_primary5202
    
    const_set_lazy(:FOLLOW_48_in_identifierSuffix5222) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_identifierSuffix5222
    
    const_set_lazy(:FOLLOW_49_in_identifierSuffix5224) { BitSet.new(Array.typed(::Java::Long).new([0x1000020000000])) }
    const_attr_reader  :FOLLOW_49_in_identifierSuffix5224
    
    const_set_lazy(:FOLLOW_29_in_identifierSuffix5228) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000])) }
    const_attr_reader  :FOLLOW_29_in_identifierSuffix5228
    
    const_set_lazy(:FOLLOW_37_in_identifierSuffix5230) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_37_in_identifierSuffix5230
    
    const_set_lazy(:FOLLOW_48_in_identifierSuffix5241) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_48_in_identifierSuffix5241
    
    const_set_lazy(:FOLLOW_expression_in_identifierSuffix5243) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_expression_in_identifierSuffix5243
    
    const_set_lazy(:FOLLOW_49_in_identifierSuffix5245) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_identifierSuffix5245
    
    const_set_lazy(:FOLLOW_arguments_in_identifierSuffix5258) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arguments_in_identifierSuffix5258
    
    const_set_lazy(:FOLLOW_29_in_identifierSuffix5268) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000])) }
    const_attr_reader  :FOLLOW_29_in_identifierSuffix5268
    
    const_set_lazy(:FOLLOW_37_in_identifierSuffix5270) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_37_in_identifierSuffix5270
    
    const_set_lazy(:FOLLOW_29_in_identifierSuffix5280) { BitSet.new(Array.typed(::Java::Long).new([0x10000000000])) }
    const_attr_reader  :FOLLOW_29_in_identifierSuffix5280
    
    const_set_lazy(:FOLLOW_explicitGenericInvocation_in_identifierSuffix5282) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_explicitGenericInvocation_in_identifierSuffix5282
    
    const_set_lazy(:FOLLOW_29_in_identifierSuffix5292) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x20])) }
    const_attr_reader  :FOLLOW_29_in_identifierSuffix5292
    
    const_set_lazy(:FOLLOW_69_in_identifierSuffix5294) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_69_in_identifierSuffix5294
    
    const_set_lazy(:FOLLOW_29_in_identifierSuffix5304) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x2])) }
    const_attr_reader  :FOLLOW_29_in_identifierSuffix5304
    
    const_set_lazy(:FOLLOW_65_in_identifierSuffix5306) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_65_in_identifierSuffix5306
    
    const_set_lazy(:FOLLOW_arguments_in_identifierSuffix5308) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arguments_in_identifierSuffix5308
    
    const_set_lazy(:FOLLOW_29_in_identifierSuffix5318) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x2000000000000])) }
    const_attr_reader  :FOLLOW_29_in_identifierSuffix5318
    
    const_set_lazy(:FOLLOW_113_in_identifierSuffix5320) { BitSet.new(Array.typed(::Java::Long).new([0x10000000010])) }
    const_attr_reader  :FOLLOW_113_in_identifierSuffix5320
    
    const_set_lazy(:FOLLOW_innerCreator_in_identifierSuffix5322) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_innerCreator_in_identifierSuffix5322
    
    const_set_lazy(:FOLLOW_nonWildcardTypeArguments_in_creator5341) { BitSet.new(Array.typed(::Java::Long).new([-0xfffefffffffff0])) }
    const_attr_reader  :FOLLOW_nonWildcardTypeArguments_in_creator5341
    
    const_set_lazy(:FOLLOW_createdName_in_creator5343) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_createdName_in_creator5343
    
    const_set_lazy(:FOLLOW_classCreatorRest_in_creator5345) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classCreatorRest_in_creator5345
    
    const_set_lazy(:FOLLOW_createdName_in_creator5355) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000000, 0x4])) }
    const_attr_reader  :FOLLOW_createdName_in_creator5355
    
    const_set_lazy(:FOLLOW_arrayCreatorRest_in_creator5358) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arrayCreatorRest_in_creator5358
    
    const_set_lazy(:FOLLOW_classCreatorRest_in_creator5362) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classCreatorRest_in_creator5362
    
    const_set_lazy(:FOLLOW_classOrInterfaceType_in_createdName5382) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classOrInterfaceType_in_createdName5382
    
    const_set_lazy(:FOLLOW_primitiveType_in_createdName5392) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_primitiveType_in_createdName5392
    
    const_set_lazy(:FOLLOW_nonWildcardTypeArguments_in_innerCreator5415) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_nonWildcardTypeArguments_in_innerCreator5415
    
    const_set_lazy(:FOLLOW_Identifier_in_innerCreator5418) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_innerCreator5418
    
    const_set_lazy(:FOLLOW_classCreatorRest_in_innerCreator5420) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classCreatorRest_in_innerCreator5420
    
    const_set_lazy(:FOLLOW_48_in_arrayCreatorRest5439) { BitSet.new(Array.typed(::Java::Long).new([-0xfd6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_48_in_arrayCreatorRest5439
    
    const_set_lazy(:FOLLOW_49_in_arrayCreatorRest5453) { BitSet.new(Array.typed(::Java::Long).new([0x1100000000000])) }
    const_attr_reader  :FOLLOW_49_in_arrayCreatorRest5453
    
    const_set_lazy(:FOLLOW_48_in_arrayCreatorRest5456) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_arrayCreatorRest5456
    
    const_set_lazy(:FOLLOW_49_in_arrayCreatorRest5458) { BitSet.new(Array.typed(::Java::Long).new([0x1100000000000])) }
    const_attr_reader  :FOLLOW_49_in_arrayCreatorRest5458
    
    const_set_lazy(:FOLLOW_arrayInitializer_in_arrayCreatorRest5462) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arrayInitializer_in_arrayCreatorRest5462
    
    const_set_lazy(:FOLLOW_expression_in_arrayCreatorRest5476) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_expression_in_arrayCreatorRest5476
    
    const_set_lazy(:FOLLOW_49_in_arrayCreatorRest5478) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_arrayCreatorRest5478
    
    const_set_lazy(:FOLLOW_48_in_arrayCreatorRest5481) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_48_in_arrayCreatorRest5481
    
    const_set_lazy(:FOLLOW_expression_in_arrayCreatorRest5483) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_expression_in_arrayCreatorRest5483
    
    const_set_lazy(:FOLLOW_49_in_arrayCreatorRest5485) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_arrayCreatorRest5485
    
    const_set_lazy(:FOLLOW_48_in_arrayCreatorRest5490) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_48_in_arrayCreatorRest5490
    
    const_set_lazy(:FOLLOW_49_in_arrayCreatorRest5492) { BitSet.new(Array.typed(::Java::Long).new([0x1000000000002])) }
    const_attr_reader  :FOLLOW_49_in_arrayCreatorRest5492
    
    const_set_lazy(:FOLLOW_arguments_in_classCreatorRest5523) { BitSet.new(Array.typed(::Java::Long).new([0x11c000000002])) }
    const_attr_reader  :FOLLOW_arguments_in_classCreatorRest5523
    
    const_set_lazy(:FOLLOW_classBody_in_classCreatorRest5525) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classBody_in_classCreatorRest5525
    
    const_set_lazy(:FOLLOW_nonWildcardTypeArguments_in_explicitGenericInvocation5549) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_nonWildcardTypeArguments_in_explicitGenericInvocation5549
    
    const_set_lazy(:FOLLOW_Identifier_in_explicitGenericInvocation5551) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_explicitGenericInvocation5551
    
    const_set_lazy(:FOLLOW_arguments_in_explicitGenericInvocation5553) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arguments_in_explicitGenericInvocation5553
    
    const_set_lazy(:FOLLOW_40_in_nonWildcardTypeArguments5576) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_40_in_nonWildcardTypeArguments5576
    
    const_set_lazy(:FOLLOW_typeList_in_nonWildcardTypeArguments5578) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_typeList_in_nonWildcardTypeArguments5578
    
    const_set_lazy(:FOLLOW_42_in_nonWildcardTypeArguments5580) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_nonWildcardTypeArguments5580
    
    const_set_lazy(:FOLLOW_29_in_selector5603) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_selector5603
    
    const_set_lazy(:FOLLOW_Identifier_in_selector5605) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_selector5605
    
    const_set_lazy(:FOLLOW_arguments_in_selector5607) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arguments_in_selector5607
    
    const_set_lazy(:FOLLOW_29_in_selector5618) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x20])) }
    const_attr_reader  :FOLLOW_29_in_selector5618
    
    const_set_lazy(:FOLLOW_69_in_selector5620) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_69_in_selector5620
    
    const_set_lazy(:FOLLOW_29_in_selector5630) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x2])) }
    const_attr_reader  :FOLLOW_29_in_selector5630
    
    const_set_lazy(:FOLLOW_65_in_selector5632) { BitSet.new(Array.typed(::Java::Long).new([0x20000000, 0x4])) }
    const_attr_reader  :FOLLOW_65_in_selector5632
    
    const_set_lazy(:FOLLOW_superSuffix_in_selector5634) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_superSuffix_in_selector5634
    
    const_set_lazy(:FOLLOW_29_in_selector5644) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x2000000000000])) }
    const_attr_reader  :FOLLOW_29_in_selector5644
    
    const_set_lazy(:FOLLOW_113_in_selector5646) { BitSet.new(Array.typed(::Java::Long).new([0x10000000010])) }
    const_attr_reader  :FOLLOW_113_in_selector5646
    
    const_set_lazy(:FOLLOW_innerCreator_in_selector5648) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_innerCreator_in_selector5648
    
    const_set_lazy(:FOLLOW_48_in_selector5658) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_48_in_selector5658
    
    const_set_lazy(:FOLLOW_expression_in_selector5660) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_expression_in_selector5660
    
    const_set_lazy(:FOLLOW_49_in_selector5662) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_49_in_selector5662
    
    const_set_lazy(:FOLLOW_arguments_in_superSuffix5685) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arguments_in_superSuffix5685
    
    const_set_lazy(:FOLLOW_29_in_superSuffix5695) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_superSuffix5695
    
    const_set_lazy(:FOLLOW_Identifier_in_superSuffix5697) { BitSet.new(Array.typed(::Java::Long).new([0x2, 0x4])) }
    const_attr_reader  :FOLLOW_Identifier_in_superSuffix5697
    
    const_set_lazy(:FOLLOW_arguments_in_superSuffix5699) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_arguments_in_superSuffix5699
    
    const_set_lazy(:FOLLOW_66_in_arguments5719) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ff7fffff030, 0x3e600000003ee])) }
    const_attr_reader  :FOLLOW_66_in_arguments5719
    
    const_set_lazy(:FOLLOW_expressionList_in_arguments5721) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_expressionList_in_arguments5721
    
    const_set_lazy(:FOLLOW_67_in_arguments5724) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_67_in_arguments5724
    
    const_set_lazy(:FOLLOW_annotations_in_synpred5_Java44) { BitSet.new(Array.typed(::Java::Long).new([0x403f92000020, 0x200])) }
    const_attr_reader  :FOLLOW_annotations_in_synpred5_Java44
    
    const_set_lazy(:FOLLOW_packageDeclaration_in_synpred5_Java58) { BitSet.new(Array.typed(::Java::Long).new([0x403f9e000022, 0x200])) }
    const_attr_reader  :FOLLOW_packageDeclaration_in_synpred5_Java58
    
    const_set_lazy(:FOLLOW_importDeclaration_in_synpred5_Java60) { BitSet.new(Array.typed(::Java::Long).new([0x403f9e000022, 0x200])) }
    const_attr_reader  :FOLLOW_importDeclaration_in_synpred5_Java60
    
    const_set_lazy(:FOLLOW_typeDeclaration_in_synpred5_Java63) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_typeDeclaration_in_synpred5_Java63
    
    const_set_lazy(:FOLLOW_classOrInterfaceDeclaration_in_synpred5_Java78) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_classOrInterfaceDeclaration_in_synpred5_Java78
    
    const_set_lazy(:FOLLOW_typeDeclaration_in_synpred5_Java80) { BitSet.new(Array.typed(::Java::Long).new([0x403f96000022, 0x200])) }
    const_attr_reader  :FOLLOW_typeDeclaration_in_synpred5_Java80
    
    const_set_lazy(:FOLLOW_explicitConstructorInvocation_in_synpred113_Java2455) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_explicitConstructorInvocation_in_synpred113_Java2455
    
    const_set_lazy(:FOLLOW_nonWildcardTypeArguments_in_synpred117_Java2480) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x22])) }
    const_attr_reader  :FOLLOW_nonWildcardTypeArguments_in_synpred117_Java2480
    
    const_set_lazy(:FOLLOW_set_in_synpred117_Java2483) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x4])) }
    const_attr_reader  :FOLLOW_set_in_synpred117_Java2483
    
    const_set_lazy(:FOLLOW_arguments_in_synpred117_Java2491) { BitSet.new(Array.typed(::Java::Long).new([0x4000000])) }
    const_attr_reader  :FOLLOW_arguments_in_synpred117_Java2491
    
    const_set_lazy(:FOLLOW_26_in_synpred117_Java2493) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_26_in_synpred117_Java2493
    
    const_set_lazy(:FOLLOW_annotation_in_synpred128_Java2704) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_annotation_in_synpred128_Java2704
    
    const_set_lazy(:FOLLOW_localVariableDeclarationStatement_in_synpred151_Java3231) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_localVariableDeclarationStatement_in_synpred151_Java3231
    
    const_set_lazy(:FOLLOW_classOrInterfaceDeclaration_in_synpred152_Java3241) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_classOrInterfaceDeclaration_in_synpred152_Java3241
    
    const_set_lazy(:FOLLOW_77_in_synpred157_Java3386) { BitSet.new(Array.typed(::Java::Long).new([-0xdf2fc069ffe010, 0x3e60000fbd3e6])) }
    const_attr_reader  :FOLLOW_77_in_synpred157_Java3386
    
    const_set_lazy(:FOLLOW_statement_in_synpred157_Java3388) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_statement_in_synpred157_Java3388
    
    const_set_lazy(:FOLLOW_catches_in_synpred162_Java3464) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x40000])) }
    const_attr_reader  :FOLLOW_catches_in_synpred162_Java3464
    
    const_set_lazy(:FOLLOW_82_in_synpred162_Java3466) { BitSet.new(Array.typed(::Java::Long).new([0x100010000000])) }
    const_attr_reader  :FOLLOW_82_in_synpred162_Java3466
    
    const_set_lazy(:FOLLOW_block_in_synpred162_Java3468) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_block_in_synpred162_Java3468
    
    const_set_lazy(:FOLLOW_catches_in_synpred163_Java3480) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_catches_in_synpred163_Java3480
    
    const_set_lazy(:FOLLOW_switchLabel_in_synpred178_Java3771) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_switchLabel_in_synpred178_Java3771
    
    const_set_lazy(:FOLLOW_89_in_synpred180_Java3798) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_89_in_synpred180_Java3798
    
    const_set_lazy(:FOLLOW_constantExpression_in_synpred180_Java3800) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_constantExpression_in_synpred180_Java3800
    
    const_set_lazy(:FOLLOW_75_in_synpred180_Java3802) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_75_in_synpred180_Java3802
    
    const_set_lazy(:FOLLOW_89_in_synpred181_Java3812) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_89_in_synpred181_Java3812
    
    const_set_lazy(:FOLLOW_enumConstantName_in_synpred181_Java3814) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x800])) }
    const_attr_reader  :FOLLOW_enumConstantName_in_synpred181_Java3814
    
    const_set_lazy(:FOLLOW_75_in_synpred181_Java3816) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_75_in_synpred181_Java3816
    
    const_set_lazy(:FOLLOW_enhancedForControl_in_synpred182_Java3859) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_enhancedForControl_in_synpred182_Java3859
    
    const_set_lazy(:FOLLOW_localVariableDeclaration_in_synpred186_Java3899) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_localVariableDeclaration_in_synpred186_Java3899
    
    const_set_lazy(:FOLLOW_assignmentOperator_in_synpred188_Java4082) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_assignmentOperator_in_synpred188_Java4082
    
    const_set_lazy(:FOLLOW_expression_in_synpred188_Java4084) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_expression_in_synpred188_Java4084
    
    const_set_lazy(:FOLLOW_40_in_synpred198_Java4200) { BitSet.new(Array.typed(::Java::Long).new([0x10000000000])) }
    const_attr_reader  :FOLLOW_40_in_synpred198_Java4200
    
    const_set_lazy(:FOLLOW_40_in_synpred198_Java4202) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_40_in_synpred198_Java4202
    
    const_set_lazy(:FOLLOW_51_in_synpred198_Java4204) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_synpred198_Java4204
    
    const_set_lazy(:FOLLOW_42_in_synpred199_Java4240) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred199_Java4240
    
    const_set_lazy(:FOLLOW_42_in_synpred199_Java4242) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred199_Java4242
    
    const_set_lazy(:FOLLOW_42_in_synpred199_Java4244) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred199_Java4244
    
    const_set_lazy(:FOLLOW_51_in_synpred199_Java4246) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_synpred199_Java4246
    
    const_set_lazy(:FOLLOW_42_in_synpred200_Java4285) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred200_Java4285
    
    const_set_lazy(:FOLLOW_42_in_synpred200_Java4287) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred200_Java4287
    
    const_set_lazy(:FOLLOW_51_in_synpred200_Java4289) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_synpred200_Java4289
    
    const_set_lazy(:FOLLOW_40_in_synpred211_Java4597) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_40_in_synpred211_Java4597
    
    const_set_lazy(:FOLLOW_51_in_synpred211_Java4599) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_synpred211_Java4599
    
    const_set_lazy(:FOLLOW_42_in_synpred212_Java4631) { BitSet.new(Array.typed(::Java::Long).new([0x8000000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred212_Java4631
    
    const_set_lazy(:FOLLOW_51_in_synpred212_Java4633) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_51_in_synpred212_Java4633
    
    const_set_lazy(:FOLLOW_40_in_synpred215_Java4724) { BitSet.new(Array.typed(::Java::Long).new([0x10000000000])) }
    const_attr_reader  :FOLLOW_40_in_synpred215_Java4724
    
    const_set_lazy(:FOLLOW_40_in_synpred215_Java4726) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_40_in_synpred215_Java4726
    
    const_set_lazy(:FOLLOW_42_in_synpred216_Java4758) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred216_Java4758
    
    const_set_lazy(:FOLLOW_42_in_synpred216_Java4760) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred216_Java4760
    
    const_set_lazy(:FOLLOW_42_in_synpred216_Java4762) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_synpred216_Java4762
    
    const_set_lazy(:FOLLOW_42_in_synpred217_Java4798) { BitSet.new(Array.typed(::Java::Long).new([0x40000000000])) }
    const_attr_reader  :FOLLOW_42_in_synpred217_Java4798
    
    const_set_lazy(:FOLLOW_42_in_synpred217_Java4800) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_42_in_synpred217_Java4800
    
    const_set_lazy(:FOLLOW_castExpression_in_synpred229_Java5009) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_castExpression_in_synpred229_Java5009
    
    const_set_lazy(:FOLLOW_66_in_synpred233_Java5047) { BitSet.new(Array.typed(::Java::Long).new([-0xfffffffffffff0])) }
    const_attr_reader  :FOLLOW_66_in_synpred233_Java5047
    
    const_set_lazy(:FOLLOW_primitiveType_in_synpred233_Java5049) { BitSet.new(Array.typed(::Java::Long).new([0x0, 0x8])) }
    const_attr_reader  :FOLLOW_primitiveType_in_synpred233_Java5049
    
    const_set_lazy(:FOLLOW_67_in_synpred233_Java5051) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_67_in_synpred233_Java5051
    
    const_set_lazy(:FOLLOW_unaryExpression_in_synpred233_Java5053) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_unaryExpression_in_synpred233_Java5053
    
    const_set_lazy(:FOLLOW_type_in_synpred234_Java5065) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_type_in_synpred234_Java5065
    
    const_set_lazy(:FOLLOW_29_in_synpred236_Java5106) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_synpred236_Java5106
    
    const_set_lazy(:FOLLOW_Identifier_in_synpred236_Java5108) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_Identifier_in_synpred236_Java5108
    
    const_set_lazy(:FOLLOW_identifierSuffix_in_synpred237_Java5112) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_identifierSuffix_in_synpred237_Java5112
    
    const_set_lazy(:FOLLOW_29_in_synpred242_Java5160) { BitSet.new(Array.typed(::Java::Long).new([0x10])) }
    const_attr_reader  :FOLLOW_29_in_synpred242_Java5160
    
    const_set_lazy(:FOLLOW_Identifier_in_synpred242_Java5162) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_Identifier_in_synpred242_Java5162
    
    const_set_lazy(:FOLLOW_identifierSuffix_in_synpred243_Java5166) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_identifierSuffix_in_synpred243_Java5166
    
    const_set_lazy(:FOLLOW_48_in_synpred249_Java5241) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_48_in_synpred249_Java5241
    
    const_set_lazy(:FOLLOW_expression_in_synpred249_Java5243) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_expression_in_synpred249_Java5243
    
    const_set_lazy(:FOLLOW_49_in_synpred249_Java5245) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_49_in_synpred249_Java5245
    
    const_set_lazy(:FOLLOW_48_in_synpred262_Java5481) { BitSet.new(Array.typed(::Java::Long).new([-0xff6ffffffff030, 0x3e600000001e6])) }
    const_attr_reader  :FOLLOW_48_in_synpred262_Java5481
    
    const_set_lazy(:FOLLOW_expression_in_synpred262_Java5483) { BitSet.new(Array.typed(::Java::Long).new([0x2000000000000])) }
    const_attr_reader  :FOLLOW_expression_in_synpred262_Java5483
    
    const_set_lazy(:FOLLOW_49_in_synpred262_Java5485) { BitSet.new(Array.typed(::Java::Long).new([0x2])) }
    const_attr_reader  :FOLLOW_49_in_synpred262_Java5485
  }
  
  private
  alias_method :initialize__java_parser, :initialize
end

