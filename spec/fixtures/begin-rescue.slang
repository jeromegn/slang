div
  - begin
    span beginning
    - raise Exception.new("yup")
  - rescue ex : Exception
    span rescued #{ex.message}
    - begin
      span beginning 2
      - array = [] of Int32
      - array[2] > 10
    - rescue ex : IndexError
      span rescued IndexError
      - begin
        span beginning 3
      - rescue
        span rescued begin 3
      - else
        span nothing to rescue