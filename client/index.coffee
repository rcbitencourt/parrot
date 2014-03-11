'use strict'

angular.module('app', [
  'ngRoute'
])
  .config ($routeProvider, $httpProvider) ->

    $routeProvider
      .when '/:user',
        templateUrl: 'views/chat.tpl.html'
        controller: 'ChatController'
      .otherwise
        redirectTo: '/anonymous'


    $httpProvider.defaults.headers.common = { 'Content-Type' : 'application/json' }