module Slang
  module Nodes
    class Element < Node
      SELF_CLOSING_TAGS = {"area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "menuitem", "meta", "param", "source", "track", "wbr"}
      RAW_TEXT_TAGS     = %w(script style)

      delegate :name, :id, :attributes, to: @token

      def generate_class_names
        names = attributes.delete("class").as Set
        names.join(" ")
      end

      def allow_children_to_escape?
        !RAW_TEXT_TAGS.includes?(name)
      end

      def to_s(str, buffer_name)
        str << "#{buffer_name} << \"\n\"\n" unless str.empty?
        str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
        str << "#{buffer_name} << \"<#{name}\"\n"
        str << "#{buffer_name} << \" id=\\\"#{id}\\\"\"\n" if id
        c_names = generate_class_names
        if c_names && c_names != ""
          str << "#{buffer_name} << \" class\"\n"
          str << "#{buffer_name} << \"=\\\"\"\n"
          str << "(\"#{c_names}\").to_s #{buffer_name}\n"
          str << "#{buffer_name} << \"\\\"\"\n"
        end
        attributes.each do |name, value|
          next if value == "false" # don't want the attribute
          str << "#{buffer_name} << \" #{name}\"\n"
          next if value == "true" # just want the attr there
          # any other attribute value.
          str << "#{buffer_name} << \"=\\\"\"\n"
          str << "#{buffer_name} << (#{value}).to_s.gsub(/\"/,\"&quot;\")\n"
          str << "#{buffer_name} << \"\\\"\"\n"
        end
        str << "#{buffer_name} << \">\"\n"
        if children?
          nodes.each do |node|
            node.to_s(str, buffer_name)
          end
        end
        if !self_closing?
          if children? && !only_inline_children?
            str << "#{buffer_name} << \"\n\"\n"
            str << "#{buffer_name} << \"#{indentation}\"\n" if indent?
          end
          str << "#{buffer_name} << \"</#{name}>\"\n"
        end
      end

      def only_inline_children?
        nodes.all? { |n| n.inline }
      end

      def self_closing?
        SELF_CLOSING_TAGS.includes?(name)
      end
    end
  end
end
