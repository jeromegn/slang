# Slang

Very much inspired by [slim](https://github.com/slim-template/slim), this is a templating language which outputs HTML.

## Status

**Developer Preview**: Barely any tests, no real-world usage, just playing with creating a nice parser/lexer that gives us slim-like templating capabilities.

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
span#some-id.classname
  #hello.world.world2
    span data-some-var=some_var
      span
        span.deep_nested
          = Process.pid
          | text node
          ' other text node syntax
    span.alongside pid=Process.pid
      custom-tag#with-id pid="#{Process.pid}"
        - strings.each do |s|
          span
            = s
#amazing-div some-attr="hello"
```

Given the context:

```crystal
some_var = "hello"
strings = ["ah", "oh"]
```

Compiles to HTML:

```html
<span id="some-id" class="classname">
  <div id="hello" class="world world2">
    <span data-some-var="hello">
      <span>
        <span class="deep_nested">
          12766
          text node
          other text node
        </span>
      </span>
    </span>
    <span class="alongside" pid="12766">
      <custom-tag id="with-id" pid="12766">
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
```

## Roadmap

- [ ] Documentation
- [ ] Tests
- [x] No need to rely on ECR probably, but that's optimization at this point

## Contributing

1. Fork it ( https://github.com/jeromegn/slang/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jeromegn](https://github.com/jeromegn) Jerome Gravel-Niquet - creator, maintainer
