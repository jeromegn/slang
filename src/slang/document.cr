module Slang
  class Document < Node
    def column_number
      1
    end

    def document?
      true
    end

    def parent
      self
    end
  end
end