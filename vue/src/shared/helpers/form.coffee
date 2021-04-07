import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'
import Flash   from '@/shared/services/flash'

import { fieldFromTemplate } from '@/shared/helpers/poll'

export submitDiscussion = (scope, model, options = {}) ->
  if model.isForking
    submitFn = model.moveComments
  else
    model.save

  submit(scope, model, _.merge(
    submitFn: submitFn
    flashSuccess: if model.isForking then "discussion_fork_actions.moved" else "discussion_form.messages.#{actionName(model)}"
    failureCallback: ->
      console.log "failure"
    successCallback: (data) ->
      _.invokeMap Records.documents.find(model.removedDocumentIds), 'remove'
      if model.isForking
        model.forkTarget().discussion().forkedEventIds = []
        _.invokeMap Records.events.find(model.forkedEventIds), 'remove'
      nextOrSkip(data, scope, model)
  , options))

export submitMembership = (scope, model, options = {}) ->
  submit(scope, model, _.merge(
    flashSuccess: "membership_form.#{actionName(model)}"
    successCallback: -> EventBus.$emit '$close'
  , options))

submit = (scope, model, options = {}) ->
  submitFn  = options.submitFn  or model.save
  confirmFn = options.confirmFn or (-> false)
  (prepareArgs) ->
    return if scope.isDisabled
    prepare(scope, model, options, prepareArgs)
    if confirm(confirmFn(model))
      setTimeout ->
        submitFn(model).then(
          success(scope, model, options),
          failure(scope, model, options),
        ).finally(
          cleanup(scope, model, options)
        )
    else
      cleanup(scope, model, options)

prepare = (scope, model, options, prepareArgs) ->
  Flash.loading(options.loadingMessage)
  options.prepareFn(prepareArgs) if typeof options.prepareFn is 'function'
  EventBus.$emit 'processing'
  model.cancelDraftFetch()       if typeof model.cancelDraftFetch is 'function'
  model.clearDrafts()            if typeof model.clearDrafts      is 'function'
  model.setErrors()
  scope.isDisabled = true

confirm = (confirmMessage) ->
  if confirmMessage and typeof window.confirm == 'function'
    window.confirm(confirmMessage)
  else
    true

progress = (scope) ->
  (progress) ->
    return unless progress.total > 0
    scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)

success = (scope, model, options) ->
  (data) ->
    # Flash.dismiss()
    options.successCallback(data) if typeof options.successCallback is 'function'
    if options.flashSuccess?
      flashKey     = if typeof options.flashSuccess is 'function' then options.flashSuccess() else options.flashSuccess
      Flash.success flashKey, calculateFlashOptions(options.flashOptions)

failure = (scope, model, options) ->
  (response) ->
    # Flash.dismiss()
    options.failureCallback(response) if typeof options.failureCallback is 'function'
    setErrors(scope, model, response) if _.includes([401, 422], response.status)
    EventBus.$emit errorTypes[response.status] or 'unknownError',
      model: model
      response: response

cleanup = (scope, model, options = {}) ->
  ->
    Flash.dismiss()
    options.cleanupFn(scope, model) if typeof options.cleanupFn is 'function'
    EventBus.$emit 'doneProcessing' unless options.skipDoneProcessing
    scope.isDisabled = false
    scope.files = null        if scope.files
    scope.percentComplete = 0 if scope.percentComplete

calculateFlashOptions = (options) ->
  _.each _.keys(options), (key) ->
    options[key] = options[key]() if typeof options[key] is 'function'
  options

nextOrSkip = (data, scope, model) ->
  eventData = _.find(data.events, (event) -> event.kind == eventKind(model)) || {}
  if event = Records.events.find(eventData.id)
    EventBus.$emit 'nextStep', event
  else
    EventBus.$emit 'skipStep'

actionName = (model) ->
  return 'forked' if model.isA('discussion') and model.isForking
  if model.isNew() then 'created' else 'updated'

setErrors = (scope, model, response) ->
  response.json().then (r) ->
    model.setErrors(r.errors)

export eventKind = (model) ->
  if model.isA('discussion') and model.isNew()
    return if model.isForking then 'discussion_forked' else 'new_discussion'

  if model.isNew()
    "#{model.constructor.singular}_created"
  else
    "#{model.constructor.singular}_edited"

errorTypes =
  400: 'badRequest'
  401: 'unauthorizedRequest'
  403: 'forbiddenRequest'
  404: 'resourceNotFound'
  422: 'unprocessableEntity'
  500: 'internalServerError'
