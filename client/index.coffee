'use strict'

angular.module('app', [
  'ngRoute'
])
  .config ($routeProvider, $httpProvider) ->

    $routeProvider
      .when '/',
        templateUrl: 'views/main.tpl.html'
        controller: 'MainController'

    $httpProvider.defaults.headers.common = { 'Content-Type' : 'application/json' }