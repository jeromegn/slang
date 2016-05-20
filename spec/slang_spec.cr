require "./spec_helper"

describe Slang do
  it "renders a basic document" do
    res = render_file("spec/fixtures/basic.slang")
    res.should eq <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width,initial-scale=1.0">
        <title>This is a title</title>
      </head>
      <body>
        <!--Multi-line comment
          <span>this is wrapped in a comment</span>
        -->
        <!--[if IE]>
          <p>Dat browser is old.</p>
        <![endif]-->
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
        <!--This is a visible comment-->
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

  describe "raw html" do
    it "renders html" do
      res = render_file "spec/fixtures/with_html.slang"

      res.should eq <<-HTML
      <table>
        <tr><td>#{Process.pid}</td></tr>
      </table>
      HTML
    end
  end

  describe "if elsif else" do
    it "renders the correct branches" do
      res = render_file "spec/fixtures/if-elsif-else.slang"

      res.should eq <<-HTML
      <div>
        <span>this guy is nested</span>
        <span>deeply nested</span>
        <span>true is just true man</span>
      </div>
      HTML
    end
  end

  describe "case when" do
    it "renders the correct branches" do
      res = render_file "spec/fixtures/case-when.slang"

      res.should eq <<-HTML
      <div>
        <span>this guy is nested</span>
        <span>deeply nested</span>
        <span>true is just true man</span>
      </div>
      HTML
    end
  end

  describe "begin rescue" do
    it "renders the correct branches" do
      res = render_file "spec/fixtures/begin-rescue.slang"

      res.should eq <<-HTML
      <div>
        <span>beginning</span>
        <span>rescued yup</span>
        <span>beginning 2</span>
        <span>rescued IndexError</span>
        <span>beginning 3</span>
        <span>nothing to rescue</span>
      </div>
      HTML
    end
  end

  describe "text node" do
    it "properly escapes double quotes" do
      res = render_file "spec/fixtures/double-quotes.slang"

      res.should eq <<-HTML
      <div>
        <span>&quot;hello&quot;</span>
        <span>&quot;hello&quot; world</span>
        <span>&quot;hello&quot; &quot;world&quot;</span>
        <span>&quot;hello world&quot;</span>
        <span>&quot;hello world&quot;</span>
        <span>&quot;hello world&quot;</span>
        <span>&quot;hello world&quot;</span>
        <span>&quot;hello world&quot;</span>
        <span>&quot;hello world&quot;</span>
        <span>&quot;hello&quot; &quot;world&quot;</span>
      </div>
      HTML
    end
  end
end
