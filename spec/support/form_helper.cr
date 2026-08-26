class Form
  def initialize
  end

  def text_input(name)
    "<input type=\"text\" name=\"#{name}\" \\>"
  end
end

module FormHelper
  def form_for(&)
    form = Form.new
    String.build do |__form__|
      __form__ << "<form>"
      __form__ << yield form
      __form__ << "</form>"
    end
  end
end
