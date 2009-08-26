$:.unshift File.dirname(__FILE__)
$:.unshift "#{File.dirname(__FILE__)}/../jre4ruby"
$:.unshift "#{File.dirname(__FILE__)}/../antlr4ruby"

require "#{File.dirname(__FILE__)}/converter/converter"

show_parse_tree = $*.delete "--parse-tree"
ruby_prof = $*.delete "--ruby-prof"
perftools = $*.delete "--perftools"
stdout = $*.delete "--stdout"
converter = Java2Ruby::Converter.new $*.first

if ruby_prof
  require "ruby-prof"
  RubyProf.start
end
if perftools
  require "perftools"
  PerfTools::CpuProfiler.start "perftools_profile"
end

puts converter.parse_tree.to_string_tree if show_parse_tree
if stdout
  puts converter.output
else
  converter.convert
end

if ruby_prof
  result = RubyProf.stop
  printer = RubyProf::GraphHtmlPrinter.new result
  File.open("ruby_prof_profile.html", "w") do |file|
    printer.print file
  end
end
if perftools
  PerfTools::CpuProfiler.stop
end
