doctype html
span#some-id.classname
  #hello.world.world2
    - some_var = "hello world haha"
    span data-some-var=some_var
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