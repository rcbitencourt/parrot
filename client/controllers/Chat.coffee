'use strict';

angular.module('app')
  .controller 'ChatController', ($scope, $routeParams) ->

    $scope.messages = []
    socket = io.connect()

    socket.on 'connect', () ->
      socket.on 'message', (msg) ->
        $scope.$apply () ->
          autoScrollAfter = shouldAutoScroll()
          $scope.messages.push msg
          autoScroll() if autoScrollAfter

      socket.emit "join", $routeParams.user

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