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
    @boxes = []
    @setup_events()

  setup_events: ->
    @events ||= []


    keydown = (e) =>
      done = =>
        @measuring = false
        @end_pos = [@mouse_tracker.mousex, @mouse_tracker.mousey]
        @last_size = [Math.abs(@end_pos[0] - @start_pos[0]), Math.abs(@end_pos[1] - @start_pos[1])]
        JRule.Messenger.notify "#{@last_size[0]}x#{@last_size[1]}"
        document.removeEventListener 'keyup', keyup_fn

      keyup_fn = =>
        done()
        @cleanup()

      # console.log e.keyCode
      if e.keyCode == 16 #shift
        @measuring = true
        @start_pos = [@mouse_tracker.mousex, @mouse_tracker.mousey]
        @mark_spot_with_crosshair @start_pos
        document.body.style.cursor = "none"
        @setup_indicators()

        document.addEventListener 'keyup', keyup_fn

      else if e.keyCode == 32 && @measuring
        e.preventDefault()
        done()
        @draw_box [@start_pos, @end_pos]
        console.log "new box!", @start_pos, @end_pos

    @events.push { type: "keydown", fn: keydown }

    mousemove = =>
      @render()

    onclick = (e) =>
      if e.toElement.className == "jrule_caliper_box"
        idx = e.toElement.dataset.index
        if idx < @boxes.length
          @boxes.splice idx, 1

        document.body.removeChild e.toElement        

    @events.push { type: "click", fn: onclick }

    # @events.push { type: "jrule:mousemove", fn: mousemove }

    underhand.add_events @events
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

  #expects box to be an array of [start, end] where each are [x, y] coordinates
  draw_box: (box, include_size=true) ->
    x = Math.min(box[0][0], box[1][0])
    y = Math.min(box[0][1], box[1][1])
    width = Math.abs box[0][0] - box[1][0] # Math.max(box[0][0], box[1][0]) -  Math.min(box[0][0], box[0][1])
    height = Math.abs box[0][1] - box[1][1] # Math.max(box[0][1], box[1][1]) -  Math.min(box[0][1], box[1][1])
    new_box = @create_box x, y, width, height
    console.log new_box
    document.body.appendChild new_box
    @boxes.push new_box 
    @boxes[@boxes.length - 1].dataset.index = @boxes.length - 1

    if include_size
      size = document.createElement "div"
      size.className = "size_indicator"
      style =
        position: "absolute"
        top: "50%"
        fontSize: "16px"
        fontFamily: "sans-serif"
        color: "#fafafa"
        textAlign: "center"
        width: "100%"
      underhand.apply_styles size, style
      underhand.set_text size, "#{width}x#{height}"
      new_box.appendChild size


  create_box: (x, y, width, height) ->
    box = document.createElement "div"
    box.className = "jrule_caliper_box"
    style =
      position: "fixed"
      left: "#{x}px"
      top: "#{y}px"
      width: "#{width}px"
      height: "#{height}px"
      backgroundColor: "rgba(100, 100, 100, .4)"
      zIndex: JRule.zIndex

    underhand.apply_styles box, style
    box

  setup_indicators: ->
    @indicator = @create_box @start_pos[0], @start_pos[1], 1, 1
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










