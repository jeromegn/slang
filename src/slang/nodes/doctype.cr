module Slang
  module Nodes
    class Doctype < Node
      getter :value
      getter :parent

      def initialize(@parent : Node, @value)
      end

      def column_number
        1
      end

      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"<!DOCTYPE #{value}>\"\n"
      end

    end
  end
end