###global describe, beforeEach, it, expect, inject, module###
'use strict'

describe 'RoasterCtrl', ->
  ctrl = undefined

  beforeEach module 'roaster'

  beforeEach inject ($rootScope, $controller) ->
    ctrl = $controller 'RoasterCtrl'

  it 'should have ctrlName as RoasterCtrl', ->
    expect(ctrl.ctrlName).toEqual 'RoasterCtrl'

