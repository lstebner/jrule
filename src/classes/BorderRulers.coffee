# BorderRulers
# These are the Rulers that line the edge of the screen. They contain tick marks at
# set intervals and also tick divisions. The major ticks are all labeled. This also
# tracks mouse position, though it is hard/impossible to see with the crosshairs on.
#
# author: lstebner

class JRule.BorderRulers
  constructor: (@opts={}) ->
    @rulers = {}
    @mouse_ticks = {}
    @mouse_tracker = JRule.MouseTracker.get_tracker()
  
    @default_opts()
    @setup_rulers()
    @setup_mouse_pos()
    @setup_events()
    
  default_opts: ->
    defaults =
      style:
        backgroundColor: "rgba(#{JRule.ColorWheel.hex_to_rgba('#aaa', .5)})"
        opacity: .5
        tickColor: "#f8f8f8"
        mouseTickColor: "#00f"
      top: true
      left: true
      right: false
      bottom: false
      tick_distance: 200 #px
      rule_size: 25
      divisions: 10
      show_mouse: true
      show_labels: true
      start_in_center: true

    #todo: actual extend of defaults with given @opts
    @opts = defaults

  config_items: ->
    ['divisions', 'tick_distance', 'show_mouse', 'show_labels']

  config: (what, value) ->
    switch what
      when 'divisions'
        @opts.divisions = value

      when 'tick_distance'
        @opts.tick_distance = value

      when 'show_mouse'
        @opts.show_mosue = value

      when 'show_labels'
        @opts.show_labels = value

    @setup_rulers(true)

  get_style: ->
    backgroundColor: @opts.style.backgroundColor
    opacity: @opts.style.opacity

  setup_rulers: (force=false) ->
    return if @setup && !force

    @destroy_rulers() if @setup && force
    
    create_ruler = =>
      rule = document.createElement("div")
      rule.className = "ruler"

      styles = @get_style()
      underhand.extend styles,
        position: "fixed"
        zIndex: JRule.zIndex

      underhand.apply_styles rule, styles

      rule
      
    if @opts.top
      top_ruler = create_ruler()
      underhand.apply_styles top_ruler,
        left: 0
        right: 0
        top: 0
        height: "#{@opts.rule_size}px"
      @rulers.top = top_ruler

    if @opts.left
      left_ruler = create_ruler()
      underhand.apply_styles left_ruler,
        left: 0
        top: 0
        bottom: 0
        width: "#{@opts.rule_size}px"
      @rulers.left = left_ruler
  
    for name, ruler of @rulers
      #investigate why this causes an error initially
      document.body?.appendChild ruler

    @setup_ticks()

    @shown = true
    @setup = true

  setup_events: ->
    @events ||= []

    if @opts.show_mouse
      mousemove = (e) =>
        @render()

      @events.push { type: "jrule:mousemove", fn: mousemove }

      underhand.add_events @events, document.body

  tick_style: (side) ->
    style =
      position: "absolute"
      display: "block"
      backgroundColor: @opts.style.tickColor

    if side == "top" || side == "bottom"
      style.width = "1px"
      style.height = "100%"
    else
      style.width = "100%"
      style.height = "1px"

    style

  create_label: (side, pos) ->
    label = document.createElement "div"
    label.className = "tick_label"
    underhand.set_text label, "#{pos}px"
    style =
      position: "absolute"
      fontSize: "10px"
      fontFamily: "sans-serif"

    if side == "top"
      underhand.extend style,
        left: "#{pos}px"
        bottom: "2px"
        marginLeft: "-14px"
    else
      underhand.extend style,
        top: "#{pos}px"
        left: "4px"
        "-webkit-transform": "rotate(-90deg)"
        "transform": "rotate(-90deg)"
        "-moz-transform": "rotate(-90deg)"

    underhand.apply_styles label, style

    label

  setup_ticks: ->
    doc_rect = document.body.getBoundingClientRect()

    ticks = Math.ceil doc_rect.width / @opts.tick_distance
    tick_distance = Math.round doc_rect.width / ticks
    division_distance = Math.round tick_distance / @opts.divisions

    for side in ['top', 'left']
      for i in [0...ticks]
        tick_pos = i * @opts.tick_distance
        @draw_tick side, tick_pos, 1, { backgroundColor: "#666" }

        if @opts.show_labels
          tick_label = @create_label side, tick_pos
          @rulers[side].appendChild tick_label

        for j in [1..@opts.divisions]
          div_pos = j * division_distance + tick_pos
          @draw_tick side, div_pos, (if j % 2 then .3 else .5)

  setup_mouse_pos: ->
    doc_rect = document.body.getBoundingClientRect()

    if @opts.show_mouse
      if @rulers.hasOwnProperty 'top'
        mouse_x_tick = @create_tick 'top', Math.round(doc_rect.width / 2), 1
        mouse_x_tick.style.backgroundColor = "#{@opts.style.mouseTickColor}"
        @mouse_ticks.x = mouse_x_tick
        @rulers.top.appendChild @mouse_ticks.x
      if @rulers.hasOwnProperty 'left'
        mouse_y_tick = @create_tick 'left', Math.round(doc_rect.width / 2), 1
        mouse_y_tick.style.backgroundColor = "#{@opts.style.mouseTickColor}"
        @mouse_ticks.y = mouse_y_tick
        @rulers.left.appendChild @mouse_ticks.y

      mouse_pos = document.createElement "div"
      style =
        position: "fixed"
        zIndex: JRule.zIndex + 1
        left: 0
        top: 0
        padding: "6px"
        backgroundColor: "#888"
        color: "#fafafa"
        fontSize: "12px"
        fontFamily: "sans-serif"
        fontWeight: 100
      underhand.apply_styles mouse_pos, style
      @mouse_pos = mouse_pos
      document.body.appendChild @mouse_pos

  create_tick: (side, pos, height=1, style_overrides={}) ->
    new_tick = document.createElement("div")
    style = underhand.extend @tick_style(side), style_overrides
    new_tick.className = "tick"

    if side == "top" || side == "bottom"
      style.left = "#{pos}px"
      style.height = "#{100*height}%"
    else
      style.top = "#{pos}px"
      style.width = "#{100*height}%"

    underhand.apply_styles new_tick, style
    new_tick

  draw_tick: (side, pos, height=1, style_overrides={}) ->
    if @rulers.hasOwnProperty side
      new_tick = @create_tick side, pos, height, style_overrides

      @rulers[side].appendChild new_tick
    else
      false

  destroy_rulers: ->
    for name, ruler of @rulers
      document.body.removeChild ruler

  destroy: ->
    underhand.remove_events @events, document.body

    document.body.removeChild @mouse_pos

    @destroy_rulers()

  render: ->
    if @opts.show_mouse
      if @mouse_ticks.x
        @mouse_ticks.x.style.left = "#{@mouse_tracker.mousex}px"
      if @mouse_ticks.y
        @mouse_ticks.y.style.top = "#{@mouse_tracker.mousey}px"

      underhand.set_text @mouse_pos, "#{@mouse_tracker.mousex}, #{@mouse_tracker.mousey}"

  toggle_visibility: ->
    @shown = !@shown

    for side, ruler of @rulers
      ruler.style.display = if @shown then "block" else "none"

    @shown
