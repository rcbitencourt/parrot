express = require('express')
http = require('http')
socketio = require('socket.io')

app = express()
server = http.createServer(app)
io = socketio.listen(server)

app.use('/', express.static(__dirname + '/../client'));

app.get "/api/ping", (req, res) ->
  res.json(200, "pong! :]")

io.sockets.on 'connection', (socket) ->
  # console.log "Socket connected: #{socket.id}"

  socket.on "message", (msg) ->
    io.sockets.emit "message", msg
    # console.log "MESSAGE -> ", msg

  socket.on "join", (user) ->
    io.sockets.emit "message", {
      from : "Parrot"
      message : "User #{user} joined the chat!"
    }

server.listen(3300)
module.exports = app