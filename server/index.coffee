express = require('express')
connect = require('connect')
http = require('http')
Conf = require('./conf')
cookie = require('cookie')
socketio = require('socket.io')
passport = require('passport')
TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
sessionStore = new express.session.MemoryStore();

app = express()
server = http.createServer(app)
io = socketio.listen(server)
serverHost = Conf.get("server:host")
serverPort = Conf.get("server:port")
sessionSecret = Conf.get("server:sessionSecret")

passport.serializeUser (user, done) ->

  profile = {
    name : user.displayName
  }

  if user.profileUrl?.indexOf('facebook') > -1
    profile.photo = "http://graph.facebook.com/#{ user.id }/picture?type=large"
  else
    profile.photo = user.photos[0]?.value

  done null, profile

passport.deserializeUser (user, done) ->
  done null, user

passport.use new TwitterStrategy({
    consumerKey: Conf.get("twitter:consumerKey")
    consumerSecret: Conf.get("twitter:consumerSecret")
    callbackURL: "#{serverHost}:#{serverPort}/auth/twitter/callback"
  },
  (token, tokenSecret, profile, done) ->
    process.nextTick () ->
      return done(null, profile)
)

passport.use new FacebookStrategy({
    clientID: Conf.get("facebook:clientID")
    clientSecret: Conf.get("facebook:clientSecret")
    callbackURL: "#{serverHost}:#{serverPort}/auth/facebook/callback"
  },
  (accessToken, refreshToken, profile, done) ->
    process.nextTick () ->
      return done(null, profile)
)

whenAuthorized = (req, res, callback) ->

  debugUser = Conf.get("debugUser")
  req.user = req.session.passport.user = debugUser if debugUser

  if !req.user
    res.send(401, 'Unauthorized');
  else
    callback(req.user)

app.configure () ->
  # app.use(express.logger());
  app.use(express.cookieParser())
  app.use(express.urlencoded())
  app.use(express.json())
  app.use(express.session({ store: sessionStore, secret: sessionSecret, key: 'connect.sid' }))

  app.use(passport.initialize())
  app.use(passport.session())

app.use('/', express.static(__dirname + '/../client'))

app.get('/auth/twitter', passport.authenticate('twitter'))
app.get('/auth/twitter/callback',
  passport.authenticate('twitter', {
    successRedirect: '/'
    failureRedirect: '/'
  })
)

app.get('/auth/facebook', passport.authenticate('facebook'))
app.get('/auth/facebook/callback',
  passport.authenticate('facebook', {
    successRedirect: '/'
    failureRedirect: '/'
  })
)

app.get "/auth/me", (req, res) ->
  whenAuthorized req, res, (user) ->
    res.json(200, user)

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
    user = socket.handshake.session.passport.user

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