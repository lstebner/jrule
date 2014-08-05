# This is the main JRule object, it connects all the submodules together providing a 
# controller of sorts for the user. By default, it's instantiated as document.jruler
#
# author: lstebner

class JRule
  @talkative: 1
  @version: .5
  @zIndex: 999999

  constructor: (@opts={}) ->
    @setup_border_rulers()
    @setup_caliper()
    @setup_grid()
    @setup_mandolin()
    @mouse_tracker = JRule.MouseTracker.get_tracker()
    @setup_events()

    console?.log 'jrule ready!'
    JRule.Messenger.notify 'jrule ready!'
    JRule.Messenger.notify 'Press "h" to view help'

  default_opts: ->

  destroy: ->
    @caliper.destroy() if @caliper
    @border_rulers.destroy() if @border_rulers
    @grid.destroy() if @grid
    @mouse_tracker.destroy() if @mouse_tracker
    @mandolin.destroy() if @mandolin
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
        JRule.Messenger.notify "Messages #{if JRule.talkative then 'on' else 'off'}", { duration: 1000, force: true }
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

  setup_mandolin: ->
    @mandolin = new JRule.Mandolin()

  toggle_crosshairs: ->
    shown = @mouse_tracker.toggle_crosshairs()
    JRule.Messenger.notify "Crosshairs #{if shown then 'on' else 'off'}", { duration: 1000 }

  toggle_rulers: ->
    shown = @border_rulers.toggle_visibility()
    JRule.Messenger.notify "Rulers #{if shown then 'on' else 'off'}", { duration: 1000 }

  toggle_grid: ->
    shown = @grid.toggle_grid()
    JRule.Messenger.notify "Grid #{if shown then 'on' else 'off'}", { duration: 1000 }

  toggle_help: ->
    JRule.Help.get().toggle()

  config: (what, settings={}) ->
    options = if what == 'crosshairs'
      @mouse_tracker.config_items()
    else if what == 'rulers'
      @border_rulers.config_items()

    for key, val of settings
      if options.indexOf(key) > -1
        switch what
          when 'crosshairs' then @mouse_tracker.config key, val
          when 'rulers' then @border_rulers.config key, val









