Given(/^I have a proposal which has expired$/) do
  @motion = FactoryGirl.create :motion, author: @user
  @motion.close_at_date = Date.parse((Time.zone.now - 10.days).to_s)
  @motion.save
end

When(/^I click the notifications dropdown$/) do
  find("#notifications-toggle").click
end

Then(/^I should see that the motion expired$/) do
  find("#notifications-container").should have_content(I18n.t('notifications.motion_closed.by_expiry') + ": " + @motion.name)
end

Given(/^someone has closed a proposal in a group I belong to$/) do
  @motion = FactoryGirl.create :motion
  @group = @motion.group
  @closer = FactoryGirl.create :user
  @group.add_member!(@closer)
  @group.add_member!(@user)
  @motion.close!(@closer)
end

Then(/^I should see that someone closed the motion$/) do
  find("#notifications-container").should have_content(@closer.name + " " + I18n.t('notifications.motion_closed.by_user'))
end

Given(/^a visitor has requested membership to the group$/) do
  params = { name: "Richie", email: "rich@loomio.org" }
  @membership_request = RequestMembership.to_group(group: @group, params: params)
end

Then(/^I should see that the visitor requested access to the group$/) do
  find("#notifications-container").should have_content(@membership_request.name + " " + I18n.t('notifications.membership_requested'))
end

Given(/^a user has requested membership to the group$/) do
  @requestor = FactoryGirl.create :user
  @membership_request = RequestMembership.to_group(group: @group, requestor: @requestor)
end

Then(/^I should see that the user requested access to the group$/) do
  step 'I should see that the visitor requested access to the group'
end

When(/^I click the membership request notification$/) do
  find(".selector-item, .notification-item").click
end

Then(/^I should see the membership request page$/) do
  page.should have_css("body.manage_membership_requests.index")
end

