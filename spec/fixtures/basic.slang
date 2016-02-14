doctype html
html
  head
    title This is a title
  body
    / Multi-line comment
      span this is wrapped in a comment
    /[if IE]
      p Dat browser is old.
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
    / This is an invisible comment
    #amazing-div some-attr="hello"
    /! This is a visible comment