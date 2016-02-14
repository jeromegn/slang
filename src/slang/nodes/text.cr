module Slang
  module Nodes
    class Text < Node
      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"\n\"\n" unless str.empty? || inline
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "#{buffer_name} << "
        if escaped
          str << "HTML.escape((#{value}).to_s)"
        else
          str << "(#{value})"
        end
        str << ".to_s(#{buffer_name})\n"
      end

    end
  end
end