require "spec"
require "../src/slang"

require "./support/form_view"

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

macro render_file_i18n(filename, lang, locales_dir = "spec/fixtures/locales")
  String.build do |__str__|
    \{{ run("./support/process_file_i18n", {{filename}}, "__str__", {{locales_dir}}, {{lang.stringify}}) }}
  end
end

macro render_i18n(slang, lang, locales_dir = "spec/fixtures/locales")
  String.build do |__str__|
    \{{ run("./support/process_i18n", {{slang}}, "__str__", {{locales_dir}}, {{lang.stringify}}) }}
  end
end
