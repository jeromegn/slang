module Slang
  # Minimal gettext .po reader: plain msgid/msgstr entries only. Extractor
  # (see extractor.cr) never emits msgctxt or plurals, so an entry using
  # either is out of this shard's scope and is skipped rather than guessed at.
  module Po
    def self.parse(content : String) : Hash(String, String)
      catalog = {} of String => String

      content.split(/\n[ \t]*\n/).each do |block|
        lines = block.lines.map(&.strip).reject(&.empty?)
        next if lines.empty?
        next if lines.any? { |line| line.starts_with?("#,") && line[2..].split(',').map(&.strip).includes?("fuzzy") }
        next if lines.any?(&.starts_with?("msgctxt")) || lines.any?(&.starts_with?("msgid_plural"))

        lines = lines.reject(&.starts_with?('#'))
        msgid = extract_field(lines, "msgid")
        msgstr = extract_field(lines, "msgstr")
        next unless msgid && msgstr
        next if msgid.empty? || msgstr.empty?

        catalog[msgid] = msgstr
      end

      catalog
    end

    private def self.extract_field(lines : Array(String), keyword : String) : String?
      index = lines.index(&.starts_with?("#{keyword} "))
      return nil unless index

      value = unquote(lines[index][(keyword.size + 1)..])
      j = index + 1
      while j < lines.size && lines[j].starts_with?('"')
        value += unquote(lines[j])
        j += 1
      end
      value
    end

    # `quoted` is a single .po string literal, e.g. `"Salvar\n"`.
    private def self.unquote(quoted : String) : String
      inner = quoted[1..-2]
      String.build do |io|
        j = 0
        while j < inner.size
          c = inner[j]
          if c == '\\' && j + 1 < inner.size
            j += 1
            case inner[j]
            when 'n'  then io << '\n'
            when 't'  then io << '\t'
            when 'r'  then io << '\r'
            when '"'  then io << '"'
            when '\\' then io << '\\'
            else           io << inner[j]
            end
          else
            io << c
          end
          j += 1
        end
      end
    end
  end
end
