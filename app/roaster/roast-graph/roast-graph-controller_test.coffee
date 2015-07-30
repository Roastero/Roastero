###global describe, beforeEach, it, expect, inject, module###
'use strict'

describe 'RoastGraphCtrl', ->
  ctrl = undefined

  beforeEach module 'roaster'

  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    ctrl = $controller 'RoastGraphCtrl',
      $scope: scope

  it 'should have ctrlName as RoastGraphCtrl', ->
    expect(ctrl.ctrlName).toEqual 'RoastGraphCtrl'
