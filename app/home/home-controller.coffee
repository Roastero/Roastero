'use strict'

###*
 # @ngdoc object
 # @name home.controller:HomeCtrl

 # @description

###
class HomeCtrl
  constructor: ->
    @ctrlName = 'HomeCtrl'

angular
  .module('home')
  .controller 'HomeCtrl', HomeCtrl
