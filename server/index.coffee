express = require('express')
connect = require('connect')
http = require('http')
cookie = require('cookie')
Conf = require('./conf')
Auth = require('./auth')
socketio = require('socket.io')
sessionStore = new express.session.MemoryStore();

app = express()
server = http.createServer(app)
io = socketio.listen(server)
serverPort = Conf.get("server:port")
sessionSecret = Conf.get("server:sessionSecret")

app.configure () ->
  # app.use(express.logger());
  app.use(express.cookieParser())
  app.use(express.urlencoded())
  app.use(express.json())
  app.use(express.session({ store: sessionStore, secret: sessionSecret, key: 'connect.sid' }))

app.use('/', express.static(__dirname + '/../client'))
Auth.configureApp(app)

app.get "/api/ping", (req, res) ->
  res.json(200, "pong! :]")

serverMessage = (msg) ->
  {
    from : "Parrot"
    message : msg,
    date : new Date()
  }

io.configure () ->
  io.set 'authorization', (handshakeData, accept) ->

    if handshakeData.headers.cookie

      handshakeData.cookie = cookie.parse(handshakeData.headers.cookie);
      sid = handshakeData.cookie['connect.sid']
      handshakeData.sessionID = connect.utils.parseSignedCookies(handshakeData.cookie, sessionSecret)['connect.sid']

      sessionStore.get handshakeData.sessionID, (err, session) ->
        if err
          return accept('Invalid session!', false)
        else if !session
          return accept('Session not found!', false)

        handshakeData.session = session
        accept(null, true)

    else
      return accept('No cookies found.', false)

io.sockets.on 'connection', (socket) ->
  # console.log "Socket connected: #{socket.id}"

  socket.on "join", () ->
    user = socket.handshake.session.passport?.user

    if user
      socket.set("user", user)
      io.sockets.emit "message", serverMessage( "Hey, <b>#{user.name}</b> have joined the room!" )

  socket.on "disconnect", () ->
    socket.get 'user', (err, user) ->
      if user
        io.sockets.emit "message", serverMessage( "User <b>#{user.name}</b> have left the room!" )

  socket.on "message", (msg) ->
    socket.get 'user', (err, user) ->
      if user
        msg.date = new Date()
        msg.from = user.name
        io.sockets.emit "message", msg
        # console.log "MESSAGE -> ", msg

server.listen(serverPort)
module.exports = app