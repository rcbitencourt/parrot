express = require('express')
http = require('http')
Conf = require('./conf')
Socket = require('./socket')
Auth = require('./auth')
sessionStore = new express.session.MemoryStore();

app = express()
server = http.createServer(app)
serverPort = Conf.get("server:port")
sessionSecret = Conf.get("server:sessionSecret")

# Configure server
# app.use(express.logger());
app.use(express.cookieParser())
app.use(express.urlencoded())
app.use(express.json())
app.use(express.session({ store: sessionStore, secret: sessionSecret, key: 'connect.sid' }))
Auth.configureApp(app)
Socket.configureServer(server, sessionStore)

# Routes
app.use('/', express.static(__dirname + '/../client'))

app.get "/api/ping", (req, res) ->
  res.json(200, "pong! :]")

server.listen(serverPort)
module.exports = app