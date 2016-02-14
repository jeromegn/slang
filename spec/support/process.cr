require "../../src/slang"
if File.exists?(ARGV[0])
  puts Slang.process_file(ARGV[0], ARGV[1])
else
  puts Slang.process_string(ARGV[0], "dummy.slang", ARGV[1])
end