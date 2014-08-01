# underhand
#
# underhand is a module for all the helpers that JRule uses. Some of these are 
# similar to methods you would find in underscore (such as extend), but others
# are just convenience methods for things I found myself doing over and over. 
#
# author: lstebner

#soft pitch, cause we like it easy
underhand = {}

underhand.set_text = (el, content) ->
  if el.innerText
    el.innerText = content
  else
    el.textContent = content

#covenience methods for adding and removing events from the document body
#expects an array of objects, each with a type (the event to handle) and
#an 'fn', which is the callback function
#the second argument, el, is the element to add or remove the events from.
#if not supplied, they default to document level
underhand.add_events = (events, el) ->
  for e in events
    if el?
      el.addEventListener e.type, e.fn
    else
      document.addEventListener e.type, e.fn

underhand.remove_events = (events, el) ->
  for e in events
    if el?
      el.removeEventListener e.type, e.fn
    else
      document.removeEventListener e.type, e.fn

#apply a series of styles to a dom element.
#expects el to be a single element
#expects styles to be an object where the keys are style properties
underhand.apply_styles = (el, styles) ->
  for key, val of styles
    el.style[key] = val

underhand.extend = (first={}, second={}) ->
  for key, val of second
    first[key] = val

  first

underhand.defaults = (default_props, obj={}) ->
  for key, val of default_props
    if !obj.hasOwnProperty(key)
      obj[key] = val

  obj
