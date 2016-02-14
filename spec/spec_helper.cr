require "spec"
require "../src/slang"

macro render(filename)
  String.build do |__str__|
    \{{ run("./support/process", {{filename}}, "__str__") }}
  end
end

# macro render(slang)
#   puts "render macro"
#   puts {{slang}}
#   String.build do |__str__|
#     \{{ puts Slang.process_string({{slang}}, "dummy.slang", "__str__") }}
#   end
# end