require "spec"
require "../src/slang"

macro render_file(filename)
  String.build do |__str__|
    \{{ run("./support/process_file", {{filename}}, "__str__") }}
  end
end

macro render(slang)
  String.build do |__str__|
    \{{ run("./support/process", {{slang}}, "__str__") }}
  end
end