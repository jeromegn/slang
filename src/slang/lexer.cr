module Slang
  class Lexer

    getter token

    def initialize(string)
      @reader = Char::Reader.new(string)
      @token = Token.new
      @line_number = 1
      @column_number = 1
      @io = MemoryIO.new
    end

    def next_token
      skip_whitespace

      @token = Token.new
      @token.line_number = @line_number
      @token.column_number = @column_number

      case current_char
      when '\0'
        @token.type = :EOF
      when '\r'
        if next_char == '\n'
          consume_newline
        else
          raise "expected '\\n' after '\\r'"
        end
      when '\n'
        consume_newline
      when '.', '#', .alpha?
        consume_element
      when '-'
        consume_block
      else
        consume_text
      end
      p @token
    end

    private def consume_element
      @token.type = :ELEMENT

      loop do
        case current_char
        when .alpha?
          consume_element_name
        when '.'
          next_char # skip the . or # at the beginning
          consume_element_class
        when '#'
          next_char # skip the . or # at the beginning
          consume_element_id
        when ' '
          consume_element_attributes
        else
          break
        end
      end

    end
 
    private def consume_element_attributes
      loop do
        case current_char
        when .alpha?, '-', '_'
          n, v = p consume_element_attribute
          @token.element_attributes[n] = v
        when ' '
          next_char
        else
          break
        end
      end
    end

    private def consume_element_attribute
      { consume_html_valid_name, consume_value }
    end

    private def consume_element_name
      @token.element_name = consume_html_valid_name
    end

    private def consume_element_class
      @token.element_class_names << consume_html_valid_name
    end

    private def consume_element_id
      @token.element_id = consume_html_valid_name
    end

    private def consume_tag_component
      consume_html_valid_name
    end

    private def consume_html_valid_name
      String.build do |str|
        loop do
          case current_char
          when .alphanumeric?, '-', '_'
            str << current_char
            next_char
          else
            break
          end
        end
      end
    end

    private def consume_block
      @token.type = :BLOCK
      next_char
      next_char if current_char == ' '
      @token.value = consume_value(false)
    end

    private def consume_text
      @token.type = :TEXT
      if current_char == '='
        next_char
        next_char if current_char == ' '
        @token.value = consume_value(false)
      else
        next_char if current_char == '|' || current_char == '\''
        next_char if current_char == ' '
        @token.value = "\"#{consume_value(false)}\""
      end
    end

    CLOSE_OPEN_MAP = {
      '}' => '{',
      ']' => '[',
      ')' => '('
    }

    private def consume_value(end_on_space = true)
      String.build do |str|
        opened_controls = {} of Char => Int32
        loop do
          case current_char
          when '='
            next_char
          when '[', '{', '(' # opening control
            opened_controls[current_char] ||= 0
            opened_controls[current_char] += 1
            str << current_char
            next_char
          when ']', '}', ')' # closing control
            open_char = CLOSE_OPEN_MAP[current_char]
            if opened_controls[open_char]
              opened_controls[open_char] -= 1
            end
            str << current_char
            next_char
          when ' '
            break if end_on_space && opened_controls.all? { |k,v| v == 0 }
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
          unless next_char == '\n'
            raise "expected '\\n' after '\\r'"
          end
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