'use strict'

###*
 # @ngdoc object
 # @name roaster.controller:RoastGraphCtrl

 # @description

###
class RoastGraphCtrl
  constructor: (@$scope, @$rootScope) ->
    @ctrlName = 'RoastGraphCtrl'

    @graph =
      data: []
      options: labels: [
        'x'
        'A'
        'B'
      ]
      legend: series:
        A: label: 'Series A'
        B:
          label: 'Series B'
          format: 3

    base_time = Date.parse('2008/07/01')
    num = 24 * 0.25 * 365
    i = 0
    while i < num
      @graph.data.push [
        new Date(base_time + i * 3600 * 1000)
        i + 50 * i % 60
        i * (num - i) * 4.0 / num
      ]
      i++

    @coords = []
    @pointsOfInterest = []

    @setCoords = (coords) ->
      @coords.concat coords
      return

    @$rootScope.$on 'roastGraph_setCoords', (event, listOfCoordObjects) ->
      @setCoords(listOfCoordObjects)
      return

    @addCoord = (time, temp) ->
      @coords.push {'time': time, 'temp': temp}
      return

    @$rootScope.$on 'roastGraph_addCoord', (event, time, temp) ->
      @addCoord(time, temp)
      return

    @getCoords = () ->
      return @coords

    @$rootScope.$on 'roastGraph_getCoords', (event) ->
      coords = @getCoords()
      @$rootScope.emit 'roastGraph_coords', coords
      return

    @setPointsOfInterest = (pointsOfInterest) ->
      @pointsOfInterest.concat pointsOfInterest
      return

    @$rootScope.$on 'roastGraph_setPointsOfInterest', (event, pointsOfInterest) ->
      @setPointsOfInterest pointsOfInterest
      return

    @addPointOfInterest = (time, note) ->
      @pointsOfInterest.push {'time': time, 'note': note}
      return

    @$rootScope.$on 'roastGraph_addPointOfInterest', (event, time, note) ->
      @addPointOfInterest time, note
      return

    @clear = () ->
      @coords = []
      @pointsOfInterest = []
      return

    @$rootScope.$on 'roastGraph_clear', () ->
      @clear()


RoastGraphCtrl.$inject = ["$scope", "$rootScope"]

angular
  .module('roaster')
  .controller 'RoastGraphCtrl', RoastGraphCtrl
