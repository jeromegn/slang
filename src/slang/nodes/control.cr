module Slang
  module Nodes
    class Control < Node

      def to_s(str, buffer_name)
        str << "#{value}\n"
        if children?
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
          str << "end\n"
        end
      end

    end
  end
end