# Slang [![Build Status](https://travis-ci.org/jeromegn/slang.svg?branch=master)](https://travis-ci.org/jeromegn/slang) [![Dependency Status](https://shards.rocks/badge/github/jeromegn/slang/status.svg)](https://shards.rocks/github/jeromegn/slang) [![devDependency Status](https://shards.rocks/badge/github/jeromegn/slang/dev_status.svg)](https://shards.rocks/github/jeromegn/slang)

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

```
require "kilt/slang"

Kilt.render("path/to/file.slang") #=> <compiled template>
```

Example with [Kemal](http://kemalcr.com) (includes Kilt):

```crystal
require "kilt/slang"

get "/" do
  render "path/to/file.slang"
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
    title This is a title
  body
    span#some-id.classname
      #hello.world.world2
        - some_var = "hello world haha"
        span
          span data-some-var=some_var two-attr="fun" and a #{p("hello")}
          span
            span.deep_nested
              = Process.pid
              | text node
              ' other text node
        span.alongside pid=Process.pid
          custom-tag#with-id pid="#{Process.pid}"
            - ["ah", "oh"].each do |s|
              span = s

    #amazing-div some-attr="hello"
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
```

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
