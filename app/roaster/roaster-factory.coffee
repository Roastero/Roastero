'use strict'

###*
 # @ngdoc service
 # @name roaster.factory:Roaster

 # @description

###
angular
  .module 'roaster'
  .factory 'Roaster', () ->
    RoasterBase = {}
    RoasterBase.someMethod = ->
      'Roaster'

    RoasterBase
