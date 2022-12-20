# Slang [![Build Status](https://travis-ci.org/jeromegn/slang.svg?branch=master)](https://travis-ci.org/jeromegn/slang)

Lightweight, terse, templating language for Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  slang:
    github: jeromegn/slang
```

## Usage

### Preferred: use Kilt

[Kilt](https://github.com/jeromegn/kilt) is included as a dependency for this project. It should help integrating non-ECR template engines.

Add this to your application's `shard.yml`:
```yaml
dependencies:
  kilt:
    github: jeromegn/kilt
```

```
require "kilt/slang"

Kilt.render("path/to/file.slang") #=> <compiled template>
```

Example with [Kemal](http://kemalcr.com) (includes Kilt):

```crystal
require "kilt/slang"

get "/" do
  Kilt.render "path/to/file.slang"
end
```

### Without Kilt

```crystal
String.build do |str|
  Slang.embed("path/to/file.slang", "str")
end
```

## Syntax

```slim
doctype html
html
  head
    meta name="viewport" content="width=device-width,initial-scale=1.0"
    title This is a title
    css:
      h1 {color: red;}
      p {color: green;}
    style h2 {color: blue;}
  body
    /! Visible multi-line comment
      span this is wrapped in a comment
    /[if IE]
      p Dat browser is old.
    / Invisible multi-line comment
      span this is wrapped in a comment
    h1 This is a slang file
    h2 This is blue
    input type="checkbox" checked=false
    input type="checkbox" checked=true
    input type="checkbox" checked="checked"
    span#some-id.classname
      #hello.world.world2
        - some_var = "hello world haha"
        span
          span data-some-var=some_var two-attr="fun" and a #{p("hello")}
          span
            span.deep_nested
              p
                | text inside of <p>
              = Process.pid
              | text node
              ' other text node
        span.alongside pid=Process.pid
          custom-tag#with-id pid="#{Process.pid}"
            - ["ah", "oh"].each do |s|
              span = s
    / This is an invisible comment
    - if true == true
      #amazing-div some-attr="hello"
    - else
      #not-so-amazing-div some-attr="goodbye"
    /! This is a visible comment
    script var num1 = 8*4;

    javascript:
      var num2 = 8*3;
      alert("8 * 3 + 8 * 4 = " + (num1 + num2));
```

Given the context:

```crystal
some_var = "hello"
strings = ["ah", "oh"]
```

Compiles to HTML:

```html
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
    <!--Visible multi-line comment
      <span>this is wrapped in a comment</span>
    -->
    <!--[if IE]>
      <p>Dat browser is old.</p>
    <![endif]-->
    <h1>This is a slang file</h1>
    <h2>This is blue</h2>
    <input type="checkbox"/>
    <input type="checkbox" checked/>
    <input type="checkbox" checked="checked"/>
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
```

### Difference between single and double equals in Slang

* `=` inserts HTML with escaped characters
* `==` inserts HTML without escaping. It is needed when you have already rendered HTML and you need to insert it to your layout directly.

## TODO

- [x] Fix known limitations
- [ ] More tests
- [ ] Website
- [ ] Documentation

## Contributing

1. Fork it ( https://github.com/jeromegn/slang/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jeromegn](https://github.com/jeromegn) Jerome Gravel-Niquet - creator, maintainer
- [kRaw1er](https://github.com/kRaw1er) Dmitry Neveshkin
- [elorest](https://github.com/elorest) Isaac Sloan
