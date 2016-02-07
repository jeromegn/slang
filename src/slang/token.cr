module Slang
  class Token

    property :type
    property :line_number, :column_number
    
    # elements
    property :element_name,
             :element_class_names,
             :element_attributes,
             :element_id

    property :value

    def initialize
      @type = :EOF
      @line_number = 0
      @column_number = 0
      @element_class_names = Set(String).new
      @element_attributes = {} of String => String
    end

    # def to_s(io)
    #   case @type
    #   when :KEY
    #     io << @string_value
    #   when :STRING
    #     @string_value.inspect(io)
    #   when :INT
    #     io << @int_value
    #   when :FLOAT
    #     io << @float_value
    #   else
    #     io << @type
    #   end
    # end

  end
end
