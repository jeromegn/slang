module Slang
  class Token

    property :type
    property :line_number, :column_number
    
    # elements
    property :name,
             :class_names,
             :attributes,
             :id

    property :value, :escaped, :inline

    def initialize
      @type = :EOF
      @line_number = 0
      @column_number = 0
      @name = "div"
      @class_names = Set(String).new
      @attributes = {} of String => String
      @escaped = true
      @inline = false
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
