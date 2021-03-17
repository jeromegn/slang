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
          str << "unless #{value} == false\n" # remove the attribute if value evaluates to false
          str << "#{buffer_name} << \" #{name}\"\n"
          str << "unless #{value} == true\n" # remove the value if value evaluates to true
          # any other attribute value.
          str << "#{buffer_name} << \"=\\\"\"\n"
          str << "#{buffer_name} << (#{value}).to_s.gsub(/\"/,\"&quot;\")\n"
          str << "#{buffer_name} << \"\\\"\"\n"
          str << "end\n"
          str << "end\n"
        end
        str << "#{buffer_name} << \">\"\n"
        render_children(str, buffer_name)
        if !self_closing?
          str << "#{buffer_name} << \"</#{name}>\"\n"
        end
      end

      def self_closing?
        SELF_CLOSING_TAGS.includes?(name)
      end
    end
  end
end
