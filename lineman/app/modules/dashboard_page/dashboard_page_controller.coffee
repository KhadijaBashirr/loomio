angular.module('loomioApp').controller 'DashboardPageController', ($scope, Records) ->

  $scope.page = {}
  $scope.perPage = 25

  $scope.refresh = (options = {}) ->
    options['filter'] = $scope.filter
    switch $scope.sort
      when 'date'
        options['per'] = $scope.perPage
        options['from'] = $scope.page[$scope.filter] = $scope.page[$scope.filter] || 0
        $scope.page[$scope.filter] = $scope.page[$scope.filter] + $scope.perPage
        Records.discussions.fetchInboxByDate  options
      when 'group'
        Records.discussions.fetchInboxByGroup options

  $scope.setOptions = (options = {}) ->
    $scope.filter = options['filter'] if options['filter']
    $scope.sort   = options['sort']   if options['sort']
    $scope.refresh()
  $scope.setOptions sort: 'group', filter: 'all'

  $scope.dashboardDiscussions = ->
    window.Loomio.currentUser.inboxDiscussions()

  $scope.dashboardGroups = ->
    window.Loomio.currentUser.groups()

  $scope.footerReached = ->
    return false if $scope.loadingDiscussions
    $scope.loadingDiscussions = true
    $scope.refresh().then ->
      $scope.loadingDiscussions = false

  $scope.unread = (discussion) ->
    discussion.isUnread() or $scope.filter != 'unread'


  $scope.lastInboxActivity = (discussion) ->
    -discussion.lastInboxActivity()

  $scope.startOfDay = ->
    moment().startOf('day').clone()

  $scope.today = (discussion) ->
    discussion.lastInboxActivity().isAfter $scope.startOfDay()

  $scope.yesterday = (discussion) ->
    discussion.lastInboxActivity().isBetween($scope.startOfDay().subtract(1, 'day'), $scope.startOfDay())

  $scope.thisWeek = (discussion) ->
    discussion.lastInboxActivity().isBetween($scope.startOfDay().subtract(1, 'week'), $scope.startOfDay().subtract(1, 'day'))

  $scope.thisMonth = (discussion) ->
    discussion.lastInboxActivity().isBetween($scope.startOfDay().subtract(1, 'month'), $scope.startOfDay().subtract(1, 'week'))

  $scope.older = (discussion) ->
    discussion.lastInboxActivity().isBefore($scope.startOfDay().subtract(1, 'month'))

  $scope.anyToday = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.today(discussion) and $scope.unread(discussion)

  $scope.anyYesterday = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.yesterday(discussion) and $scope.unread(discussion)

  $scope.anyThisWeek = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.thisWeek(discussion) and $scope.unread(discussion)

  $scope.anyThisMonth = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.thisMonth(discussion) and $scope.unread(discussion)

  $scope.anyOlder = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.older(discussion) and $scope.unread(discussion)

  $scope.anyThisGroup = (group) ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      discussion.groupId == group.id and $scope.unread(discussion)