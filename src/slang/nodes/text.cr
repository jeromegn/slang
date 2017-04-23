module Slang
  module Nodes
    class Text < Node
      def allow_children_to_escape?
        parent.not_nil!.allow_children_to_escape?
      end

      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"\n\"\n" unless str.empty? || inline
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "#{buffer_name} << "
        if escaped && parent.not_nil!.allow_children_to_escape?
          str << "HTML.escape((#{value}).to_s)"
        else
          str << "(#{value})"
        end
        str << ".to_s(#{buffer_name})\n"
        if children?
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
        end
      end
    end
  end
end
