# frozen_string_literal: true

require "./refactor_base"

def camel_case(string)
  string = string.sub(/^[a-z\d]*/, &:capitalize)
  string.gsub!(/(?:_|(::))([a-z\d]*)/) do
    "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
  end
  string
end

def test_directory(directory)
  directory = directory.split("/").compact.join("/")
  Dir["./#{directory}/**/*.rb"].sort.each do |file|
    test_file(file)
  end
end

def test_file(file)
  file = "./#{file}" unless file.match?(%r{^\./})
  require file

  module_directories = file.split(%r{[/.]})[1..-2]
  module_names = camel_case(module_directories.join("::"))
  test_class = Object.const_get("#{module_names}::Tests")

  test_class.new.call
end

limit_to = ARGV.shift

if limit_to.nil?
  %w[first_set_of_refactorings].each do |directory|
    test_directory(directory)
  end
elsif limit_to.split("/").last.include?(".")
  test_file(limit_to)
else
  test_directory(limit_to)
end
