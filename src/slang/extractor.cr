require "./visitor"
require "./translatable"

module Slang
  class Extractor < Visitor
    record Entry, msgid : String, line_number : Int32, comment : String? = nil

    getter entries = [] of Entry
    @pending_comment : String? = nil

    def visit(node : Nodes::Doctype)
    end

    def visit(node : Nodes::Comment)
      visit_children(node) if node.visible
    end

    def visit(node : Nodes::Element)
      collect_attributes(node)
      return if Nodes::Element::NO_TRANSLATE_TAGS.includes?(node.name)
      visit_children(node)
    end

    def visit(node : Nodes::Text)
      collect(node.value, node.line_number)
      visit_children(node) if node.children?
    end

    def visit(node : Nodes::Control)
      visit_children(node)
      node.branches.each &.accept(self)
    end

    # A `/ ...` comment is invisible in the rendered HTML (unlike `/! ...`,
    # which renders as `<!-- -->`), so it is free to reuse as a translator
    # note: it attaches to whichever translatable string comes right after it
    # and never reaches the page.
    def visit_children(node : Node)
      pending_comment = nil
      node.children.each do |child|
        if child.is_a?(Nodes::Comment) && !child.visible
          pending_comment = child.value
          next
        end

        # Only touch @pending_comment when *this* level just saw a comment —
        # otherwise a nested visit_children call (recursing into an element's
        # own children) would stomp on a comment an ancestor level is still
        # holding for its next sibling.
        if pending_comment
          @pending_comment = pending_comment
          child.accept(self)
          @pending_comment = nil
          pending_comment = nil
        else
          child.accept(self)
        end
      end
    end

    private def collect_attributes(node : Nodes::Element)
      Translatable::ATTRIBUTES.each do |name|
        attr = node.attributes[name]?
        next unless attr.is_a?(Token::AttributeValue) && attr.literal
        collect(attr.value, node.line_number)
      end
    end

    private def collect(value : String?, line_number : Int32)
      return unless text = Translatable.literal_text(value)
      entries << Entry.new(text, line_number, @pending_comment)
      @pending_comment = nil
    end
  end
end
