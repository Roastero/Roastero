###global describe, beforeEach, it, expect, inject, module###
'use strict'

describe 'Roaster', ->
  factory = undefined
  $websocketBackend = undefined

  beforeEach module 'roaster'


  beforeEach inject (Roaster) ->
    factory = Roaster

  beforeEach angular.mock.module 'ngWebSocket', 'ngWebSocketMock'

  beforeEach inject (_$websocketBackend_) ->
    $websocketBackend = _$websocketBackend_
    $websocketBackend.mock()
    $websocketBackend.expectConnect 'wss://localhost.roastero.com:3201/roaster'
    $websocketBackend.expectSend {data: JSON.stringify {test: true}}

  # # socket.onMessage()
  # it 'should trigger with every message from the websocket', ->
  #   expect(factory.someValue).toEqual 'Roaster'
  #
  # it 'should have someMethod return Roaster', ->
  #   expect(factory.someMethod()).toEqual 'Roaster'
