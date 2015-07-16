###global describe, beforeEach, it, expect, inject, module###
'use strict'

describe 'Roaster', ->
  factory = undefined

  beforeEach module 'roaster'

  beforeEach inject (Roaster) ->
    factory = Roaster

  it 'should have someValue be Roaster', ->
    expect(factory.someValue).toEqual 'Roaster'

  it 'should have someMethod return Roaster', ->
    expect(factory.someMethod()).toEqual 'Roaster'
