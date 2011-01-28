module RubyNaming
  extend self
  
  RUBY_KEYWORDS = %w{alias allocate and begin break case class def defined do else elsif end ensure false for if in initialize module next nil not or redo rescue retry return self super then true undef unless until when while yield}

  def lower_name(name, escape_first = false)
    name = "_#{name}" if escape_first and name[0] == ?_
    new_word = escape_first
    name.gsub(/./) { |char|
      case char
      when /[a-z]/
        new_word = true
        char
      when /[A-Z]/
        if new_word
          new_word = false
          escape_first = false
          "_" + char.downcase
        else
          char.downcase
        end
      else
        new_word = false unless escape_first
        char
      end
    }
  end
  
  def ruby_method_name(name)
    case name
    when :constructor
      "initialize"
    when "toString"
      "to_s"
    when "equals"
      "=="
    else
      ruby_name = lower_name name, true
      ruby_name << "_" if RUBY_KEYWORDS.include?(ruby_name)
      ruby_name
    end
  end
  
  def ruby_constant_name(name)
    return "Exception" if name == :ruby_exception
    if name.to_s[0..0] =~ /[a-z]/
      if name.to_s[1..1] =~ /[A-Z]/
        name = name.to_s[0..0].upcase + "_" + name.to_s[1..-1]
      else
        name = name.to_s[0..0].upcase + name.to_s[1..-1]
      end
    end
    name = "Java#{name}" if %w{Comparable Date Error Exception File Integer List Queue Set Thread ThreadGroup Throwable}.include? name
    name << "_" if %w{BEGIN END}.include? name
    name
  end
  
  def ruby_package_name(name)
    ruby_constant_name name
  end
  
  def ruby_class_name(names)
    names.map do |name|
      ruby_constant_name name
    end
  end
end