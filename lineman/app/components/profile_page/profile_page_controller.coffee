angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, CurrentUser, Records, FlashService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm) ->
  @user = CurrentUser.clone()

  @availableLocales = ->
    window.Loomio.locales

  @submit = ->
    @isDisabled = true
    Records.users.updateProfile(@user).then ->
      @isDisabled = false
      FlashService.success('profile_page.messages.updated')
      $location.path('/dashboard')
    , ->
      @isDisabled = false
      $rootScope.$broadcast 'pageError', 'cantUpdateProfile', @user
  @changePicture = ->
    ModalService.open ChangePictureForm

  @changePassword = ->
    ModalService.open ChangePasswordForm

  @deactivateUser = ->
    ModalService.open DeactivateUserForm

  @canDeactivateUser = ->
    AbilityService.canDeactivateUser()

  return
