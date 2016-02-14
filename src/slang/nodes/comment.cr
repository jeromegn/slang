module Slang
  module Nodes
    class Comment < Node

      delegate :conditional, :visible, @token

      def to_s(str, buffer_name)
        if visible || children?
          str << "#{buffer_name} << \"\n\"\n" unless str.empty?
          str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
          str << "#{buffer_name} << \"<!--\"\n"
          str << "#{buffer_name} << \"[#{conditional}]>\"\n" if conditional?
          str << "#{buffer_name} << \"#{value}\"\n" if value
          if children?
            nodes.each do |node|
              node.to_s(str, buffer_name)
            end
            str << "#{buffer_name} << \"\n#{indentation}\"\n"
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