require "./spec_helper"

# `Slang.embed_i18n`/`Slang.file_i18n` only take the -Dslang_i18n_disabled
# fallback path at macro-expansion time (see src/slang/macros.cr), so this
# file has nothing to test without it. Run with:
#
#   crystal spec -Dslang_i18n_disabled spec/i18n_flag_spec.cr
{% skip_file unless flag?(:slang_i18n_disabled) %}

class I18nFlagView
  Slang.file_i18n "spec/fixtures/i18n-flag.slang", "spec/fixtures/locales"
end

describe "-Dslang_i18n_disabled" do
  it "makes embed_i18n render the source-language template, ignoring lang" do
    lang = "pt_BR" # translated to "Salvar" in spec/fixtures/locales/pt_BR.po
    result = String.build { |__slang__| Slang.embed_i18n "spec/fixtures/i18n-flag.slang", "__slang__", lang, "spec/fixtures/locales" }
    result.should eq "<p>Save</p>"
  end

  it "makes file_i18n's generated #to_s do the same" do
    result = String.build { |io| I18nFlagView.new.to_s(io, "pt_BR") }
    result.should eq "<p>Save</p>"
  end
end
