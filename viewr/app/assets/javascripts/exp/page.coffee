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
  view_mgr = new viewr.ViewManager(window.Settings)
  notifier = new viewr.Notifier(window.Settings)
  createListener(window.Settings, view_mgr, notifier)

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

createListener = (settings, view_manager, notifier) ->
  listener = new viewr.FayeListener(settings, view_manager, notifier)
  listener.connect()
