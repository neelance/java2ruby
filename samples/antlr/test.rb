require "rjava"
import_classes "lib/antlr"

#if is_jruby?
#  class << Org::Antlr::Runtime::BitSet
#    alias_method :new_orig, :new
#    def new(list)
#      new_orig list.map { |entry| Java::JavaLang::Integer.new(entry) }
#    end
#  end
#end

require File.dirname(__FILE__) + "/TestLexer"
require File.dirname(__FILE__) + "/TestParser"

class Test
  include Org::Antlr::Runtime
  include Org::Antlr::Runtime::Debug
  
  lexer = TestLexer.new ANTLRStringStream.new("ABCBCBBBCCC")
  tokens = CommonTokenStream.new
  tokens.set_token_source lexer
  builder = ParseTreeBuilder.new "Test"
  parser = TestParser.new tokens, builder
  parser.root
  puts builder.get_tree.to_string_tree
end
