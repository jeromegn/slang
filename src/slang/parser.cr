module Slang
  class Parser
    DEFAULT_BUFFER_NAME = "__slang__"

    def initialize(string)
      @lexer = Lexer.new(string)
      next_token
    end

    def parse(io_name = DEFAULT_BUFFER_NAME)
      document = Document.new
      @current_node = document
      String.build do |str|
        loop do
          case token.type
          when :EOF
            break
          when :NEWLINE
            next_token
          when :DOCTYPE
            document.nodes << Nodes::Doctype.new(document, token.value)
            next_token
          when :ELEMENT, :TEXT, :CONTROL
            parent = @current_node.not_nil!
            until parent.is_a?(Document)
              break if parent.not_nil!.column_number < token.column_number
              parent = parent.not_nil!.parent.not_nil!
            end

            node = case token.type
            when :ELEMENT
              Nodes::Element.new(parent, token.element_name,
                class_names: token.element_class_names,
                id: token.element_id,
                column_number: token.column_number,
                attributes: token.element_attributes,
                value: token.value
              )
            when :CONTROL
              Nodes::Control.new(parent, token.value, column_number: token.column_number)
            else
              Nodes::Text.new(parent, token.value, column_number: token.column_number)
            end
            parent.not_nil!.nodes << node
            @current_node = node
            next_token
          else
            unexpected_token
          end
        end
        document.to_s(str, io_name)
      end
    end

    private delegate token, @lexer
    private delegate next_token, @lexer

    private def unexpected_token
      raise "unexpected token '#{token}'"
    end
  end
end