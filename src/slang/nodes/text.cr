module Slang
  module Nodes
    class Text < Node

      getter :value, :parent, :column_number

      def initialize(@parent, @value, @column_number = 1)
      end

      def to_ecr
        String.build do |str|
          indentation_spaces.times {|n| str << " " }
          str << "<%= #{value} %>"
        end
      end

    end
  end
end