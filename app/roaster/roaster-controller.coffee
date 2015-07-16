'use strict'

###*
 # @ngdoc object
 # @name roaster.controller:RoasterCtrl

 # @description

###
class RoasterCtrl
  constructor: ->
    @ctrlName = 'RoasterCtrl'

angular
  .module('roaster')
  .controller 'RoasterCtrl', RoasterCtrl
