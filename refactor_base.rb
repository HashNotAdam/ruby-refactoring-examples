# frozen_string_literal: true

class RefactorBase
  def initialize
    puts "\n"
    puts "##"
    puts "# #{self.class.name}"
    puts "##"
    puts "\n"
  end

  def assert(boolean_statement)
    return if boolean_statement

    puts "##"
    puts "# NOTICE: call to `#{called_method}` without appropriate parameters"
    puts "##"
  end

  private

  def calling_method
    caller_method(2)
  end

  def called_method
    caller_method(1)
  end

  def caller_method(index)
    caller[index + 1].split(" ").last.gsub(/[^a-z_]/, "")
  end
end
