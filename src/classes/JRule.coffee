class JRule
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
      if e.keyCode == 67 #c
        @toggle_crosshairs()
      else if e.keyCode == 82 #r
        @toggle_rulers()
      else if e.keyCode == 71 #g
        @toggle_grid()
      else if e.keyCode == 72 #h
        @show_help()
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
    @mouse_tracker.toggle_crosshairs()

  toggle_rulers: ->
    @border_rulers.toggle_visibility()

  toggle_grid: ->
    @grid.toggle_grid()

  show_help: ->
    JRule.Help.show()
