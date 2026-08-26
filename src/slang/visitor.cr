module Slang
  class Visitor
    def visit(node : Document)
      visit_children(node)
    end

    def visit(node : Node)
      raise "Not implemented for #{node.class.name}"
    end

    def visit_children(node : Node)
      node.children.each do |child|
        child.accept(self)
      end
    end
  end
end
