require "./slang"
puts ECR.process_string(Slang::Parser.new(File.read(ARGV[0])).parse, ARGV[0], ARGV[1])