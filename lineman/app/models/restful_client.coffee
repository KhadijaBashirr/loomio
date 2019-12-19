angular.module('loomioApp').factory 'RestfulClient', ($http, $upload) ->
  class RestfulClient
    apiPrefix: "api/v1"

    # override these to set default actions
    onSuccess: (response) -> response
    onFailure: (response) -> throw response

    constructor: (resourcePlural) ->
      @resourcePlural = _.snakeCase(resourcePlural)

    buildUrl: (url, params) ->
      return url unless params?
      url + "?" + window.jQuery.param(params)

    collectionPath: ->
      "#{@apiPrefix}/#{@resourcePlural}"

    memberPath: (id, action) ->
      if action?
        "#{@apiPrefix}/#{@resourcePlural}/#{id}/#{action}"
      else
        "#{@apiPrefix}/#{@resourcePlural}/#{id}"

    customPath: (path) ->
      "#{@apiPrefix}/#{@resourcePlural}/#{path}"

    get: (path, params) ->
      url = @buildUrl(@customPath(path), params)
      $http.get(url).then @onSuccess, @onFailure

    post: (path, params) ->
      $http.post(@customPath(path), params).then @onSuccess, @onFailure

    upload: (path, params, file) ->
      $upload.upload _.merge params,
        url: @customPath(path)
        headers: { 'Content-Type': false }
        data: params
        file: file

    postMember: (keyOrId, action, params) ->
      $http.post(@memberPath(keyOrId, action), params).then @onSuccess, @onFailure

    patchMember: (keyOrId, action, params) ->
      $http.patch(@memberPath(keyOrId, action), params).then @onSuccess, @onFailure

    getMember: (keyOrId, action) ->
      $http.get(@memberPath(keyOrId, action)).then @onSuccess, @onFailure

    getCollection: (params) ->
      url = @buildUrl(@collectionPath(), params)
      $http.get(url).then @onSuccess, @onFailure

    create: (params) ->
      $http.post(@collectionPath(), params).then @onSuccess, @onFailure

    update: (id, params) ->
      $http.patch(@memberPath(id), params).then @onSuccess, @onFailure

    destroy: (id) ->
      $http.delete(@memberPath(id)).then @onSuccess, @onFailure
