module Slang
  module Nodes
    class Block < Node

      getter :value, :parent, :column_number

      def initialize(@parent, @value, @column_number = 1)
      end

      def to_ecr
        String.build do |str|
          indentation_spaces.times {|n| str << " " }
          str << "<% #{value} %>"
          str << "\n#{super}" if children?
          indentation_spaces.times {|n| str << " " }
          str << "<% end %>"
        end
      end

    end
  end
end