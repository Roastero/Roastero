'use strict'

# States setup with Multiple Named Views for more information check out this
# link: https://scotch.io/tutorials/angular-routing-using-ui-router

angular
  .module 'roaster'
  .config ($stateProvider) ->
    $stateProvider
      .state 'roaster',
        url: '/roaster'
        controller: 'RoasterCtrl'
        controllerAs: 'roaster'
        views:
          '':
            templateUrl: 'roaster/roaster.tpl.html'

          'roastGraph@roaster':
            templateUrl: 'roaster/roast-graph/roast-graph-view.tpl.html'
            controller: 'RoastGraphCtrl'
            controllerAs: 'RoastGraphCtrl'
    return
