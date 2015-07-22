'use strict'
###*
 # @ngdoc directive
 # @name roaster.directive:roastGraph
 # @restrict EA
 # @element

 # @description

 # @example
   <example module="roaster">
     <file name="index.html">
      <roast-graph></roast-graph>
     </file>
   </example>

###
class RoastGraph
  constructor: ($window, $sce) ->
    return {
      restrict: 'AE'
      scope:
        data: '='
        options: '='
        legend: '=?'
      templateUrl: 'roaster/roast-graph-directive.tpl.html'
      replace: false
      controllerAs: 'roastGraphDirective'
      controller: ->
        vm = @
        vm.name = 'roastGraphDirective'
      link: (scope, element, attrs) ->
        scope.LegendEnabled = true

        parent = element.parent()
        mainDiv = element.children()[0]
        chartDiv = $(mainDiv).children()[0]
        legendDiv = $(mainDiv).children()[1]

        popover = element.find('.roastGraphPop')
        popoverWidth = 0
        popoverHeight = 0
        chartArea = undefined
        popoverPos = false

        graph = new Dygraph(chartDiv, scope.data, scope.options)

        resize = () ->
          maxWidth = 0
          element.find('div.series').each ->
            itemWidth = $(this).width()
            maxWidth = Math.max(maxWidth, itemWidth)
            return
          element.find('div.series').each ->
            $(this).width maxWidth
            return
          legendHeight = element.find('div.legend').outerHeight(true)
          graph.resize parent.width(), parent.height() - legendHeight
          chartArea = $(chartDiv).offset()
          chartArea.bottom = chartArea.top + parent.height() - legendHeight
          chartArea.right = chartArea.left + parent.width()
          return

        dataUpdated = () ->
          options = scope.options
          if options == undefined
            options = {}
          options.file = scope.data
          options.highlightCallback = scope.highlightCallback
          options.unhighlightCallback = scope.unhighlightCallback
          if options.showPopover == undefined
            options.showPopover = true
          if scope.legend != undefined
            options.labelsDivWidth = 0
          graph.updateOptions options
          graph.resetZoom()
          resize()
          return

        legendUpdated = () ->
          # Clear the legend
          colors = graph.getColors()
          labels = graph.getLabels()
          scope.legendSeries = {}
          if scope.legend != undefined and scope.legend.dateFormat == undefined
            scope.legend.dateFormat = 'MMMM Do YYYY, h:mm:ss a'
          # If we want our own legend, then create it
          if scope.legend != undefined and scope.legend.series != undefined
            cnt = 0
            for key of scope.legend.series
              scope.legendSeries[key] = {}
              scope.legendSeries[key].color = colors[cnt]
              scope.legendSeries[key].label = scope.legend.series[key].label
              scope.legendSeries[key].format = scope.legend.series[key].format
              scope.legendSeries[key].visible = true
              scope.legendSeries[key].column = cnt
              cnt++
          resize()
          return

        optionsUpdated = (newOptions) ->
          graph.updateOptions newOptions
          resize()
          return

        scope.$watch 'data', dataUpdated, true
        scope.$watch 'legend', legendUpdated
        scope.$watch 'options', optionsUpdated, true

        scope.highlightCallback = (event, x, points, row) ->
          if !scope.options.showPopover
            return
          html = '<table><tr><th colspan=\'2\'>'
          if typeof moment == 'function' and scope.legend != undefined
            html += moment(x).format(scope.legend.dateFormat)
          else
            html += x
          html += '</th></tr>'
          angular.forEach points, (point) ->
            `var x`
            color = undefined
            label = undefined
            value = undefined
            if scope.legendSeries[point.name] != undefined
              label = scope.legendSeries[point.name].label
              color = 'style=\'color:' + scope.legendSeries[point.name].color + ';\''
              if scope.legendSeries[point.name].format
                value = point.yval.toFixed(scope.legendSeries[point.name].format)
              else
                value = point.yval
            else
              label = point.name
              color = ''
            html += '<tr ' + color + '><td>' + label + '</td>' + '<td>' + value + '</td></tr>'
            return
          html += '</table>'
          popover.html html
          popover.show()
          table = popover.find('table')
          popoverWidth = table.outerWidth(true)
          popoverHeight = table.outerHeight(true)
          # Provide some hysterises to the popup position to stop it flicking back and forward
          if points[0].x < 0.4
            popoverPos = false
          else if points[0].x > 0.6
            popoverPos = true
          x = undefined
          if popoverPos == true
            x = event.pageX - popoverWidth - 20
          else
            x = event.pageX + 20
          popover.width popoverWidth
          popover.height popoverHeight
          popover.animate {
            left: x + 'px'
            top: event.pageY - (popoverHeight / 2) + 'px'
          }, 20

        scope.unhighlightCallback = (event, a, b) ->
          if !scope.options.showPopover
            popover.hide()
            return

          # Check if the cursor is still within the chart area
          # If so, ignore this event.
          # This stops flickering if we get an even when the mouse covers the popover
          if event.pageX > chartArea.left and event.pageX < chartArea.right and event.pageY > chartArea.top and event.pageY < chartArea.bottom
            x = undefined
            if popoverPos == true
              x = event.pageX - popoverWidth - 20
            else
              x = event.pageX + 20
            popover.animate { left: x + 'px' }, 10
            return
          popover.hide()
          return

        scope.seriesLine = (series) ->
          $sce.trustAsHtml '<svg height="14" width="20"><line x1="0" x2="16" y1="8" y2="8" stroke="' + series.color + '" stroke-width="3" /></svg>'

        scope.seriesStyle = (series) ->
          if series.visible
            return { color: series.color }
          {}

        scope.selectSeries = (series) ->
          series.visible = !series.visible
          graph.setVisibility series.column, series.visible
          return

        resize()
        w = angular.element($window)
        w.bind 'resize', ->
          resize()
          return
        return

        ###jshint unused:false ###
        ###eslint "no-unused-vars": [2, {"args": "none"}]###
    }

RoastGraph.$inject = ['$window', '$sce']

angular
  .module 'roaster'
  .directive 'roastGraph', RoastGraph
