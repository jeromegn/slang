module Slang
  class Lexer

    getter token

    def initialize(string)
      @reader = Char::Reader.new(string)
      @token = Token.new
      @line_number = 1
      @column_number = 1
      @last_token = @token
    end

    def next_token
      skip_whitespace

      @token = Token.new
      @token.line_number = @line_number
      @token.column_number = @column_number

      inline = @last_token.type == :ELEMENT && @last_token.line_number == @line_number

      if current_char.alphanumeric? && inline
        consume_text
      else
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
          consume_control
        when '='
          consume_output
        when '|', '\''
          consume_text
        when '/'
          @token.type = :COMMENT
          next_char
          @token.value = consume_line
        else
          unexpected_char
        end
      end
      @token.inline = inline
      @last_token = @token
      @token
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
          break
        else
          break
        end
      end

    end
 
    private def consume_element_attributes
      current_attr_name = ""

      loop do
        case current_char
        when .alphanumeric?
          break unless current_attr_name.empty?
          current_attr_name = consume_html_valid_name
        when '='
          break if current_attr_name.empty?
          @token.attributes[current_attr_name] = consume_value
          current_attr_name = ""
        when ' '
          break unless current_attr_name.empty?
          next_char
        else
          break
        end
      end

      go_back(current_attr_name.size)
    end

    private def consume_element_name
      @token.name = consume_html_valid_name
      if @token.name == "doctype"
        @token.type = :DOCTYPE
        next_char if current_char == ' '
        @token.value = consume_line
      end
    end

    private def consume_element_class
      @token.class_names << consume_html_valid_name
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
          when .alphanumeric?, '-', '_'
            str << current_char
            next_char
          else
            break
          end
        end
      end
    end

    private def consume_control
      @token.type = :CONTROL
      next_char
      next_char if current_char == ' '
      @token.value = consume_line
    end

    private def consume_output
      @token.type = :OUTPUT
      next_char
      @token.escaped = current_char != '='
      next_char unless @token.escaped
      skip_whitespace
      @token.value = consume_line.strip
    end

    private def consume_text
      @token.type = :TEXT
      append_whitespace = current_char == '\''
      next_char if current_char == '|' || current_char == '\''
      skip_whitespace
      @token.value = "\"#{consume_line.strip}#{append_whitespace ? " " : ""}\""
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

    # private def consume_multi_line
    #   String.build do |str|
    #     loop do
    #     end
    #   end
    # end

    CLOSE_OPEN_MAP = {
      '}' => '{',
      ']' => '[',
      ')' => '('
    }

    private def consume_value(end_on_space = true)
      String.build do |str|
        is_str = false
        is_in_parenthesis = false
        loop do
          case current_char
          when '='
            next_char
            if current_char == '"'
              is_str = true
              str << current_char
              next_char
            elsif current_char == '('
              is_in_parenthesis = true
              str << current_char
              next_char
            end
          when '"'
            str << current_char
            next_char
            break
          when ')'
            str << current_char
            next_char
            break if is_in_parenthesis
          when ' '
            break if !is_str && !is_in_parenthesis && end_on_space
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