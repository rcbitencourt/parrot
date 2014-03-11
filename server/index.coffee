express = require('express')
http = require('http')
app = express()

app.get "/ping", (req, res) ->
  res.json(200, "pong! :]")

server = http.createServer(app).listen(3300)
module.exports = app