# ViewManager, responsible for:
#  * Reading into a data structure the 'templates' for views from the HTML 
#  * When told to, inserting a new event (and removing an old event) from
#    the DOM, based on a given data structure.

class ViewManager
  constructor: (@settings) ->
    @loadTemplates()

  loadTemplates: ->
    console.log "Loading templates"

  showMessage: (payload) ->
    console.log "Payload: ", payload
