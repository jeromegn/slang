div
  - if true == false
    span true is false
  - elsif true != true
    span true is not true
  - elsif !"blah".is_a?(String)
    span blah is a string
  - else
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
