module Slang
  abstract class Node

    getter :parent, :token
    delegate :value, :column_number, :line_number, :escaped, :inline, @token

    def initialize(@parent : Node, @token : Token)
    end

    def nodes # children
      @nodes ||= [] of Node
    end

    def children?
      nodes.size > 0
    end

    def document?
      false
    end

    def indentation_spaces
      if column_number == 1
        0
      else
        control_depth = 0
        current_parent = parent
        # de-indent blocks
        until current_parent.is_a?(Document)
          control_depth += 1 if current_parent.class.name.ends_with?("Control")
          current_parent = current_parent.not_nil!.parent.not_nil!
        end
        [(column_number - (control_depth * 2)), 1].max - 1
      end
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