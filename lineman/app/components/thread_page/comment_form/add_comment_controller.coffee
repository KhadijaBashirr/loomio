angular.module('loomioApp').controller 'AddCommentController', ($scope, Records, CurrentUser) ->
  $scope.comment = Records.comments.initialize(discussion_id: $scope.discussion.id)
  $scope.currentUser = CurrentUser

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id
    $scope.expand()
