require "../src/slang"

some_var = "hello"
strings = ["ah", "oh"]

# res = String.build do |__slang__|
#   embed_slang("basic.slang", "__slang__")
# end

res = Slang.process_file("#{__DIR__}/../spec/fixtures/basic.slang")

puts res
