import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import {capitalize} from 'lodash'

export default class OutcomeModel extends BaseModel
  @singular: 'outcome'
  @plural: 'outcomes'
  @indices: ['pollId', 'authorId']

  defaultValues: ->
    statement: ''
    statementFormat: 'html'
    customFields: {}
    files: []
    imageFiles: []
    attachments: []
    recipientUserIds: []
    recipientEmails: []
    notifyAudience: null

  afterConstruction: ->
    HasDocuments.apply @
    HasTranslations.apply @

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'poll'
    @belongsTo 'group'
    @belongsTo 'pollOption'

  reactions: ->
    @recordStore.reactions.find
      reactableId: @id
      reactableType: capitalize(@constructor.singular)

  authorName: ->
    @author().nameWithTitle(@poll().group())

  members: ->
    @poll().members()

  memberIds: ->
    @poll().memberIds()

  announcementSize: ->
    @poll().announcementSize @notifyAction()

  discussion: ->
    @poll().discussion()

  notifyAction: ->
    'publish'
