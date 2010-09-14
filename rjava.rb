$rjava_verbose = ARGV.delete("--rjava-verbose")

require "rjava/rjava_module"
require "rjava/ruby_modifications"
require "rjava/lazy_constants"
require "rjava/signature_matching"
require "rjava/class_module"
require "rjava/local_class"
require "rjava/extended_require"
require "rjava/class_loading"

require "jre4ruby" # TODO should not be here

require "rjava/java_base"
require "rjava/char_array"
require "rjava/jni/jni"
require "rjava/jni/jni_structures"
require "rjava/jni/#{RJava::PLATFORM}/jni_structs"
