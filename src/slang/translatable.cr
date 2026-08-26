module Slang
  # Shared by Codegen (which emits t() calls) and Extractor (which lists the
  # same strings for translators), so the two can never drift apart.
  module Translatable
    ATTRIBUTES = %w(placeholder title aria-label alt)

    # A literal (quoted, no #{}, no escapes) value with no letters is
    # decoration, not prose: separators such as "·" or "—", bare numbers,
    # standalone punctuation. Translators shouldn't see those, so they are
    # extracted and rendered as-is instead of going through t().
    def self.literal_text(value : String?) : String?
      return nil unless value
      return nil unless value.size >= 2 && value[0] == '"' && value[-1] == '"'

      text = value[1..-2]
      return nil if text.includes?('\\') || text.includes?("\#{")
      return nil unless text.each_char.any?(&.letter?)

      text
    end
  end
end
