'use strict';

angular.module('app')
  .filter 'nameFilter', () ->
    (input) ->
      input.split(" ")?[0]