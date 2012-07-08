class window.viewr.Notifier
  
  constructor: (@settings) ->

  notify: (payload) ->
    # Calls the other 3 methods based on settings
    console.log "Notifying: ", payload

  notifyError: (error) ->
  
  soundNotify: ->

  popupNotify: (payload) ->

  titleNotify: ->
