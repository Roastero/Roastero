###global describe, beforeEach, it, expect, inject, module###
'use strict'

describe 'RoastGraphCtrl', ->
  ctrl = undefined

  beforeEach module 'roaster'

  beforeEach inject ($rootScope, $controller) ->
    ctrl = $controller 'RoastGraphCtrl'

  it 'should have ctrlName as RoastGraphCtrl', ->
    expect(ctrl.ctrlName).toEqual 'RoastGraphCtrl'

