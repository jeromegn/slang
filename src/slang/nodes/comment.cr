module Slang
  module Nodes
    class Comment < Node
      delegate conditional, visible, to: @token

      def conditional?
        !conditional.empty?
      end
    end
  end
end
