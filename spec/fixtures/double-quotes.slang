div
  span "hello"
  span "hello" #{p("world")}
  span "hello" "#{p("world")}"
  span "hello #{p("world")}"
  span "hello #{p("#{"world"}")}"
  span "#{%(hello #{"world"})}"
  span #{%["hello #{"world"}"]}
  span #{%{"hello #{"world"}"}}
  span #{%<"hello #{"world"}">}
