class ApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  def scope
    super || {}
  end

  def poll
    cache_fetch(:polls_by_id, object.poll_id)
  end

  def group
    cache_fetch(:groups_by_id, object.group_id) { nil }
  end

  def discussion
    cache_fetch(:discussions_by_id, object.discussion_id) { nil }
  end

  def author
    cache_fetch(:users_by_id, object.author_id)
  end

  def actor
    cache_fetch(:users_by_id, object.actor_id) { nil }
  end

  def user
    cache_fetch(:users_by_id, object.user_id) { nil }
  end

  def inviter
    cache_fetch(:users_by_id, object.inviter_id) { nil }
  end

  def creator
    raise "this aint used is it?"
    cache_fetch(:users_by_id, object.creator_id) { nil }
  end

  def self.hide_when_discarded(names)
    Array(names).each do |name|
      define_method name do
        object.discarded_at ? nil : object.send(name)
      end
    end
  end

  def cache_fetch(key_or_keys, id, &block)
    scope[:cache].fetch(key_or_keys, id, &block)
  end

  def include_type?(type)
    !Array(scope[:exclude_types]).include?(type)
  end

  def include_reactions?
    include_type?('reaction')
  end

  def include_current_user_membership?
    include_type?('membership')
  end

  def include_discussion?
    include_type?('discussion')
  end

  def include_poll?
    include_type?('poll')
  end

  def include_created_event?
    include_type?('event')
  end

  def include_forked_event?
    include_type?('event')
  end

  def include_group?
    include_type?('group') && object.group_id
  end

  def include_active_polls?
    include_type?('poll')
  end

  def include_eventable?
    true
  end

  def include_poll_options?
    include_type?('poll_option')
  end

  def include_stances?
    include_type?('stance')
  end

  def include_my_stance?
    include_type?('stance')
  end

  def include_stance_choices?
    include_type?('stance_choice')
  end

  def include_participant?
    include_author?
  end

  def include_user?
    include_type?('user')
  end

  def include_author?
    include_type?('user') and include_type?('author')
  end

  def include_parent?
    include_type?('parent')
  end

  def include_actor?
    include_type?('user')
  end

  def include_inviter?
    include_type?('inviter')
  end

  def include_outcome?
    include_type?('outcome')
  end

  def include_current_outcome?
    include_type?('outcome')
  end

  def include_outcomes?
    include_type?('outcome')
  end
end
