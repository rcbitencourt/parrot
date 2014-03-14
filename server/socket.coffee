connect = require('connect')
cookie = require('cookie')
socketio = require('socket.io')
Conf = require('./conf')

serverMessage = (msg) ->
  {
    from : "Parrot"
    message : msg,
    date : new Date()
  }

class Socket

  @configureServer: (server, sessionStore) ->

    io = socketio.listen(server)

    io.configure () ->
      io.set 'authorization', (handshakeData, accept) ->

        if handshakeData.headers.cookie

          sessionSecret = Conf.get("server:sessionSecret")
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

module.exports = Socket