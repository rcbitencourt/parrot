'use strict'

angular.module('app')
  .service 'AuthService', ($http) ->

    me: () ->
      $http.get('auth/me')