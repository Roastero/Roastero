'use strict'

angular
  .module 'roaster'
  .config ($stateProvider) ->
    $stateProvider
      .state 'roaster',
        url: '/roaster'
        templateUrl: 'roaster/roaster.tpl.html'
        controller: 'RoasterCtrl'
        controllerAs: 'roaster'
