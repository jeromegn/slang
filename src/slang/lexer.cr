module Slang
  class Lexer
    RAWSTUFF = {"javascript:": "script", "css:": "style"}
    getter token

    def initialize(string)
      @reader = Char::Reader.new(string)
      @token = Token.new
      @line_number = 1
      @column_number = 1
      @last_token = @token
      @raw_text_column = 0
    end

    def next_token
      skip_whitespace
      @token = Token.new
      @token.line_number = @line_number
      @token.column_number = @column_number

      if @raw_text_column > 0 && @column_number < @raw_text_column
        @raw_text_column = 0
      end

      inline = @raw_text_column > 0 || (@last_token.type == :ELEMENT && @last_token.line_number == @line_number)

      case current_char
      when '\0'
        @token.type = :EOF
      when '\r'
        raise "slang expected '\\n' after '\\r'" unless next_char == '\n'
        consume_newline
      when '\n'
        consume_newline
      when '.', '#', .ascii_letter?
        inline ? consume_text : consume_element
      when '-'
        inline ? consume_text : consume_control
      when ':'
        inline = false # don't consider this "inline" for output
        consume_inline_element
      when '='
        consume_output
      when '|', '\''
        consume_text
      when '<'
        consume_html
        @token.escaped = true if inline
      when '/'
        consume_comment
      else
        if inline
          consume_text
        else
          unexpected_char
        end
      end

      @token.inline = inline unless @raw_text_column > 0
      @last_token = @token
      @token
    end

    ATTR_OPEN_CLOSE_MAP = {
      '{' => '}',
      '[' => ']',
      '(' => ')',
      ' ' => ' ',
    }

    private def consume_element
      @token.type = :ELEMENT

      loop do
        case current_char
        when .ascii_letter?
          consume_element_name
        when '.'
          next_char # skip the '.' at the beginning
          consume_element_class
        when '#'
          next_char # skip the '#' at the beginning
          consume_element_id
        when ' ', '[', '(', '{'
          close_char = ATTR_OPEN_CLOSE_MAP[current_char]
          open_char = current_char
          next_char
          consume_element_attributes(open_char, close_char)
          break
        else
          break
        end
      end
    end

    private def consume_inline_element
      next_char # skip ':'
      skip_whitespace
      consume_element
    end

    private def consume_element_attributes(open_char, close_char)
      current_attr_name = ""

      loop do
        case current_char
        when .alphanumeric?
          break unless current_attr_name.empty?
          current_attr_name = consume_html_valid_name
        when '='
          break if current_attr_name.empty?
          @token.add_attribute current_attr_name, consume_value(open_char, close_char), true
          current_attr_name = ""
        when ' ', close_char
          break unless current_attr_name.empty?
          next_char
        else
          break
        end
      end

      go_back(current_attr_name.size)
    end

    private def consume_element_name
      @token.name = check_raw_text_header(consume_html_valid_name)
      if @token.name == "doctype"
        @token.type = :DOCTYPE
        next_char if current_char == ' '
        @token.value = consume_line
      end
    end

    private def consume_element_class
      @token.add_attribute "class", consume_html_valid_name, false
    end

    private def consume_element_id
      @token.id = consume_html_valid_name
    end

    private def consume_tag_component
      consume_html_valid_name
    end

    private def consume_html_valid_name
      String.build do |str|
        loop do
          case current_char
          when ':'
            break if ATTR_OPEN_CLOSE_MAP.keys.includes? peek_next_char
          when .alphanumeric?, '-', '_'
            # continue
          else
            break
          end

          str << current_char
          next_char
        end
      end
    end

    private def check_raw_text_header(name : String)
      if RAWSTUFF.has_key?(name)
        @raw_text_column = (@column_number - name.size) + 2
        RAWSTUFF[name]
      else
        name
      end
    end

    private def consume_comment
      @token.type = :COMMENT
      next_char
      if current_char == '!'
        @token.visible = true
        next_char
      elsif current_char == '['
        @token.visible = true
        next_char
        @token.conditional = String.build do |str|
          loop do
            case current_char
            when ']'
              next_char
              break
            when '\0', '\n'
              break
            when '\r'
              raise "slang expected '\\n' after '\\r'" unless next_char == '\n'
            else
              str << current_char
              next_char
            end
          end
        end
      else
        @token.visible = false
      end
      skip_whitespace
      @token.value = consume_line if @token.conditional.empty?
    end

    private def consume_control
      @token.type = :CONTROL
      next_char
      next_char if current_char == ' '
      @token.value = consume_line
    end

    private def consume_output
      @token.type = :OUTPUT
      append_whitespace = false
      prepend_whitespace = false
      next_char
      if current_char == '='
        @token.escaped = false
        next_char
      end
      if current_char == '<'
        prepend_whitespace = true
        next_char
      end
      if current_char == '>'
        append_whitespace = true
        next_char
      end

      skip_whitespace
      @token.value = consume_line.strip
      @token.value = " #{@token.value}" if prepend_whitespace
      @token.value = "#{@token.value} " if append_whitespace
    end

    private def consume_text
      @token.type = :TEXT
      append_whitespace = current_char == '\''
      next_char if current_char == '|' || current_char == '\''
      skip_whitespace
      @token.value = "\"#{consume_text_line.strip}#{append_whitespace ? " " : ""}\""
    end

    private def consume_text_line
      consume_string escape_double_quotes: true
    end

    private def consume_string_interpolation
      maybe_string = false
      String.build do |str|
        loop do
          if current_char == '%'
            maybe_string = true
          end
          if maybe_string && STRING_OPEN_CLOSE_CHARS_MAP.has_key? current_char
            oc = current_char
            cc = STRING_OPEN_CLOSE_CHARS_MAP[current_char]
            str << current_char
            next_char
            str << consume_string open_char: oc, close_char: cc
            next
          end
          if current_char == '"' || current_char == '\''
            ch = current_char
            str << current_char
            next_char
            str << consume_string open_char: ch, close_char: ch
            next
          end
          if current_char == '}'
            str << current_char
            next_char
            break
          end

          if current_char == '\n' || current_char == '\0'
            break
          else
            str << current_char
            next_char
          end
        end
      end
    end

    private def consume_string(open_char = '"', close_char = '"', escape_double_quotes = false)
      level = 0
      escaped = false
      maybe_string_interpolation = false
      String.build do |str|
        loop do
          if escape_double_quotes
            if current_char == '"'
              str << "\\\""
              next_char
              next
            end
          else
            if (close_char == '"' || close_char == '\'') && current_char == close_char && !escaped
              str << current_char
              next_char
              break
            end

            if current_char == open_char && !escaped
              level += 1
            end
            if current_char == close_char && !escaped
              if level == 0
                str << current_char
                next_char
                break
              end
              level -= 1
            end
          end

          if maybe_string_interpolation
            maybe_string_interpolation = false
            if current_char == '{'
              str << consume_string_interpolation
              next
            end
          end
          if current_char == '#' && !escaped
            maybe_string_interpolation = true
          end

          if current_char == '\\' && !escaped
            escaped = true
          else
            escaped = false
          end

          if current_char == '\n' || current_char == '\0'
            break
          else
            str << current_char
            next_char
          end
        end
      end
    end

    private def consume_html
      @token.type = :HTML
      @token.escaped = false
      @token.value = "\"#{consume_line}\""
    end

    private def consume_line
      String.build do |str|
        loop do
          if current_char == '\n' || current_char == '\0'
            break
          else
            str << current_char
            next_char
          end
        end
      end
    end

    STRING_OPEN_CLOSE_CHARS_MAP = {
      '(' => ')',
      '{' => '}',
      '[' => ']',
      '<' => '>',
    }

    private def consume_value(open_char, close_char)
      String.build do |str|
        open_count = 0

        is_str = false
        is_in_parenthesis = false
        is_in_interpolation = false
        loop do
          case current_char
          when '='
            next_char
            if current_char == '"'
              ch = current_char
              str << current_char
              next_char
              str << consume_string open_char: ch, close_char: ch
              break
            end
          when ' '
            break if open_count == 0
            str << current_char
            next_char
          when open_char
            next if open_char == ' '
            open_count += 1
            str << current_char
            next_char
          when close_char
            next if close_char == ' '
            break if open_count == 0
            open_count -= 1
            str << current_char
            next_char
          when '\n', '\0'
            break
          else
            str << current_char
            next_char
          end
        end
      end
    end

    private def consume_newline
      @line_number += 1
      @column_number = 0
      loop do
        case next_char
        when '\r'
          raise "slang expected '\\n' after '\\r'" unless next_char == '\n'
        when '\n'
          # Nothing
        else
          break
        end
        @line_number += 1
        @column_number = 0
      end
      @token.line_number = @line_number
      @token.column_number = @column_number
      @token.type = :NEWLINE
    end

    private def go_back(n)
      @column_number -= n
      @reader.pos -= n
    end

    private def next_char
      @column_number += 1
      @reader.next_char
    end

    private def next_char(token_type)
      @token.type = token_type
      next_char
    end

    private def peek_next_char
      @reader.peek_next_char
    end

    private def current_pos
      @reader.pos
    end

    private def current_char
      @reader.current_char
    end

    private def skip_whitespace
      while current_char == ' ' || current_char == '\t'
        next_char
      end
    end

    private def unexpected_char(char = current_char)
      raise "unexpected char '#{char}'"
    end
  end
end
