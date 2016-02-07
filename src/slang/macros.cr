require "tempfile"
require "ecr/macros"

macro embed_slang(filename, io_name)
  \{{ run("../src/process", {{filename}}, {{io_name}}) }}
end

# macro slang_file(filename)
#   def to_s(__io__)
#     embed_slang {{filename}}, "__io__"
#   end
# end