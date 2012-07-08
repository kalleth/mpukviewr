class window.viewr.FayeListener
  constructor: (@settings, @view_manager, @notifier) ->
    @stream_url = "http://#{window.location.hostname}:9292/faye"
    @client = new Faye.Client(@stream_url)
  
  connect: ->
    # Instantiate and connect to the bayeux stream via the faye library
    @subscription = @client.subscribe('/messages', @processMessage)
    @subscription.errback(@processError)
    @subscription

  processMessage: (event) =>
    # A new message has arrived. Parse it, and send it to the view manager and notifier.
    if @typeEnabled(event)
      @view_manager.showMessage(event)
      @notifier.notify(event)

  processError: (error) =>
    console.log "An error has occurred.", error
    @notifier.notifyError(error)

  typeEnabled: (event) ->
    @settings["#{event.etype.toLowerCase()}_enabled"] == true
