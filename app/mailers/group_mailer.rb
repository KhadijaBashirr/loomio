class GroupMailer < BaseMailer
  layout 'invite_people_mailer'

  def group_announced(recipient_id, event_id, membership_id)
    @recipient = User.find_by!(id: recipient_id)
    @event = Event.find_by!(id: event_id)
    @membership = Membership.find_by!(id: membership_id)
    @inviter = @event.user || @membership.inviter

    send_single_mail to:     @recipient.email,
                     locale: @recipient.locale,
                     from:   from_user_via_loomio(@membership.inviter),
                     reply_to: @membership.inviter.name_and_email,
                     subject_key: "email.to_join_group.subject",
                     subject_params: {member: @membership.inviter.name,
                                      group_name: @membership.group.full_name,
                                      site_name: AppConfig.theme[:site_name]}
  end

  def membership_requested(recipient_id, event_id)
    recipient = User.find_by!(id: recipient_id)
    event = Event.find_by!(id: event_id)
    @membership_request = event.eventable
    @group = @membership_request.group
    @introduction = @membership_request.introduction
    send_single_mail  to: recipient.name_and_email,
                      reply_to: "#{@membership_request.name} <#{@membership_request.email}>",
                      subject_key: "email.membership_request.subject",
                      subject_params: {who: @membership_request.name, which_group: @group.full_name, site_name: AppConfig.theme[:site_name]},
                      locale: recipient.locale
  end
end
