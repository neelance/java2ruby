file_dir = File.absolute_path File.dirname(__FILE__)

$:.unshift file_dir
$:.unshift "#{file_dir}/../jre4ruby"
$:.unshift "#{file_dir}/../antlr4ruby"

module Java2Ruby
end

require "#{file_dir}/converter/converter"

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
