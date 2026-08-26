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

    def parse : Document
      loop do
        case token.type
        in .eof?
          break
        in .newline?
          next_token
        in .doctype?
          @document.children << Nodes::Doctype.new(@document, token)
          next_token
        in .element?, .text?, .html?, .comment?, .control?, .output?
          parent = @current_node

          # find the parent
          until parent.is_a?(Document)
            # column number is smaller than the node we're processing
            # therefore it is the parent
            break if parent.column_number < token.column_number
            parent = parent.parent
          end

          node = case token.type
                 when .element?
                   Nodes::Element.new(parent, token)
                 when .control?
                   Nodes::Control.new(parent, token)
                 when .comment?
                   Nodes::Comment.new(parent, token)
                 else
                   Nodes::Text.new(parent, token)
                 end

          if node.is_a?(Nodes::Control)
            if @control_nodes_per_column[node.column_number]?
              last_control_node = @control_nodes_per_column[node.column_number]
              # puts "LAST CONTROL NODE"
              # puts last_control_node.inspect
              if last_control_node.allow_branch?(node)
                last_control_node.branches << node
              else
                @control_nodes_per_column[node.column_number] = node
                parent.children << node
              end
            else
              @control_nodes_per_column[node.column_number] = node
              parent.children << node
            end
          else
            parent.children << node
          end
          @current_node = node
          next_token
        end
      end
      @document
    end

    private delegate token, to: @lexer
    private delegate next_token, to: @lexer
  end
end
