{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonUnsubscribeForm', ->
  scope: {poll: '='}
  template: require('./poll_common_unsubscribe_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.toggle = submitForm $scope, $scope.poll,
      submitFn: $scope.poll.toggleSubscription
      flashSuccess: ->
        if $scope.poll.subscribed
          'poll_common_unsubscribe_form.subscribed'
        else
          'poll_common_unsubscribe_form.unsubscribed'
  ]
