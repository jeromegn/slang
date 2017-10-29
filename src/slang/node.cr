module Slang
  abstract class Node
    getter :parent, :token
    delegate :value, :column_number, :line_number, :name, :escaped, :inline, to: @token

    def initialize(@parent : Node, @token : Token)
    end

    def nodes # children
      @nodes ||= [] of Node
    end

    def children?
      nodes.size > 0
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
      return count
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

    def to_s(str, buffer_name)
      nodes.each do |node|
        node.to_s(str, buffer_name)
      end
    end
  end
end

require "./nodes/*"
