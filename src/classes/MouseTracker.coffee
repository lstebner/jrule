class JRule.MouseTracker
  @get_tracker: ->
    @tracker ||= new JRule.MouseTracker()

  constructor: (@opts={}) ->
    @crosshairs = null

    @default_opts()
    @setup_events()

    @setup_crosshairs() if @opts.show_crosshairs

  default_opts: ->
    defaults =
      show_crosshairs: true
      style:
        crosshairColor: "rgba(100, 100, 100, .6)"
        crosshairThickness: 1

    underhand.defaults defaults, @opts

  setup_events: ->
    @events ||= []

    mousemove = (e) =>
      @mousex = e.clientX
      @mousey = e.clientY
      event = new Event 'jrule:mousemove'
      document.body.dispatchEvent event

      @render_crosshairs() if @opts.show_crosshairs

    @events.push { type: "mousemove", fn: mousemove }

    keydown = (e) =>
      if e.keyCode == 187 #+
        @increase_crosshair_size()
      else if e.keyCode == 189 #-
        @decrease_crosshair_size()

    @events.push { type: "keydown", fn: keydown }

    underhand.add_events @events

  increase_crosshair_size: ->
    @opts.style.crosshairThickness += 1
    @crosshairs.x?.style.width = "#{@opts.style.crosshairThickness}px"
    @crosshairs.y?.style.height = "#{@opts.style.crosshairThickness}px"
    JRule.Messenger.alert "#{@opts.style.crosshairThickness}px", { duration: 600 }

  decrease_crosshair_size: ->
    @opts.style.crosshairThickness = Math.max 1, @opts.style.crosshairThickness - 1
    @crosshairs.x?.style.width = "#{@opts.style.crosshairThickness}px"
    @crosshairs.y?.style.height = "#{@opts.style.crosshairThickness}px"
    JRule.Messenger.alert "#{@opts.style.crosshairThickness}px", { duration: 600 }

  setup_crosshairs: ->
    @crosshairs = {}

    @crosshairs.x = JRule.Crosshair.create 'x', "50%", @opts.style
    @crosshairs.y = JRule.Crosshair.create 'y', "50%", @opts.style

    for coord, c of @crosshairs
      document.body.appendChild c

  render_crosshairs: ->
    @setup_crosshairs() if !@crosshairs
    offset = if @opts.style.crosshairThickness == 1 then 0 else Math.round(@opts.style.crosshairThickness / 2)
    @crosshairs.x.style.left = "#{@mousex - offset}px"
    @crosshairs.y.style.top = "#{@mousey - offset}px"

  toggle_crosshairs: ->
    @opts.show_crosshairs = !@opts.show_crosshairs

    @remove_crosshairs() if !@opts.show_crosshairs
    @opts.show_crosshairs

  remove_crosshairs: ->
    for coord, c of @crosshairs
      document.body.removeChild c

    @crosshairs = null

  destroy: ->
    @remove_crosshairs()
    underhand.remove_events @events


      
