module Slang
  module Nodes
    class Element < Node

      SELF_CLOSING_TAGS = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "menuitem", "meta", "param", "source", "track", "wbr"]
      RAW_TEXT_TAGS = ["script", "style"]

      getter :name, :id, :class_names, :attributes
      getter :parent, :column_number
      def initialize(
        @parent,
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

      def to_ecr
        String.build do |str|
          indentation_spaces.times {|n| str << " " }
          str << "<#{name}"
          str << " id=\"#{id}\"" if id
          str << " class=\"#{class_names.join(" ")}\"" if class_names.size > 0
          attributes.each do |name, value|
            str << " #{name}"
            str << "=\"<%= #{value} %>\"" if value
          end
          str << ">"
          if children?
            str << "\n#{super}"
            indentation_spaces.times {|n| str << " " }
          end
          if !self_closing?
            str << "</#{name}>"
          end
        end
      end

      def self_closing?
        SELF_CLOSING_TAGS.includes?(name)
      end

    end
  end
end