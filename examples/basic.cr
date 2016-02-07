require "../src/slang"

some_var = "hello"
strings = ["ah", "oh"]

res = String.build do |str|
  embed_slang("#{__DIR__}/./basic.slang", "str")
end

# res = Slang::Parser.new(File.read("#{__DIR__}/./basic.slang")).parse

puts res