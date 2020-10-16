EventBus = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'pollMeetingChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_meeting_chart_panel.haml')
  controller: ['$scope', ($scope) ->

    $scope.totalFor = (option) ->
      _.reduce($scope.poll.latestStances(), (total, stance) ->
        scoreForStance = stance.scoreFor(option)
        total[scoreForStance] += 1
        total
      , [0, 0, 0])

    EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
      $scope.zone = zone
  ]
