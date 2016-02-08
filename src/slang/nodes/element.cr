module Slang
  module Nodes
    class Element < Node

      SELF_CLOSING_TAGS = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "menuitem", "meta", "param", "source", "track", "wbr"]
      RAW_TEXT_TAGS = ["script", "style"]

      getter :name, :id, :class_names, :attributes
      getter :parent, :column_number
      def initialize(
        @parent : Node,
        @name = "div",
        @id = nil,
        @class_names = Set(String).new,
        @column_number = 1,
        @attributes = {} of String => String
      )
        @name ||= "div"
      end

      def class_names
        if class_attribute = attributes.delete("class")
          class_attribute.split(" ").each { |cn| @class_names << cn }
        end
        @class_names
      end

      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"\n\"\n"
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "#{buffer_name} << \"<#{name}\"\n"
        str << "#{buffer_name} << \" id=\\\"#{id}\\\"\"\n" if id
        if class_names.size > 0
          str << "#{buffer_name} << \" class=\\\"#{class_names.join(" ")}\\\"\"\n"
        end
        attributes.each do |name, value|
          str << "#{buffer_name} << \" #{name}\"\n"
          if value
            str << "#{buffer_name} << \"=\\\"\"\n"
            str << "(#{value}).to_s #{buffer_name}\n"
            str << "#{buffer_name} << \"\\\"\"\n"
          end
        end
        str << "#{buffer_name} << \">\"\n"
        if children?
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
        end
        if !self_closing?
          str << "#{buffer_name} << \"\n\"\n"
          str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
          str << "#{buffer_name} << \"</#{name}>\"\n"
        end
      end

      def self_closing?
        SELF_CLOSING_TAGS.includes?(name)
      end

    end
  end
end