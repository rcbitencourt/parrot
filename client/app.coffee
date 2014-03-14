'use strict'

angular.module('app', [
  'ngRoute'
])
  .config ($routeProvider, $httpProvider) ->

    $routeProvider
      .when '/',
        templateUrl: 'views/chat.tpl.html'
        controller: 'ChatController'
      .when '/login',
        templateUrl: 'views/login.tpl.html'
        controller: 'LoginController'
      .otherwise
        redirectTo: '/'

    $httpProvider.defaults.headers.common = { 'Content-Type' : 'application/json' }