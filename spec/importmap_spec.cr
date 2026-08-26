require "./spec_helper"

describe Slang do
  it "does support JS importmaps" do
    res = render <<-SLANG
    html
      head
        script type="importmap"
          | {
          |   "imports": {
          |     "lodash": "https://cdn.jsdelivr.net/npm/lodash-es@4.17.21/lodash.min.js"
          |   }
          | }
      body
        h1 Hello, importmaps!
    SLANG

    res.should eq <<-HTML
    <html>
      <head>
        <script type="importmap">
          {
            "imports": {
              "lodash": "https://cdn.jsdelivr.net/npm/lodash-es@4.17.21/lodash.min.js"
            }
          }
        </script>
      </head>
      <body>
        <h1>Hello, importmaps!</h1>
      </body>
    </html>
    HTML
  end
end
