class window.viewr.Notifier
  
  constructor: (@settings) ->
    @resetUnseen()

  notify: (payload) ->
    # Calls the other 3 methods based on settings
    console.log "Notifying: ", payload
    @soundNotify() if @settings.sounds_enabled
    @popupNotify(payload) if @settings.notifications_enabled
    @titleNotify()

  notifyError: (error) ->
  
  soundNotify: ->
    $("audio")[0].play()

  popupNotify: (payload) ->
    if window.webkitNotifications
      if window.webkitNotifications.checkPermission() < 1
        console.log "Blah"
        title = @extractText("#{payload.etype}: #{payload.title}")
        icon = "http://viewr.multiplay.co.uk/images/icons/#{payload.etype.toLowerCase()}.png"
        body = @extractText(payload.description)
        popup = window.webkitNotifications.createNotification(icon, title, body)
        popup.show()
        setTimeout(->
          popup.cancel()
        , '15000')

  titleNotify: ->
    if !window.window_focus
      @unseen++
      document.title = "(#{@unseen}) Viewr"

  resetUnseen: ->
    @unseen = 0

  extractText: (fragment) ->
    div = document.createElement('div')
    div.innerHTML = fragment
    div.textContent || div.innerText || fragment
