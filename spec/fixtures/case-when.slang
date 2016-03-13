div
  - case "string"
  - when "blah"
    span \"string\" is \"blah\"
  - when false
    span \"string\" is false
  - when String
    span this guy is nested
    - if false
      span nope
    - else
      span deeply nested
      - if false
      - elsif false
      - elsif false
      - else
        span true is just true man
