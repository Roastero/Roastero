###global describe, beforeEach, it, expect, inject, module###
'use strict'

describe 'roastGraph', ->
  scope = undefined
  element = undefined

  beforeEach module('roaster', 'roaster/roast-graph/roast-graph-directive.tpl.html')

  beforeEach inject ($compile, $rootScope) ->
    scope = $rootScope.$new()
    element = $compile(angular.element('<roast-graph></roast-graph>')) scope

  it 'should have correct text', ->
    scope.$apply()
    expect(element.isolateScope().roastGraph.name).toEqual 'roastGraph'
