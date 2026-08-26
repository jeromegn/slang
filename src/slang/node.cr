module Slang
  abstract class Node
    getter parent : Node
    getter children : Array(Node) = [] of Node
    getter token : Token

    delegate value, column_number, line_number, name, escaped, inline, to: @token

    def initialize(@parent : Node, @token : Token)
    end

    def children? : Bool
      !@children.empty?
    end

    def allow_children_to_escape?
      true
    end

    def document?
      false
    end

    def printable_parents_count
      count = 0
      current_parent = parent
      until current_parent.is_a?(Document)
        count += 1 unless current_parent.class.name.ends_with?("Control")
        current_parent = current_parent.parent
      end
      count
    end

    def indentation_spaces
      printable_parents_count * 2
    end

    def indent?
      !token.inline && indentation_spaces > 0
    end

    def indentation
      indentation_spaces.times.map { " " }.join("")
    end

    def accept(visitor : Visitor)
      visitor.visit(self)
    end
  end
end

require "./nodes/*"
