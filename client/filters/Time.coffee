'use strict';

angular.module('app')
  .filter 'time', () ->
    (input) ->
      moment(input, "YYYY-MM-DDTHH:mm:ss.SSSSZ").format('HH:mm')