require "./spec_helper"

describe Slang do
  
  it "renders a basic document" do
    res = render_slang(:basic)
    puts res
    res.should eq <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <title>This is a title</title>
      </head>
      <body>
        <span id="some-id" class="classname">
          <div id="hello" class="world world2">
            <span>
              <span data-some-var="hello world haha" two-attr="fun">and a value</span>
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
        <div id="amazing-div" some-attr="hello"></div>
      </body>
    </html>
    HTML
  end

end
