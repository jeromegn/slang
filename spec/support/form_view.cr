require "./form_helper"

class FormView
  include FormHelper

  def to_s
    String.build do |__str__|
      {{ run("./process_file", "spec/fixtures/form-helper.slang", "__str__") }}
    end
  end
end
