describe 'Group Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'

  beforeEach ->
    groupsHelper.load()

  it 'successfully starts a discussion', ->
    groupsHelper.clickStartThreadButton()
    groupsHelper.fillInDiscussionTitle('Nobody puts baby in a corner')
    groupsHelper.fillInDiscussionDescription("I've had the time of my life")
    groupsHelper.submitDiscussionForm()
    expect(groupsHelper.discussionTitle().getText()).toContain('Nobody puts baby in a corner')
    expect(groupsHelper.discussionTitle().getText()).toContain("I've had the time of my life")

  it 'successfully edits group name', ->
    groupsHelper.openMemberOptionsDropdown()
    groupsHelper.clickEditGroupOption()
    groupsHelper.editGroupNameTo('Dancing Dirty Shoes')
    groupsHelper.submitGroupSettingsForm()
    expect(groupsHelper.groupPage().getText()).toContain('')

   it 'successfully edits group description', ->
    groupsHelper.openMemberOptionsDropdown()
    groupsHelper.clickEditGroupOption()
    groupsHelper.changeGroupVisibilitySettings()
    groupsHelper.submitGroupSettingsForm()
    expect(groupsHelper.groupPage().getText()).toContain('This group is only visible to members')

  it 'successfully edits group privacy', ->
    groupsHelper.openMemberOptionsDropdown()
    groupsHelper.clickEditGroupOption()
    groupsHelper.changeGroupVisibilitySettings()
    groupsHelper.submitGroupSettingsForm()
    expect(groupsHelper.groupPage().getText()).toContain('This group is only visible to members')

  it 'successfully edits group permissions', ->
    groupsHelper.visitEditGroupPage()
    groupsHelper.changeVotingPermissions()
    groupsHelper.submitGroupSettingsForm()
    groupsHelper.visitEditGroupPage()
    expect(groupsHelper.votePermissionsCheckbox().isSelected()).not.toBeTruthy()
