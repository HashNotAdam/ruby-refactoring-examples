# frozen_string_literal: true

require "./refactor_base"

def camel_case(string)
  string = string.sub(/^[a-z\d]*/, &:capitalize)
  string.gsub!(/(?:_|(::))([a-z\d]*)/) do
    "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
  end
  string
end

%w[first_set_of_refactorings].each do |directory|
  Dir["./#{directory}/**/*.rb"].sort.each do |file|
    require file

    module_directories = file.split(%r{[/.]})[1..-2]
    module_names = camel_case(module_directories.join("::"))
    test_class = Object.const_get("#{module_names}::Tests")

    test_class.call
  end
end
