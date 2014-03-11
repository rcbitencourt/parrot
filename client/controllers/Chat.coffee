'use strict';

angular.module('app')
  .controller 'ChatController', ($scope, $routeParams) ->

    $scope.messages = [{
      from : "Parrot",
      message : "Hey #{$routeParams.user}! Welcome to Parrot ;]"
    }]

    socket = io.connect('http://localhost:3300')

    socket.on 'connect', () ->
      socket.on 'message', (msg) ->
        $scope.$apply () ->
          autoScrollAfter = shouldAutoScroll()
          $scope.messages.push msg
          autoScroll() if autoScrollAfter

    $scope.messageKeyDown = (e) ->
      if e.keyCode == 13

        socket.emit "message", {
          from : $routeParams.user,
          message : $scope.message
        }

        $scope.message = ""

    shouldAutoScroll = () ->
      msgContainer = $(".messages");
      return msgContainer.scrollTop() + msgContainer.height() + 10 >= msgContainer[0].scrollHeight

    autoScrollTimeout = null

    autoScroll = () ->
      clearTimeout(autoScrollTimeout)
      autoScrollTimeout = setTimeout () ->
        msgContainer = $(".messages");
        msgContainer.scrollTop( msgContainer[0].scrollHeight )
      , 200