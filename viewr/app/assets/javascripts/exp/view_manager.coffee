# ViewManager, responsible for:
#  * Reading into a data structure the 'templates' for views from the HTML 
#  * When told to, inserting a new event (and removing an old event) from
#    the DOM, based on a given data structure.

class window.viewr.ViewManager
  constructor: (@settings) ->
    @template = @loadTemplates()

  loadTemplates: ->
    data = $('#template-message').html()
    Handlebars.compile(data)

  showMessage: (payload) ->
    viewData = @massagePayload(payload)
    element = $(@template(viewData))
    @insertElement(element)
    @bindElementItems(element)
    @removeLastChild()

  massagePayload: (payload) ->
    # For handlebars, we need to add a couple of fields.
    # title_link - boolean, if this has a title link or not
    payload.title_link = (payload.etype == "NEWS")
    payload.strftime_date = new Date(payload.happened_at).strftime("%d/%m/%y %H:%M")
    payload.lower_etype = payload.etype.toLowerCase()
    payload

  insertElement: (element) =>
    $("#news_container ul").prepend(element)
    element.fadeIn(800)

  bindElementItems: (element) =>
    time = element.find('.time time')
    time.tooltip({placement: 'left'})
    time.timeago()

  removeLastChild: ->
    if $("#news_container ul li").length > 49
      $("#news_container ul li:last-child").fadeOut(200, ->
        $(this).remove()
      )
