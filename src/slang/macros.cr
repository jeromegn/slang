module Slang

  macro embed(filename, io_name)
    \{{ run("slang/slang/process", {{filename}}, {{io_name}}) }}
  end

  # Use in a class
  macro file(filename)
    def to_s(__slang__)
      embed_slang {{filename}}, "__slang__"
    end
  end

end