class Form
  def initialize
  end

  def text_input(name)
    "<input type=\"text\" name=\"#{name.to_s}\" \\>"
  end
end

module FormHelper
  def form_for
    @form = Form.new
    String.build do |__form__|
      __form__ << "<form>"
      __form__ << yield @form.not_nil!
      __form__ << "</form>"
    end
  end
end
