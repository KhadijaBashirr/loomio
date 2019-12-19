angular.module('loomioApp').factory 'MembershipRequestModel', (BaseModel) ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membershipRequest'
    @plural: 'membershipRequests'
    @indices: ['id', 'groupId']

    group: ->
      @recordStore.groups.find(@groupId)

    requestor: ->
      @recordStore.users.find(@requestorId)

    responder: ->
      @recordStore.users.find(@responderId)

    actor: ->
      if @byExistingUser()
        @requestor()
      else
        @fakeUser()

    byExistingUser: -> @requestorId?

    fakeUser: ->
      name: @name
      email: @email
      avatarKind: 'initials'
      avatarInitials: 'NA'

    isPending: ->
      !@respondedAt?
