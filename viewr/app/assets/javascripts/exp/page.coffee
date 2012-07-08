# Below will move to window.viewr namespace when i cba to update legacy js.
window.Settings = new Object(
  notifications_enabled: false
  sounds_enabled: true
  tweet_enabled: true
  forum_enabled: true
  tourney_enabled: true
  facebook_enabled: true
  general_enabled: true
  service_enabled: true
  news_enabled: true
  tannoy_enabled: true
  service_enabled: true
)

$(document).ready ->
  settingsReflectsCookie()
  addCheckboxListeners()
  window.viewr.view_mgr = new viewr.ViewManager(window.Settings)
  window.viewr.notifier = new viewr.Notifier(window.Settings)
  window.viewr.listener = new viewr.FayeListener(window.Settings, window.viewr.view_mgr, window.viewr.notifier)
  window.viewr.listener.connect()
  $(window).focus ->
    dbOnWindowFocus()
  $(window).blur ->
    dbOnWindowLoseFocus()

settingsReflectsCookie = ->
  if $.cookie('settings')?
    window.Settings = JSON.parse $.cookie('settings')

addCheckboxListeners = ->
  $(":checkbox[id*='enabled']").each ->
    $(this).click(checkListener)
    klass = this.id.substr(0, (this.id.length - 8))
    act = window.Settings[this.id]
    $(this).prop "checked", act
    respectFilters(klass, act)

onWindowFocus = ->
  window.viewr.window_focus = true
  window.viewr.notifier.resetUnseen()
  document.title = "Viewr"
  fadeUnseen()

onWindowLoseFocus = ->
  window.viewr.window_focus = false

dbOnWindowFocus = onWindowFocus.debounce(250, true)
dbOnWindowLoseFocus = onWindowLoseFocus.debounce(250, true)
