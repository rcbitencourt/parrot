'use strict';

angular.module('app')
  .controller 'ChatController', ($scope, $sce, $location, AuthService) ->

    $scope.messages = []
    $scope.user = {}

    AuthService.me()
      .success (user) -> $scope.user = user
      .error (message, code) -> $location.path("/login")

    socket = io.connect null, {
      transports: ['websocket', 'htmlfile', 'xhr-multipart', 'xhr-polling', 'jsonp-polling']#, 'flashsocket']
    }

    socket.on 'connect', () ->
      socket.emit "join"

    socket.on 'message', (msg) ->
      $scope.$apply () ->

        autoScrollAfter = shouldAutoScroll()
        addMessage(msg)
        autoScroll() if autoScrollAfter

        if !pageFocused
          unreadCount++
          updateUnreadCount()

    addMessage = (msg) ->
      lastMessage = null
      msg.message = preParseMessage(msg.message)

      if $scope.messages.length > 0
        lastMessage = $scope.messages[ $scope.messages.length - 1 ]

      if lastMessage and lastMessage.from.name == msg.from.name and lastMessage.from.photo == msg.from.photo and !lastMessage.lastUnread
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

      msg = msg.replace(/\n/g, "<br/>")

    $scope.parseMessage = (msg) ->
      $sce.trustAsHtml(msg)

    $scope.messageKeyDown = (e) ->
      if e.keyCode == 13

        socket.emit "message", {
          message : $scope.message
        }

        e.preventDefault()
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

    alternateCount = 0
    alternateInterval = null

    alternateTitle = () ->

      clearInterval( alternateInterval )
      alternateCount = 0

      alternateInterval = setInterval () ->
        if alternateCount < 6
          if document.title.indexOf("Parrot") > -1
            document.title = "(#{ unreadCount }) <--"
          else
            document.title = "(#{ unreadCount }) Parrot"

        alternateCount++

        if alternateCount > 20
          alternateCount = 0
      , 1000

    updateUnreadCount = () ->
      if unreadCount > 0
        document.title = "(#{ unreadCount }) Parrot";
        alternateTitle()
      else
        clearInterval( alternateInterval )
        document.title = "Parrot";

    drawLastMessageLine = () ->
      for msg, index in $scope.messages
        msg.lastUnread = ( index == $scope.messages.length - 1 )
