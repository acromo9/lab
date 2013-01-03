###
Custom pairwise Lennard Jones properties.
###
define (require) ->

  metadata  = require "md2d/models/metadata"
  validator = require "common/validator"

  class PairwiseLJProperties

    constructor: (engine) ->
      @_engine = engine
      @_data = {}

    registerChangeHooks: (changePreHook, changePostHook) ->
      @_changePreHook = changePreHook
      @_changePostHook = changePostHook

    set: (i, j, props) ->
      props = validator.validate metadata.pairwiseLJProperties, props

      @_changePreHook()

      @_data[i] = {} if not @_data[i]?
      @_data[j] = {} if not @_data[j]?
      @_data[i][j] = @_data[j][i] = {} if not @_data[i][j]?

      for own key of props
        @_data[i][j][key] = props[key]

      @_engine.setPairwiseLJProperties i, j

      @_changePostHook()

    remove: (i, j) ->
      @_changePreHook()

      delete @_data[i][j]
      delete @_data[j][i]

      @_engine.setPairwiseLJProperties i, j

      @_changePostHook()

    get: (i, j) ->
      if @_data[i] && @_data[i][j] then @_data[i][j] else undefined

    deserialize: (array) ->
      for props in array
        props = validator.validateCompleteness metadata.pairwiseLJProperties, props
        # Save element indices and delete them from properties object. It makes no
        # sense to store this information, as it's redundant.
        el1 = props.element1
        el2 = props.element2
        delete props.element1
        delete props.element2
        @set el1, el2, props
