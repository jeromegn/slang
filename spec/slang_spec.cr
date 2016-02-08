require "./spec_helper"

describe Slang do
  
  it "ah" do
    render_slang(:basic).should eq <<-HTML
    <!DOCTYPE html>
    <span id="some-id" class="classname">
      <div id="hello" class="world world2">
        <span data-some-var="hello world haha">
          <span>
            <span class="deep_nested">
              #{Process.pid}
              text node
              other text node
            </span>
          </span>
        </span>
        <span class="alongside" pid="#{Process.pid}">
          <custom-tag id="with-id" pid="#{Process.pid}">
            <span>
              ah
            </span>
            <span>
              oh
            </span>
          </custom-tag>
        </span>
      </div>
    </span>
    <div id="amazing-div" some-attr="hello">
    </div>
    HTML
  end

end
