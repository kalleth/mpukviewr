$(document).ready ->
  faye_url = "http://#{window.location.hostname}:9292/faye"
  client = new Faye.Client(faye_url)
  console.log client
  client.subscribe('/messages', recievedMessage)

recievedMessage = (message) ->
  console.log "Recieved message", message
