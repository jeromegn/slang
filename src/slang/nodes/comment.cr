module Slang
  module Nodes
    class Comment < Node
      delegate :conditional, :visible, to: @token

      def to_s(str, buffer_name)
        if visible
          str << "#{buffer_name} << \"<!--\"\n"
          str << "#{buffer_name} << \"[#{conditional}]>\"\n" if conditional?
          str << "#{buffer_name} << \"#{value}\"\n" if value
          if children?
            nodes.each do |node|
              node.to_s(str, buffer_name)
            end
          end
          str << "#{buffer_name} << \"<![endif]\"\n" if conditional?
          str << "#{buffer_name} << \"-->\"\n"
        end
      end

      def conditional?
        !conditional.empty?
      end
    end
  end
end
