'use strict';

angular.module('app')
  .controller 'ChatController', ($scope, $routeParams, $sce) ->

    $scope.messages = []
    socket = io.connect()

    socket.on 'connect', () ->
      socket.on 'message', (msg) ->
        $scope.$apply () ->
          autoScrollAfter = shouldAutoScroll()
          addMessage(msg)
          autoScroll() if autoScrollAfter

          if !pageFocused
            unreadCount++
            updateUnreadCount()

      socket.emit "join", $routeParams.user

    addMessage = (msg) ->
      lastMessage = null
      msg.message = preParseMessage(msg.message)

      if $scope.messages.length > 0
        lastMessage = $scope.messages[ $scope.messages.length - 1 ]

      if lastMessage and lastMessage.from == msg.from and pageFocused
        lastMessage.date = msg.date
        lastMessage.message += "<br/>" + msg.message;
      else
        $scope.messages.push msg

    preParseMessage = (msg) ->
      url_pattern = /([a-z]([a-z]|\d|\+|-|\.)*):(\/\/(((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?((\[(|(v[\da-f]{1,}\.(([a-z]|\d|-|\.|_|~)|[!\$&'\(\)\*\+,;=]|:)+))\])|((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=])*)(:\d*)?)(\/(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*|(\/((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)|((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)|((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)){0})(\?((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\xE000-\xF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?/img

      # msg = msg.replace(url_pattern, "$&")
      msg = msg.replace url_pattern, (url) ->
        if url.match( /\.(jpg|jpeg|png|gif)$/i )
          return "<br/><img src='#{url}' /><br/>"

        return "<a href='#{url}' target='_blank'>#{url}</a>"

    $scope.parseMessage = (msg) ->
      $sce.trustAsHtml(msg)

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
      $(".message-text").focus()

    updateUnreadCount = () ->
      if unreadCount > 0
        document.title = "(#{ unreadCount }) Parrot";
      else
        document.title = "Parrot";

    drawLastMessageLine = () ->
      for msg, index in $scope.messages
        msg.lastUnread = ( index == $scope.messages.length - 1 )
