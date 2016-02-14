module Slang
  class Parser

    def initialize(string)
      @lexer = Lexer.new(string)
      next_token
    end

    def parse(io_name = Slang::DEFAULT_BUFFER_NAME)
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
            document.nodes << Nodes::Doctype.new(document, token)
            next_token
          when :ELEMENT, :TEXT, :CONTROL, :OUTPUT
            parent = @current_node.not_nil!
            until parent.is_a?(Document)
              break if parent.not_nil!.column_number < token.column_number
              parent = parent.not_nil!.parent.not_nil!
            end

            node = case token.type
            when :ELEMENT
              Nodes::Element.new(parent, token)
            when :CONTROL
              Nodes::Control.new(parent, token)
            else
              Nodes::Text.new(parent, token)
            end
            parent.not_nil!.nodes << node
            @current_node = node
            next_token
          when :COMMENT
            # do nothing, for now.
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