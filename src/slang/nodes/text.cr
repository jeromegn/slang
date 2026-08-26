require "random/secure"

module Slang
  module Nodes
    class Text < Node
      def allow_children_to_escape?
        parent.allow_children_to_escape?
      end
    end
  end
end
