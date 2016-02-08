macro embed_slang(filename, io_name)
  \{{ run("slang/process", {{filename}}, {{io_name}}) }}
end

# Use in a class
macro slang_file(filename)
  def to_s(__slang__)
    embed_slang {{filename}}, "__slang__"
  end
end