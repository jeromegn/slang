module Slang
  abstract class Node
  
    def nodes # children
      @nodes ||= [] of Node
    end

    def children?
      nodes.size > 0
    end

    def indentation_spaces
      @indentation_spaces ||= [column_number, 1].max - 1
    end

    def to_ecr
      String.build do |str|
        nodes.each do |node|
          str << node.to_ecr
          str << "\n"
        end
      end
    end

  end
end

require "./nodes/*"