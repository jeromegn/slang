require "./spec_helper"
require "json"

def evaluates_to_true
  1 == 1
end

def evaluates_to_false
  1 == 2
end

def evaluates_to_hello
  "hello"
end

describe Slang do
  it "renders a basic document" do
    res = render_file("spec/fixtures/basic.slang")
    res.should eq <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width,initial-scale=1.0">
        <title>This is a title</title>
        <style>
          h1 {color: red;}
          p {color: green;}
        </style>
        <style>h2 {color: blue;}</style>
      </head>
      <body>
        <!--Multi-line comment
          <span>this is wrapped in a comment</span>
        -->
        <!--[if IE]>
          <p>Dat browser is old.</p>
        <![endif]-->
        <h1>This is a slang file</h1>
        <h2>This is blue</h2>
        <span id="some-id" class="classname">
          <div id="hello" class="world world2">
            <span>
              <span data-some-var="hello world haha" two-attr="fun">and a hello</span>
              <span>
                <span class="deep_nested">
                  <p>
                    text inside of &lt;p&gt;
                  </p>
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
        <script>var num1 = 8*4;</script>
        <script>
          var num2 = 8*3;
          alert("8 * 3 + 8 * 4 = " + (num1 + num2));
        </script>
      </body>
    </html>
    HTML
  end

  it "renders a UTF8 text" do
    res = render_file("spec/fixtures/utf8.slang")
    res.should eq <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <title>Привет, мир</title>
      </head>
      <body>
        <p>Предложение</p>
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
    it "allows dynamic classname" do
      klass = "my-class"
      render("span class=klass Foo").should eq <<-HTML
      <span class="my-class">Foo</span>
      HTML
    end

    it "escapes output with single = " do
      val = %{"Hello" & world}
      render("span attr=val").should eq <<-HTML
      <span attr="&quot;Hello&quot; & world"></span>
      HTML
    end

    it "should allow quotes inside interpolated blocks " do
      person = {"name" => "cris"}
      res = render_file("spec/fixtures/interpolation-attr.slim")
      res.should eq <<-HTML
      <input name="cris" value="hello">
      HTML
    end

    it "should allow = at the end of attribute values" do
      render(%{h1 id="asdf=" Hello}).should eq <<-HTML
      <h1 id="asdf=">Hello</h1>
      HTML
    end

    # TODO: Implement?
    # it "does not escapes html with ==" do
    #   val = %{Hello & world}
    #   render("span attr==val").should eq <<-HTML
    #   <span attr="Hello & world"></span>
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

  describe "raw html" do
    it "renders html" do
      res = render_file "spec/fixtures/with_html.slang"

      res.should eq <<-HTML
      <table>
        <tr><td>#{Process.pid}</td></tr>
        <tr><td>"hello\\u0021"</td></tr>
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

  describe "svg tag" do
    it "renders tag attributes with colons" do
      res = render_file "spec/fixtures/svg.slang"
      res.should eq <<-HTML
      <div>
        <svg width="256" height="448" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <defs>
            <path id=\"shape1\" d=\"M184 144q0 3.25-2.375\"></path>
            <path id=\"shape2\" d=\"M184 144q0 3.25-2.375\"></path>
          </defs>
        </svg>
      </div>
      HTML
    end
  end

  describe "raw text" do
    it "renders javascript" do
      res = render_file "spec/fixtures/script.slang"
      res.should eq <<-HTML
      <script src="https://somecdn/vue.min.js"></script>
      <script>
        var num = 8*3;
        console.log(num);
      </script>
      <script>var num = 8*4;</script>
      <script>
        new Vue({
          el: '#app',
          template: `
            <div>
              something
            </div>
          `
        })
      </script>
      <script>
        let twoLines = "bar\\nbaz";
        let hello = "Hello, world!";
        let obj = {"a":17,"b":"foo"};
      </script>
      HTML
    end
    it "renders stylesheets" do
      res = render_file "spec/fixtures/style.slang"
      res.should eq <<-HTML
      <style>
        h1 {color:red;}
        p {
          color:blue;
        }
      </style>
      <style>h2 {color:green;}</style>
      HTML
    end
  end

  describe "block" do
    it "renders a simple block" do
      res = render_file "spec/fixtures/blocks.slang"
      res.should eq <<-HTML
      \n<p>1</p>\n<p>2</p>\n<p>3</p>
      HTML
    end

    it "renders complex form helpers" do
      FormView.new.to_s.should eq <<-HTML
      <form>
        <input type="text" name="hello" \\>
        <input type="submit"></form>
      HTML
    end
  end

  describe "boolean attributes" do
    it "renders or not the attribute when a bool is used" do
      res = render_file "spec/fixtures/boolean-attributes.slang"
      res.should eq <<-HTML
      <input type="checkbox" checked>
      <input type="checkbox">
      <input type="checkbox" checked="checked">
      <input type="checkbox" checked>
      <input type="checkbox">
      <input type="checkbox" checked="hello">
      HTML
    end
  end

  describe "attribute wrappers" do
    it "renders attributes properly when wrapped" do
      res = render_file "spec/fixtures/attribute-wrappers.slang"
      res.should eq <<-HTML
      <div hello="world" foo="bar"></div>
      <div hello="world" foo="bar"></div>
      <div hello="world" foo="bar"></div>
      <div hello="#{Process.pid}"></div>
      <div hello="world" foo="bar"></div>
      <div hello="world\\u0021" foo="bar"></div>
      <div hello="world" foo="bar"></div>
      <div hello="world!" foo="bar"></div>
      HTML
    end
  end

  describe "inline tags" do
    it "renders inlined tags" do
      res = render_file "spec/fixtures/inline-tags.slang"
      res.should eq <<-HTML
      <ul>
        <li class="first">
          <a href="/a">A link</a>
        </li>
        <li>
          <a href="/b">B link</a>
        </li>
      </ul>
      <ul>
        <li class="first">
          <a href="/a">A link</a>
        </li>
        <li>
          <a href="/b">B link</a>
        </li>
      </ul>
      HTML
    end
  end
end
