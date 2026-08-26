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

def passthrough(arg)
  arg
end

def extract(slang) : Array(Slang::Extractor::Entry)
  extractor = Slang::Extractor.new
  Slang::Parser.new(slang).parse.accept(extractor)
  extractor.entries
end

def codegen(slang, catalog = nil) : String
  cg = Slang::Codegen.new(catalog: catalog)
  Slang::Parser.new(slang).parse.accept(cg)
  cg.to_s
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

  describe "comments" do
    it "ignores invisible comments" do
      render("/ invisible\nspan Foo").should eq "<span>Foo</span>"
    end

    it "renders single-line visible comments" do
      render("/! a comment").should eq "<!--a comment-->"
    end

    it "renders visible comments with children" do
      render("/!\n  span Child").should eq "<!--\n  <span>Child</span>\n-->"
    end

    it "renders conditional IE comments" do
      render("/[if IE]\n  p Old browser").should eq "<!--[if IE]>\n  <p>Old browser</p>\n<![endif]-->"
    end
  end

  describe "shorthand elements" do
    it "renders div for #id shorthand" do
      render("#my-id").should eq %(<div id="my-id"></div>)
    end

    it "renders div for .class shorthand" do
      render(".my-class").should eq %(<div class="my-class"></div>)
    end

    it "renders div for combined #id.class shorthand" do
      render("#my-id.my-class").should eq %(<div id="my-id" class="my-class"></div>)
    end
  end

  describe "text node" do
    it "appends trailing space with ' prefix" do
      render("span\n  ' hello").should eq "<span>\n  hello \n</span>"
    end

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
            <path id="shape1" d="M184 144q0 3.25-2.375"></path>
            <path id="shape2" d="M184 144q0 3.25-2.375"></path>
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
    it "renders css: as a style tag" do
      render("css:\n  h1 {color:red;}").should eq "<style>\n  h1 {color:red;}\n</style>"
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

  describe "Windows CRLF line endings" do
    it "renders template with CRLF endings properly" do
      res = render "div(hello=\"world\")\r\n  span pid=Process.pid\r\n"
      res.should eq "<div hello=\"world\">\n  <span pid=\"#{Process.pid}\"></span>\n</div>"
    end
  end

  describe "i18n extraction" do
    it "collects tag text together with its line number" do
      entries = extract("div\n  p Save\n")
      entries.map(&.msgid).should eq ["Save"]
      entries.first.line_number.should eq 2
    end

    it "collects only the allowlisted literal attributes" do
      entries = extract(%(input placeholder="Search" title="Find" type="text" class="foo"))
      entries.map(&.msgid).sort!.should eq ["Find", "Search"]
    end

    it "skips text with no letters, such as separators" do
      extract(%(span class="sep" —\np 42)).should be_empty
    end

    it "skips pre and code content" do
      extract("pre\n  code Save\n").should be_empty
    end

    it "skips interpolated output" do
      extract(%(p\n  = "hi \#{1}"\n)).should be_empty
    end

    it "attaches the preceding invisible comment as a translator comment" do
      entries = extract("/ Translator: the file, not a person\np Name\n")
      entries.first.msgid.should eq "Name"
      entries.first.comment.should eq "Translator: the file, not a person"
    end

    it "does not leak a translator comment past the very next sibling" do
      entries = extract("/ note\np Skip\np Name\n")
      entries.map(&.comment).should eq ["note", nil]
    end

    it "formats entries as gettext .pot fragments" do
      Slang.extract_strings(%(p Save), "views/demo.slang").should eq <<-POT
      #: views/demo.slang:1
      msgid "Save"
      msgstr ""

      POT
    end
  end

  describe "i18n codegen" do
    it "leaves text untouched when no catalog is given" do
      codegen(%(p Save)).should contain("Save")
    end

    it "bakes the translated string directly into the buffer, with no runtime lookup" do
      code = codegen(%(p Save), {"Save" => "Salvar"})
      code.should contain("Salvar")
      code.should_not contain("t(")
      code.should_not contain("Save")
    end

    it "falls back to the source string when the catalog has no entry" do
      codegen(%(p Save), {} of String => String).should contain("Save")
    end

    it "translates only allowlisted literal attributes" do
      code = codegen(%(input placeholder="Search" class="foo"), {"Search" => "Pesquisar", "foo" => "should never be looked up"})
      code.should contain("Pesquisar")
      code.should_not contain("should never be looked up")
    end

    it "does not translate pre/code content even with a catalog" do
      codegen("pre\n  code Save\n", {"Save" => "Salvar"}).should contain("Save")
    end

    it "does not translate text with no letters even with a catalog" do
      codegen(%(span —), {"—" => "should never be looked up"}).should_not contain("should never be looked up")
    end
  end

  describe "Po.parse" do
    it "parses plain msgid/msgstr pairs" do
      Slang::Po.parse(%(msgid "Save"\nmsgstr "Salvar"\n)).should eq({"Save" => "Salvar"})
    end

    it "skips the header entry (empty msgid)" do
      Slang::Po.parse(%(msgid ""\nmsgstr "Content-Type: text/plain\\n"\n)).should be_empty
    end

    it "skips fuzzy entries" do
      Slang::Po.parse(%(#, fuzzy\nmsgid "Save"\nmsgstr "Salvar"\n)).should be_empty
    end

    it "skips entries with an empty msgstr" do
      Slang::Po.parse(%(msgid "Save"\nmsgstr ""\n)).should be_empty
    end

    it "joins multi-line string literals" do
      Slang::Po.parse(%(msgid ""\n"Save"\nmsgstr ""\n"Salvar"\n)).should eq({"Save" => "Salvar"})
    end

    it "unescapes \\n and \\\" within string literals" do
      Slang::Po.parse(%(msgid "a\\nb"\nmsgstr "c\\"d"\n)).should eq({"a\nb" => "c\"d"})
    end
  end

  describe "i18n end-to-end (render_i18n)" do
    it "renders the matching locale's translation" do
      lang = "pt_BR"
      render_i18n(%(p Save), lang).should eq "<p>Salvar</p>"
    end

    it "falls back to the source language for an unknown locale" do
      lang = "fr"
      render_i18n(%(p Save), lang).should eq "<p>Save</p>"
    end

    it "falls back to the source string for a fuzzy or untranslated entry" do
      lang = "pt_BR"
      render_i18n(%(p Cancel), lang).should eq "<p>Cancel</p>"
      render_i18n(%(p Untranslated), lang).should eq "<p>Untranslated</p>"
    end

    it "translates allowlisted attributes too" do
      lang = "pt_BR"
      render_i18n(%(input placeholder="Search"), lang).should eq %(<input placeholder="Pesquisar">)
    end
  end
end
