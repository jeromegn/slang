module Slang
  module Nodes
    class Block < Node

      getter :value, :parent, :column_number

      def initialize(@parent, @value, @column_number = 1)
      end

      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "#{value}\n"
        str << "#{buffer_name} << \"\n\"\n"
        if children?
          # str << "#{buffer_name} << \"\n\"\n"
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
        end
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "end\n"
      end

    end
  end
end