# This is the main JRule object, it connects all the submodules together providing a 
# controller of sorts for the user. By default, it's instantiated as document.jruler
#
# author: lstebner

class JRule
  @talkative: 1

  constructor: (@opts={}) ->
    @setup_border_rulers()
    @setup_caliper()
    @setup_grid()
    @mouse_tracker = JRule.MouseTracker.get_tracker()
    @setup_events()

    console?.log 'jrule ready!'
    JRule.Messenger.alert 'jrule ready!'
    JRule.Messenger.alert 'Press "h" to view help'

  default_opts: ->

  destroy: ->
    @caliper.destroy() if @caliper
    @border_rulers.destroy() if @border_rulers
    @grid.destroy() if @grid
    @mouse_tracker.destroy() if @mouse_tracker
    document.jruler = undefined

    console?.log "Venni Vetti Vecci"

  setup_events: ->
    @events ||= []

    keydown = (e) =>
      # console.log e.keyCode
      if e.keyCode == 67 #c
        @toggle_crosshairs()
      else if e.keyCode == 82 #r
        @toggle_rulers()
      else if e.keyCode == 71 #g
        @toggle_grid()
      else if e.keyCode == 72 #h
        @toggle_help()
      else if e.keyCode == 77 #m
        JRule.talkative = !JRule.talkative
        JRule.Messenger.alert "Messages #{if JRule.talkative then 'on' else 'off'}", { duration: 1000, force: true }
      else if e.keyCode == 27 #esc
        @destroy()

    @events.push { type: "keydown", fn: keydown }
    
    underhand.add_events @events

  setup_border_rulers: ->
    @border_rulers = new JRule.BorderRulers()

  setup_caliper: ->
    @caliper = new JRule.Caliper()

  setup_grid: ->
    @grid = new JRule.Grid()

  toggle_crosshairs: ->
    shown = @mouse_tracker.toggle_crosshairs()
    JRule.Messenger.alert "Crosshairs #{if shown then 'on' else 'off'}", { duration: 1000 }

  toggle_rulers: ->
    shown = @border_rulers.toggle_visibility()
    JRule.Messenger.alert "Rulers #{if shown then 'on' else 'off'}", { duration: 1000 }

  toggle_grid: ->
    shown = @grid.toggle_grid()
    JRule.Messenger.alert "Grid #{if shown then 'on' else 'off'}", { duration: 1000 }

  toggle_help: ->
    JRule.Help.get().toggle()
