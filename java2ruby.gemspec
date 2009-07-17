--- !ruby/object:Gem::Specification 
name: java2ruby
version: !ruby/object:Gem::Version 
  version: 1.0.0
platform: ruby
authors: []

autorequire: 
bindir: bin
cert_chain: []

date: 2009-07-17 00:00:00 +02:00
default_executable: 
dependencies: []

description: 
email: 
executables: []

extensions: []

extra_rdoc_files: []

files: 
- java2ruby.rb
- rjava.rb
- LICENSE
- converter/JavaParser.java
- converter/tools.rb
- converter/JavaParser.rb
- converter/java_modules.rb
- converter/java_types.rb
- converter/java_methods.rb
- converter/Java.tokens
- converter/converter.rb
- converter/Java.g
- converter/JavaLexer.java
- converter/JavaLexer.rb
- converter/matchers/core_matchers.rb
- converter/matchers/statement_matchers.rb
- converter/matchers/expression_matchers.rb
- converter/matchers/class_matchers.rb
- converter/matchers/variable_matchers.rb
- rjava/java_base.rb
- rjava/jni/jni_structs_i386-mingw32.rb
- rjava/jni/jni_tools_i686-linux.so
- rjava/jni/jni.rb
- rjava/jni/jni_structs_x86_64-linux.rb
- rjava/jni/jni_structs_i686-linux.rb
- rjava/jni/jni_tools_x86_64-linux.so
- rjava/jni/jni.h
- rjava/jni/jni_structs.rb.ffi
- rjava/jni/jni_tools_i686-darwin9.so
- rjava/jni/jni_preprocessed.h
- rjava/jni/jni_structs_i686-darwin9.rb
- rjava/jni/jni_md.h
- rjava/jni/jni_tools.c
- rjava/jni/jni_tools_i386-mingw32.so
- rjava/lazy_constants.rb
- rjava/signature_matching.rb
- rjava/local_class.rb
- rjava/ruby_modifications.rb
- rjava/extended_require.rb
- rjava/class_module.rb
- rjava/char_array.rb
- rjava/class_loading.rb
has_rdoc: true
homepage: http://github.com/neelance/java2ruby/
post_install_message: 
rdoc_options: 
- --charset=UTF-8
require_paths: 
- .
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: 
rubygems_version: 1.3.1
signing_key: 
specification_version: 2
summary: A source code converter from Java to Ruby, making it possible to use Java libraries with MRI.
test_files: []

