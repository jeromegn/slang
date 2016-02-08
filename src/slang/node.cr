module Slang
  abstract class Node

    def nodes # children
      @nodes ||= [] of Node
    end

    def children?
      nodes.size > 0
    end

    def indentation_spaces
      [column_number, 1].max - 1
    end

    def indent?
      indentation_spaces > 0
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