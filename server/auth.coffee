passport = require('passport')
Conf = require('./conf')
TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy

serverHost = Conf.get("server:host")
serverPort = Conf.get("server:port")

# User serialization
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

# Login strategies
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

class Auth

  @configureApp: (app) ->
    app.use(passport.initialize())
    app.use(passport.session())

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
      Auth.whenAuthorized req, res, (user) ->
        res.json(200, user)

  @whenAuthorized = (req, res, callback) ->

    debugUser = Conf.get("debugUser")
    req.user = req.session.passport.user = debugUser if debugUser

    if !req.user
      res.send(401, 'Unauthorized');
    else
      callback(req.user)

module.exports = Auth