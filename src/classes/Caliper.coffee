# Caliper
#
# This is the Measuring Tool. It allows you to easily and quickly measure how big
# on screen items are. By default, the 'shift' key toggles measuring on and goes from
# your initial mouse position to wherever you drag. Releasing 'shift' then stops 
# measuring.
#
# author: lstebner


class JRule.Caliper
  constructor: (@opts={}) ->
    @mouse_tracker = JRule.MouseTracker.get_tracker()
    @crosshairs = []
    @setup_events()

  setup_events: ->
    @events ||= []

    keydown = (e) =>
      if e.keyCode == 16 #shift
        @measuring = true
        @start_pos = [@mouse_tracker.mousex, @mouse_tracker.mousey]
        @mark_spot_with_crosshair @start_pos
        document.body.style.cursor = "none"
        @setup_indicators()

        keyup_fn = =>
          @measuring = false
          @end_pos = [@mouse_tracker.mousex, @mouse_tracker.mousey]
          document.removeEventListener 'keyup', keyup_fn
          @cleanup()

        document.addEventListener 'keyup', keyup_fn

    @events.push { type: "keydown", fn: keydown }

    mousemove = =>
      @render()

    @events.push { type: "jrule:mousemove", fn: mousemove }

    underhand.add_events [{ type: "keydown", fn: keydown }]
    underhand.add_events [{ type: "jrule:mousemove", fn: mousemove }], document.body


  render: ->
    if @measuring
      x = Math.min(@mouse_tracker.mousex, @start_pos[0])
      y = Math.min(@mouse_tracker.mousey, @start_pos[1])
      width = Math.max(@mouse_tracker.mousex, @start_pos[0]) -  Math.min(@mouse_tracker.mousex, @start_pos[0])
      height = Math.max(@mouse_tracker.mousey, @start_pos[1]) -  Math.min(@mouse_tracker.mousey, @start_pos[1])
      indicator_style =
        width: "#{width}px"
        height: "#{height}px"
        left: "#{x}px"
        top: "#{y}px"
        zIndex: JRule.zIndex
      underhand.apply_styles @indicator, indicator_style

      indicator_size_style =
        display: 'block'

      h_dir = if @start_pos[0] > @mouse_tracker.mousex then "left" else "right"
      v_dir = if @start_pos[1] > @mouse_tracker.mousey then "up" else "down"
      @drag_direction = [h_dir, v_dir]

      if h_dir == "left"
        indicator_size_style.left = 0
        indicator_size_style.right = "auto"
      else
        indicator_size_style.right = 0
        indicator_size_style.left = "auto"

      if v_dir == "up"
        indicator_size_style.top = 0
        indicator_size_style.bottom = "auto"
      else
        indicator_size_style.bottom = 0
        indicator_size_style.top = "auto"

      underhand.apply_styles @indicator_size, indicator_size_style
      underhand.set_text @indicator_size, "#{width}, #{height}"

  setup_indicators: ->
    indicator = document.createElement "div"
    i_style =
      position: "fixed"
      left: "#{@start_pos[0]}px"
      top: "#{@start_pos[1]}px"
      backgroundColor: "rgba(100, 100, 100, .4)"
      zIndex: JRule.zIndex
    @indicator = indicator
    underhand.apply_styles @indicator, i_style
    document.body.appendChild @indicator

    indicator_size = document.createElement "div"
    is_style =
      position: "absolute"
      right: 0
      bottom: 0
      fontFamily: "sans-serif"
      fontSize: "12px"
      backgroundColor: "#000"
      color: "#fff"
      padding: "3px"
      zIndex: 1
    @indicator_size = indicator_size
    underhand.apply_styles @indicator_size, is_style
    @indicator.appendChild @indicator_size

  mark_spot_with_crosshair: (pos) ->
    @crosshairs.push JRule.Crosshair.create 'x', "#{pos[0]}px"
    @crosshairs.push JRule.Crosshair.create 'y', "#{pos[1]}px"

    for c in @crosshairs
      document.body.appendChild c

  cleanup: ->
    @indicator.removeChild @indicator_size
    document.body.removeChild @indicator

    for c in @crosshairs
      document.body.removeChild c

    @crosshairs = []

    document.body.style.cursor = "default"

  destroy: ->
    keydown = null
    mousemove = null

    for e in @events
      keydown = e if e.type == "keydown"
      mousemove = e if e.type == "jrule:mousemove"

    underhand.remove_events([{ type: "keydown", fn: keydown.fn }]) if keydown
    underhand.remove_events([{ type: "jrule:mousemove", fn: mousemove.fn }], document.body) if mousemove
