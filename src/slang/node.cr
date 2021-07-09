module Slang
  abstract class Node
    getter :parent, :token
    delegate :value, :column_number, :line_number, :name, :escaped, to: @token

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

    def to_s(str, buffer_name)
      render_children(str, buffer_name)
    end

    private def render_children(str, buffer_name)
      nodes.each do |node|
        node.to_s(str, buffer_name)
      end
    end
  end
end

require "./nodes/*"
