class window.viewr.FayeListener
  constructor: (@settings, @view_manager, @notifier) ->

  connect: ->
    # Instantiate and connect to the bayeux stream via the faye library

  processMessage: ->
    # A new message has arrived. Parse it, and send it to the view manager and notifier.
