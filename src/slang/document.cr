module Slang
  class Document < Node
    def initialize
      @token = Token.new
      @token.column_number = 1
      @parent = self
    end

    def document?
      true
    end
  end
end
