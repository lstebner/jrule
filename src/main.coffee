# first
# @codekit-prepend "helpers/underhand.coffee"
# @codekit-prepend "classes/JRule.coffee"


# @codekit-prepend "classes/BorderRulers.coffee"
# @codekit-prepend "classes/Caliper.coffee"
# @codekit-prepend "classes/Crosshair.coffee"
# @codekit-prepend "classes/Grid.coffee"
# @codekit-prepend "classes/Mandolin.coffee"
# @codekit-prepend "classes/Messenger.coffee"
# @codekit-prepend "classes/MouseTracker.coffee"

document.JRule = JRule

ready = ->
  document.jruler = new document.JRule()

if document.readyState != "complete"
  document.addEventListener 'DOMContentLoaded', ->
    ready()
else
  ready()

