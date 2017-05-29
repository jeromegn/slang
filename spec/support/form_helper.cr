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
    yield @form.not_nil!
  end
end
