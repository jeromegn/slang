div
  span "hello"
  span "hello" #{passthrough("world")}
  span "hello" "#{passthrough("world")}"
  span "hello #{passthrough("world")}"
  span "hello #{passthrough("#{"world"}")}"
  span "#{%(hello #{"world"})}"
  span #{%["hello #{"world"}"]}
  span #{%{"hello #{"world"}"}}
  span #{%<"hello #{"world"}">}
  span #{%<"hello#{'"'}>} "world"
