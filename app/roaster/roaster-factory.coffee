'use strict'

###*
 # @ngdoc service
 # @name roaster.factory:Roaster

 # @description

###
angular
  .module 'roaster'
  .factory 'Roaster', ($scope, $websocket) ->
    RoasterBase = {}
    RoasterBase.messages = []
    RoasterBase.lastStandardMessage = {}
    RoasterBase.socket = $websocket 'wss://localhost.roastero.com:3201/roaster'

    # Trigger on every message received by socket
    RoasterBase.socket.onMessage (message) ->
      parsedMessage = JSON.parse message.data

      # Push message data onto array for later comparison
      RoasterBase.messages.push parsedMessage

      # Do stuff with the message contents
      unpackMessage parsedMessage

      # Check if standard message
      if isStandardMessage parsedMessage
        RoasterBase.lastStandardMessage = parsedMessage

      # Keep messages array from continually growing
      if RoasterBase.messages.length > 10
        RoasterBase.messages.shift()

      return

    # Log to console when there's an error with the socket and
    # broadcast a message
    RoasterBase.socket.onError (error) ->
        # This may need to be changed to rootScope but I'm not sure if it's
        # necessary yet
        $scope.broadcast 'roaster_socketError', error
        console.log 'roaster_socketError', error

    # I don't think this should ever happen, Lets log if it ever does
    RoasterBase.socket.onClose (event) ->
      $scope.broadcast 'roaster_socketClosed', event
      console.log 'roaster_socketClosed', event

    # Triggered when connected to websocket
    RoasterBase.socket.onOpen () ->
      $scope.broadcast 'roaster_socketConnected'
      console.log 'roaster_socketConnected' # Just for debugging

    unpackMessage = (message) ->
      if message.roasterInformation?
        loadRoasterInformation message

      if message.history?
        loadRoastHistory message

      # Checks for data that has changed since last message
      if RoasterBase.lastStandardMessage?
        broadcastChangedData message, RoasterBase.lastStandardMessage

      # Broadcast on all data (First Standard message)
      broadcastAllData message

      return

    isStandardMessage = (message) ->
      if message.temp? and message.totalTime? and message.fanSpeed? and
      message.sectionTime? and message.status? and message.connectionStatus?
        return true
      else
        return false

    loadRoastHistory = (message) ->
      # TODO
      return

    broadcastChangedData = (currentMessage, previousMessage) ->
      if currentMessage.fanSpeed != previousMessage.fanSpeed
        $scope.broadcast 'roaster_fanSpeedChanged', currentMessage.fanSpeed

      if currentMessage.status != previousMessage.status
        $scope.broadcast 'roaster_statusChanged', currentMessage.status

      if currentMesage.targetTemp != previousMessage.targetTemp
        $scope.broadcast 'roaster_targetTempChanged', currentMesage.targetTemp

      if currentMessage.sectionNumber != previousMessage.sectionNumber
        $scope.broadcast 'roaster_sectionChanged', currentMesage.sectionNumber

      return

    broadcastAllData = (message) ->
      # Send out roast data
      $scope.broadcast 'roaster_roastData', message.sectionTime,
      message.totalTime, message.currentTemp
      return

    RoasterBase.setFan = (speed) ->
      RoasterBase.socket.send JSON.stringify
        fanSpeed: speed
      return

    RoasterBase.setTemperature = (temp) ->
      RoasterBase.socket.send JSON.stringify
        targetTemp: temp
      return

    RoasterBase.setSectionTime = (time) ->
      RoasterBase.socket.send JSON.stringify
        sectionTime: time
      return

    RoasterBase.requestCurrentRoastHistory = () ->
      RoasterBase.socket.send JSON.stringify
        requestHistory: true
      return

    RoasterBase.sendRecipe = (recipeJSON) ->
      RoasterBase.socket.send JSON.stringify
        recipe: recipeJSON
      return

    RoasterBase.stopRoast = () ->
      RoasterBase.socket.send JSON.stringify
        status: 'Stopped'
      return

    RoasterBase.startRoast = () ->
      RoasterBase.socket.send JSON.stringify
        status: 'Started'
      return

    RoasterBase.coolRoast = () ->
      RoasterBase.socket.send JSON.stringify
        status: 'Cooling'
      return

    RoasterBase.changeSection = (sectionNumber) ->
      RoasterBase.socket.send JSON.stringify
        sectionNumber: sectionNumber
      return

    RoasterBase.requestCurrentRecipe = () ->
      RoasterBase.socket.send JSON.stringify
        recipe: 'request'
      return

    RoasterBase.requestRoasterInformation = () ->
      RoasterBase.socket.send JSON.stringify
        roasterInformation: true
      return

    return RoasterBase
