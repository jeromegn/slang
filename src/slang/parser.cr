module Slang
  class Parser
    @current_node : Node

    def initialize(string)
      @lexer = Lexer.new(string)
      @document = Document.new
      @current_node = @document
      @control_nodes_per_column = {} of Int32 => Nodes::Control
      next_token
    end

    def parse(io_name = Slang::DEFAULT_BUFFER_NAME)
      String.build do |str|
        loop do
          case token.type
          when :EOF
            break
          when :NEWLINE
            next_token
          when :DOCTYPE
            @document.nodes << Nodes::Doctype.new(@document, token)
            next_token
          when :ELEMENT, :TEXT, :HTML, :COMMENT, :CONTROL, :OUTPUT
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
                   when :COMMENT
                     Nodes::Comment.new(parent, token)
                   else
                     Nodes::Text.new(parent, token)
                   end

            # puts node.inspect
            # puts @control_nodes_per_column[node.column_number]?

            if node.is_a?(Nodes::Control)
              if @control_nodes_per_column[node.column_number]?
                last_control_node = @control_nodes_per_column[node.column_number]
                # puts "LAST CONTROL NODE"
                # puts last_control_node.inspect
                if last_control_node.allow_branch?(node)
                  last_control_node.branches << node
                else
                  @control_nodes_per_column[node.column_number] = node
                  parent.not_nil!.nodes << node
                end
              else
                @control_nodes_per_column[node.column_number] = node
                parent.not_nil!.nodes << node
              end
            else
              parent.not_nil!.nodes << node
            end
            @current_node = node
            next_token
          else
            unexpected_token
          end
        end
        @document.to_s(str, io_name)
      end
    end

    private delegate token, to: @lexer
    private delegate next_token, to: @lexer

    private def unexpected_token
      raise "unexpected token '#{token}'"
    end
  end
end
