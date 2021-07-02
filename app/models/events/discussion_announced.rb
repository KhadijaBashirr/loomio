class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  attr_accessor :discussion_readers
  attr_accessor :announcement

  def self.publish!(model, actor, discussion_readers, announcement)
    super(model,
          user: actor,
          discussion_readers: discussion_readers,
          announcement: announcement)
  end

  private

  def email_recipients
    member_ids = []
    if eventable.group_id && @announcement && actor.can?(:announce, eventable)
      member_ids = eventable.group.accepted_memberships.email_announcements.pluck(:user_id)
    end
    user_ids =  member_ids.concat(discussion_readers.email_announcements.pluck(:user_id)).uniq
    User.distinct.active.where(id: user_ids)
  end

  def notification_recipients
    member_ids = []
    if eventable.group_id && @announcement && actor.can?(:announce, eventable)
      member_ids = eventable.group.accepted_memberships.app_announcements.pluck(:user_id)
    end
    user_ids = member_ids.concat(discussion_readers.app_announcements.pluck(:user_id)).uniq
    User.distinct.active.where(id: user_ids)
  end
end
