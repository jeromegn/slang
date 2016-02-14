require "./spec_helper"

describe Slang do
  
  it "renders a basic document" do
    res = render_file("spec/fixtures/basic.slang")
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
              <span data-some-var="hello world haha" two-attr="fun">and a hello</span>
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
                <span>ah</span>
                <span>oh</span>
              </custom-tag>
            </span>
          </div>
        </span>
        <div id="amazing-div" some-attr="hello"></div>
      </body>
    </html>
    HTML
  end

  describe "attributes" do

    it "accepts string values" do
      render("span attr=\"hello\"").should eq <<-HTML
      <span attr="hello"></span>
      HTML
    end

    it "accepts spaces in attribute string values" do
      render("span attr=\"hello world\"").should eq <<-HTML
      <span attr="hello world"></span>
      HTML
    end

    # it "accepts spaces in attributes with control" do
    #   render("span attr=(p \"hello\")").should eq <<-HTML
      
    #   <span attr="hello"></span>
    #   HTML
    # end

  end

  describe "output" do

    it "accepts spaces in attribute string values" do
      res = render_file "spec/fixtures/output.slang"

      res.should eq <<-HTML
      <div>
        hello
      </div>
      HTML
    end

    it "escapes html" do
      render("div <ah>").should eq <<-HTML
      <div>&lt;ah&gt;</div>
      HTML
    end

    it "escapes html with =" do
      render("div = \"<ah>\"").should eq <<-HTML
      <div>&lt;ah&gt;</div>
      HTML
    end

    it "does not escapes html with ==" do
      render("div == \"<ah>\"").should eq <<-HTML
      <div><ah></div>
      HTML
    end

  end

end
