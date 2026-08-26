require "slang"

if ARGV[0]? == "--extract"
  puts Slang.extract_strings_from_file(ARGV[1])
elsif ARGV[0]? == "--i18n"
  puts Slang.process_file_i18n(ARGV[1], ARGV[2], ARGV[3], ARGV[4])
else
  puts Slang.process_file(ARGV[0], ARGV[1])
end
