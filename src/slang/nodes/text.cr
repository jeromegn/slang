require "random/secure"

module Slang
  module Nodes
    class Text < Node
      def allow_children_to_escape?
        parent.allow_children_to_escape?
      end

      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"\n\"\n" unless str.empty? || inline
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "#{buffer_name} << "

        # Escaping.
        if escaped && parent.allow_children_to_escape?
          str << "HTML.escape("
        end

        # This is an output (code) token and has children
        if token.type == :OUTPUT && children?
          sub_buffer_name = "#{buffer_name}#{Random::Secure.hex(8)}"
          str << "(#{value}\nString.build do |#{sub_buffer_name}|\n"
          nodes.each do |node|
            node.to_s(str, "#{sub_buffer_name}")
          end
          str << "end\nend)"
        else
          str << "(#{value})"
        end

        # escaping, need to close HTML.escape
        if escaped && parent.allow_children_to_escape?
          str << ".to_s)"
        end
        str << ".to_s(#{buffer_name})\n"

        if token.type != :OUTPUT && children?
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
        end
      end
    end
  end
end
