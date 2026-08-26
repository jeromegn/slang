module Slang
  class Token
    enum Type
      EOF
      Newline
      Text
      Element
      Doctype
      Control
      Output
      HTML
      Comment
    end

    # Represents a non-class attribute value together with a flag that is true
    # when the value is a quoted string literal with no #{} interpolation —
    # meaning it can be fully resolved at codegen time.
    record AttributeValue, value : String, literal : Bool

    property type : Type = :EOF
    property line_number : Int32 = 0
    property column_number : Int32 = 0
    # elements
    property name : String = "div"
    property attributes : Hash(String, AttributeValue | Set(String))
    property id : String?

    property value : String?
    property escaped : Bool = true
    property inline : Bool = false
    property visible : Bool = true
    property conditional : String = ""

    def initialize
      @attributes = {} of String => (AttributeValue | Set(String))
      @attributes["class"] = Set(String).new
    end

    def add_attribute(name, value, interpolate)
      if name == "class"
        value = "\#{#{value}}" if interpolate
        (@attributes["class"].as Set) << value
      else
        # A value is a literal when it was quoted in the template ("..."), contains
        # no #{} interpolation, and contains no backslash escape sequences.
        # Backslashes are stored doubled by the lexer (e.g. ! → \\u0021) so
        # taking the raw characters and re-inspecting them would corrupt the value.
        literal = value.starts_with?('"') && value.ends_with?('"') &&
                  !value.includes?('\\') && !value.includes?("\#{")
        @attributes[name] = AttributeValue.new(value, literal)
      end
    end
  end
end
