require "spec"
require "../src/slang"

macro render_slang(filename)
  String.build do |__str__|
    \{{ run("./support/process", "spec/fixtures/{{filename.id}}.slang", "__str__") }}
  end
end