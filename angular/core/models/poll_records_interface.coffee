angular.module('loomioApp').factory 'PollRecordsInterface', (BaseRecordsInterface, PollModel) ->
  class PollRecordsInterface extends BaseRecordsInterface
    model: PollModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      options['discussion_id'] = discussionKey
      @fetch
        params: options

    fetchClosedByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @fetch
        path: 'closed'
        params: options
