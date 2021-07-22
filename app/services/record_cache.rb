class RecordCache
  attr_accessor :scope
  attr_accessor :exclude_types
  attr_accessor :user_ids

  def initialize
    @scope = {}
    @exclude_types = []
    @user_ids = []
  end

  def fetch(key_or_keys, id)
    (scope.dig(*Array(key_or_keys)) || {}).fetch(id) do
      if block_given?
        yield
      else
        raise "scope missing preloaded model: #{key_or_keys} #{id}"
      end
    end
  end

  def self.for_groups(group_ids, user_id)
    obj = new
    all_group_ids = obj.add_groups_by_id(group_ids)
    obj.add_memberships_by_group_id(all_group_ids, user_id)
    obj.add_users_by_id
    puts "!!!!!!group colleciton loaded!!!!!!!!!"
    obj
  end

  def self.for_events(collection, discussion_id, current_user, exclude_types)
    obj = new
    obj.exclude_types = exclude_types
    discussion_ids = [discussion_id]
    group_ids = Discussion.where(id: discussion_ids).pluck(:group_id)
    comment_ids = collection.where(eventable_type: 'Comment').except(:order).pluck(:eventable_id)
    stance_ids = collection.where(eventable_type: 'Stance').except(:order).pluck(:eventable_id)

    all_group_ids = obj.add_groups_by_id(group_ids)
    poll_ids = obj.add_polls_by_discussion_id(discussion_ids)
    obj.add_events_by_id(collection.pluck(:parent_id))
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_groups_by_id(all_group_ids)
    obj.add_memberships_by_group_id(all_group_ids, current_user.id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_comments_by_id(comment_ids)
    obj.add_stances_by_id(stance_ids)
    obj.add_stances_by_poll_id(poll_ids, current_user.id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, current_user.id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    obj.add_users_by_id
    puts "!!!!!!event colleciton loaded!!!!!!!!!"
    obj
  end

  def self.for_discussions(collection, current_user, exclude_types)
    obj = new
    obj.exclude_types = exclude_types
    discussion_ids = collection.map(&:id)
    all_group_ids = obj.add_groups_by_id(collection.map(&:group_id))
    poll_ids = obj.add_polls_by_discussion_id(discussion_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_memberships_by_group_id(all_group_ids, current_user.id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_stances_by_poll_id(poll_ids, current_user.id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, current_user.id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    obj.add_users_by_id
    puts "!!!!!!discussion colleciton loaded!!!!!!!!!"
    obj
  end

  def self.for_polls(collection, current_user, exclude_types)
    obj = new
    obj.exclude_types = exclude_types
    poll_ids = collection.map(&:id)
    discussion_ids = collection.map(&:discussion_id).compact
    all_group_ids = obj.add_groups_by_id(collection.map(&:group_id))
    obj.add_polls_by_id(poll_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_memberships_by_group_id(all_group_ids, current_user.id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_stances_by_poll_id(poll_ids, current_user.id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, current_user.id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    obj.add_users_by_id
    puts "!!!!!!poll colleciton loaded!!!!!!!!!"
    obj
  end

  def self.for_stances(collection, current_user, exclude_types)
    obj = new
    obj.exclude_types = exclude_types
    stance_ids = collection.map(&:id)
    poll_ids = collection.map(&:poll_id).uniq.compact
    obj.add_polls_by_id(poll_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_stance_choices_by_stance_id(stance_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_users_by_id
    puts "!!!!!!stance colleciton loaded!!!!!!!!!"
    obj
  end

  def add_users_by_id
    scope[:users_by_id] ||= {}
    User.where(id: user_ids.compact.uniq).each do |user|
      scope[:users_by_id][user.id] = user
    end
  end

  # in controller
  # ScopeService.add_groups_by_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def add_groups_by_id(group_ids)
    return [] if group_ids.empty?
    return [] if exclude_types.include?('group')
    scope[:groups_by_id] ||= {}
    return [] if group_ids.empty?
    ids = []
    parent_ids = []
    Group.where(id: group_ids).each do |group|
      ids.push group.id
      user_ids.push group.creator_id
      parent_ids.push group.parent_id if group.parent_id
      scope[:groups_by_id][group.id] = group
    end
    ids.concat add_groups_by_id(parent_ids)
  end

  def add_subscriptions_by_group_id(group_ids)
    return [] if group_ids.empty?
    return [] if exclude_types.include?('subscription')
    scope[:subscriptions_by_group_id] ||=  {}
    Group.includes(:subscription).where(id: group_ids).each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription
    end
  end

  # in controller
  # ScopeService.add_my_memberships_by_group_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def add_memberships_by_group_id(group_ids, user_id)
    return [] if group_ids.empty?
    return [] if exclude_types.include?('membership')
    scope[:memberships_by_group_id] ||= {}
    ids = []
    Membership.where(group_id: group_ids, user_id: user_id).each do |m|
      ids.push m.id
      user_ids.push m.user_id
      user_ids.push m.inviter_id if m.inviter_id
      scope[:memberships_by_group_id][m.group_id] = m
    end
    ids
  end

  def add_polls_by_discussion_id(discussion_ids)
    return [] if discussion_ids.empty?
    return [] if exclude_types.include?('poll')
    scope[:polls_by_discussion_id] ||= {}
    scope[:polls_by_id] ||= {}
    ids = []
    Poll.where(discussion_id: discussion_ids).each do |poll|
      ids.push poll.id
      user_ids.push poll.author_id
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_discussion_id][poll.discussion_id] ||= []
      scope[:polls_by_discussion_id][poll.discussion_id].push poll
    end
    ids
  end

  def add_events_by_id(event_ids)
    return [] if event_ids.empty?
    return [] if exclude_types.include?('event')
    scope[:events_by_id] ||= {}
    parent_ids = []
    Event.where(id: event_ids).each do |event|
      user_ids.push event.user_id if event.user.id
      parent_ids.push(event.parent_id) if event.parent_id
      scope[:events_by_id][event.id] = event
    end
    add_events_by_id(parent_ids) if parent_ids.any?
    parent_ids
  end

  def add_comments_by_id(comment_ids)
    return [] if comment_ids.empty?
    return [] if exclude_types.include?('comment')
    scope[:comments_by_id] ||= {}
    parent_ids = []
    Comment.where(id: comment_ids).each do |comment|
      user_ids.push comment.user_id
      scope[:comments_by_id][comment.id] = comment
      parent_ids.push comment.parent_id if comment.parent_id
    end
    add_comments_by_id(parent_ids) if parent_ids.any?
  end

  def add_outcomes_by_poll_id(poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('outcome')
    scope[:outcomes_by_id] ||= {}
    scope[:outcomes_by_poll_id] ||= {}
    Outcome.where(poll_id: poll_ids).each do |outcome|
      user_ids.push outcome.author_id
      scope[:outcomes_by_id][outcome.id] = outcome
      scope[:outcomes_by_poll_id][outcome.poll_id] = outcome if outcome.latest
    end
  end

  def add_polls_by_id(poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('poll')
    scope[:polls_by_id] ||= {}
    Poll.where(id: poll_ids).each do |poll|
      user_ids.push poll.author_id
      scope[:polls_by_id][poll.id] = poll
    end
  end

  def add_poll_options_by_poll_id(poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('poll_option')
    scope[:poll_options_by_poll_id] ||= {}
    PollOption.where(poll_id: poll_ids).each do |poll_option|
      scope[:poll_options_by_poll_id][poll_option.poll_id] ||= []
      scope[:poll_options_by_poll_id][poll_option.poll_id].push(poll_option)
    end
  end

  def add_stances_by_id(stance_ids)
    return [] if stance_ids.empty?
    return [] if exclude_types.include?('stance')
    scope[:stances_by_id] ||= {}
    scope[:users_by_id] ||= {}
    Stance.where(id: stance_ids).each do |stance|
      user_ids.push stance.participant_id
      scope[:stances_by_id][stance.id] = stance
    end
  end

  def add_stance_choices_by_stance_id(stance_ids)
    return [] if stance_ids.empty?
    return [] if exclude_types.include?('stance_choice')
    scope[:stance_choices_by_stance_id] ||= {}
    StanceChoice.where(stance_id: stance_ids).each do |choice|
      scope[:stance_choices_by_stance_id][choice.stance_id] ||= []
      scope[:stance_choices_by_stance_id][choice.stance_id].push choice
    end
  end

  def add_stances_by_poll_id(poll_ids, user_id)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('stance')
    scope[:stances_by_id] ||= {}
    scope[:stances_by_poll_id] ||= {}
    user_ids.push user_id
    ids = []
    Stance.where(poll_id: poll_ids, participant_id: user_id).each do |stance|
      ids.push stance
      scope[:stances_by_id][stance.id] = stance
      scope[:stances_by_poll_id][stance.poll_id] = stance
    end
    ids
  end

  def add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    return [] if discussion_ids.empty?
    # return [] if exclude_types.include?('discussion')
    scope[:discussion_readers_by_discussion_id] ||= {}
    ids = []
    user_ids.push user_id
    DiscussionReader.
                     where(discussion_id: discussion_ids, user_id: user_id).each do |dr|
      ids.push dr.id
      scope[:discussion_readers_by_discussion_id][dr.discussion_id] = dr
    end
    ids
  end

  def add_events_by_kind_and_discussion_id(kind, discussion_ids)
    return [] if discussion_ids.empty?
    return [] if exclude_types.include?('event')
    scope[:events_by_discussion_id] ||= {}
    scope[:events_by_discussion_id][kind] ||= {}
    ids = []
    Event.where(kind: kind, eventable_id: discussion_ids).each do |event|
      user_ids.push event.user_id
      scope[:events_by_discussion_id][kind][event.eventable_id] = event
    end
    ids
  end

  def add_events_by_kind_and_poll_id(kind, poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('event')
    scope[:events_by_poll_id] ||= {}
    scope[:events_by_poll_id][kind] ||= {}
    ids = []
    Event.where(kind: kind, eventable_id: poll_ids).each do |event|
      user_ids.push event.user_id
      scope[:events_by_poll_id][kind][event.eventable_id] = event
    end
    ids
  end

  def add_discussions_by_id(discussion_ids)
    return [] if discussion_ids.empty?
    scope[:discussions_by_id] ||= {}
    Discussion.where(id: discussion_ids).each do |d|
      user_ids.push d.author_id
      scope[:discussions_by_id][d.id] = d
    end
  end
end
