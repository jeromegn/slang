# Slang [![Build Status](https://travis-ci.org/jeromegn/slang.svg?branch=master)](https://travis-ci.org/jeromegn/slang) [![Dependency Status](https://shards.rocks/badge/github/jeromegn/slang/status.svg)](https://shards.rocks/github/jeromegn/slang) [![devDependency Status](https://shards.rocks/badge/github/jeromegn/slang/dev_status.svg)](https://shards.rocks/github/jeromegn/slang)

Very much inspired by [slim](https://github.com/slim-template/slim), this is a templating language which outputs HTML.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  slang:
    github: jeromegn/slang
```

## Usage

### Rendering some slang to HTML

```crystal
String.build do |str|
  embed_slang("path/to/file.slang", "str")
end
```

### With frameworks...

```crystal
macro render_slang(filename)
  String.build do |__view__|
    embed_slang "views/{{filename.id}}.slang", "__view__"
  end
end

render_slang :hello # will check for views/hello.slang and render it.
```

Example with [Kemal](http://kemalcr.com):

```crystal
get "/" do
  render_slang :hello
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

- [ ] More tests
- [ ] Website
- [ ] Documentation
- [x] No need to rely on ECR probably, but that's optimization at this point

## Contributing

1. Fork it ( https://github.com/jeromegn/slang/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jeromegn](https://github.com/jeromegn) Jerome Gravel-Niquet - creator, maintainer
