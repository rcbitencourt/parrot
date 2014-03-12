express = require('express')
http = require('http')
socketio = require('socket.io')

app = express()
server = http.createServer(app)
io = socketio.listen(server)

app.use('/', express.static(__dirname + '/../client'));

app.get "/api/ping", (req, res) ->
  res.json(200, "pong! :]")

serverMessage = (msg) ->
  {
    from : "Parrot"
    message : msg,
    date : new Date()
  }

io.sockets.on 'connection', (socket) ->
  # console.log "Socket connected: #{socket.id}"

  socket.on "join", (user) ->
    socket.set("user", user)
    io.sockets.emit "message", serverMessage( "Hey, <b>#{user}</b> have joined the room!" )

  socket.on "disconnect", () ->
    socket.get 'user', (err, user) ->
      io.sockets.emit "message", serverMessage( "User <b>#{user}</b> have left the room!" )

  socket.on "message", (msg) ->
    msg.date = new Date()
    io.sockets.emit "message", msg
    # console.log "MESSAGE -> ", msg

server.listen(3300)
module.exports = app