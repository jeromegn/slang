module Slang
  class Token
    property :type
    property :line_number, :column_number
    # elements
    property :name,
      :class_names,
      :attributes,
      :id

    property :value, :escaped, :inline, :visible, :conditional

    @value : String?
    @id : String?

    def initialize
      @type = :EOF
      @line_number = 0
      @column_number = 0
      @name = "div"
      @class_names = Set(String).new
      @attributes = {} of String => String
      @escaped = true
      @inline = false
      @visible = true
      @conditional = ""
    end

  end
end
