'use strict'

angular
  .module 'roastero'
  .config ($urlRouterProvider) ->
    $urlRouterProvider.otherwise '/home'
