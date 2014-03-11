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

          if !pageFocused
            unreadCount++
            updateUnreadCount()

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

    pageFocused = true
    unreadCount = 0

    $(window).on "blur", (e) ->
      pageFocused = false
      drawLastMessageLine()

    $(window).on "focus", (e) ->
      unreadCount = 0
      pageFocused = true
      updateUnreadCount()

    updateUnreadCount = () ->
      if unreadCount > 0
        document.title = "(#{ unreadCount }) Parrot";
      else
        document.title = "Parrot";

    drawLastMessageLine = () ->
      for msg, index in $scope.messages
        msg.lastUnread = ( index == $scope.messages.length - 1 )
