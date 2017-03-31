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
    / Multi-line comment
      span this is wrapped in a comment
    /[if IE]
      p Dat browser is old.
    h1 This is a slang file
    h2 This is blue
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
    #amazing-div some-attr="hello"
    /! This is a visible comment
    script var num1 = 8*4;

    javascript:
      var num2 = 8*3;
      alert("8 * 3 + 8 * 4 = " + (num1 + num2);
