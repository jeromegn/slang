require "html"
require "./slang/version"
require "./slang/node"
require "./slang/document"
require "./slang/lexer"
require "./slang/parser"
require "./slang/token"
require "./slang/macros"
require "./slang/codegen"
require "./slang/extractor"
require "./slang/po"

# require "./slang/*"

module Slang
  extend self
  DEFAULT_BUFFER_NAME = "__slang__"

  def process_string(slang, filename = "dummy.slang", buffer_name = DEFAULT_BUFFER_NAME) : String
    document = Slang::Parser.new(slang).parse
    codegen = Codegen.new(buffer_name)
    document.accept(codegen)
    codegen.to_s
  end

  def process_file(filename, buffer_name = DEFAULT_BUFFER_NAME)
    raise "Slang template: #{filename} doesn't exist." unless File.exists?(filename)
    process_string(File.read(filename), filename, buffer_name)
  end

  # Every `<lang>.po` file in `locales_dir` becomes one `when` branch, each a
  # full codegen pass with that locale's strings resolved and folded into the
  # static buffer — no t(), no runtime hash lookup, one string compare total.
  # The source-language text (untouched) is the `else` fallback, matching
  # gettext's own rule: a missing translation renders the msgid itself.
  def process_string_i18n(slang, filename = "dummy.slang", buffer_name = DEFAULT_BUFFER_NAME, locales_dir = "locales", lang_expr = "lang") : String
    locales = Dir.exists?(locales_dir) ? Dir.glob(File.join(locales_dir, "*.po")).map { |path| File.basename(path, ".po") }.sort! : [] of String
    return process_string(slang, filename, buffer_name) if locales.empty?

    # Each pass parses `slang` fresh: Codegen (via Nodes::Element#generate_class_names)
    # mutates the AST it visits, so the same parsed Document can't be visited twice.
    String.build do |io|
      io << "case " << lang_expr << "\n"
      locales.each do |lang|
        catalog = Po.parse(File.read(File.join(locales_dir, "#{lang}.po")))
        codegen = Codegen.new(buffer_name, catalog: catalog)
        Slang::Parser.new(slang).parse.accept(codegen)
        io << "when " << lang.inspect << "\n" << codegen.to_s
      end
      io << "else\n"
      fallback = Codegen.new(buffer_name)
      Slang::Parser.new(slang).parse.accept(fallback)
      io << fallback.to_s
      io << "end\n"
    end
  end

  def process_file_i18n(filename, buffer_name = DEFAULT_BUFFER_NAME, locales_dir = "locales", lang_expr = "lang")
    raise "Slang template: #{filename} doesn't exist." unless File.exists?(filename)
    process_string_i18n(File.read(filename), filename, buffer_name, locales_dir, lang_expr)
  end

  # Lists this file's translatable strings as .pot entries; does not touch
  # what process_file generates.
  def extract_strings(slang, filename = "dummy.slang") : String
    document = Slang::Parser.new(slang).parse
    extractor = Extractor.new
    document.accept(extractor)

    extractor.entries.map { |entry|
      String.build do |io|
        io << "#. #{entry.comment}\n" if entry.comment
        io << "#: #{filename}:#{entry.line_number}\n"
        io << "msgid #{entry.msgid.inspect}\n"
        io << "msgstr \"\"\n"
      end
    }.join("\n")
  end

  def extract_strings_from_file(filename) : String
    raise "Slang template: #{filename} doesn't exist." unless File.exists?(filename)
    extract_strings(File.read(filename), filename)
  end
end
