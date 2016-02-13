doctype html
html
  head
    title This is a title
  body
    span#some-id.classname
      #hello.world.world2
        - some_var = "hello world haha"
        span
          span data-some-var=some_var two-attr="fun" and a value
          span
            span.deep_nested
              = Process.pid
              | text node
              ' other text node
        span.alongside pid=Process.pid
          custom-tag#with-id pid="#{Process.pid}"
            - ["ah", "oh"].each do |s|
              span
                = s

    #amazing-div some-attr="hello"