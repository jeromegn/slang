module Slang
  module Nodes
    class Control < Node
      def branches
        @branches ||= [] of Nodes::Control
      end

      def branches?
        !branches.empty?
      end

      private def control_value : String
        value || ""
      end

      def if?
        control_value.starts_with?("if ")
      end

      def else?
        control_value.match /^else\s{0,}/
      end

      def elsif?
        control_value.starts_with?("elsif ")
      end

      def begin?
        control_value.match(/^begin\s{0,}/)
      end

      def rescue?
        control_value.match(/^rescue\s{0,}/)
      end

      def ensure?
        control_value.match /^ensure\s{0,}/
      end

      def case?
        control_value.starts_with?("case ")
      end

      def when?
        control_value.starts_with?("when ")
      end

      def branch?
        else? || elsif? || rescue? || when? || ensure?
      end

      def branchable?
        if? || case? || begin?
      end

      def allow_branch?(branch)
        return false unless branch.is_a?(Nodes::Control)
        return false unless branchable?
        if if?
          branch.else? || branch.elsif?
        elsif begin?
          branch.rescue? || branch.ensure? || branch.else?
        elsif case?
          branch.when? || branch.else?
        else
          false
        end
      end

      def endable?
        !branch? && children? || branches?
      end

      def to_s(str, buffer_name)
        str << "#{control_value}\n"
        if children?
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
        end
        if branches?
          branches.each do |branch|
            branch.to_s(str, buffer_name)
          end
        end
        str << "end\n" if endable?
      end
    end
  end
end
