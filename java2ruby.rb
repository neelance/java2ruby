file_dir = File.absolute_path File.dirname(__FILE__)

$:.unshift file_dir
$:.unshift "#{file_dir}/../jre4ruby"
$:.unshift "#{file_dir}/../antlr4ruby"

module Java2Ruby
end

require "ruby_modifications"
require "ruby_naming"
require "#{file_dir}/converter/converter"

show_log = $*.delete "--show-log"
ruby_prof = $*.delete "--ruby-prof"
perftools = $*.delete "--perftools"
converter = Java2Ruby::Converter.new $*.first

if ruby_prof
  require "ruby-prof"
  RubyProf.start
end

if perftools
  require "perftools"
  PerfTools::CpuProfiler.start "perftools_profile"
end

if show_log
  converter.log = {}
end

exception = nil
begin
  converter.convert
rescue Exception => e
  exception = e
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

if show_log
  require "tempfile"
  file = Tempfile.new ["log", ".yaml"]
  
  converter.log.each do |header, content|
    file.puts "--- #{header.upcase} ---"
    file.puts content
    file.puts
  end
  
  file.close
  system "geany #{file.path}"
end

raise exception if exception