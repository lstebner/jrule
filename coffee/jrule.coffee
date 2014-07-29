set_text = (el, content) ->
  if el.innerText
    el.innerText = content
  else
    el.textContent = content

class JRule
  constructor: (@opts={}) ->
    @setup_border_rulers()
    @setup_caliper()
    @setup_grid()
    @mouse_tracker = JRule.MouseTracker.get_tracker()
    @setup_events()

    console?.log 'jrule ready!'

  default_opts: ->

  setup_events: ->
    document.addEventListener 'keydown', (e) =>
      if e.keyCode == 67 #c
        @toggle_crosshairs()
      else if e.keyCode == 82 #r
        @toggle_rulers()
      else if e.keyCode == 71 #g
        @toggle_grid()

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

class JRule.Crosshair
  @create: (axis, pos="50%", style={}) ->
    style_defaults = 
      crosshairColor: "rgba(100, 100, 100, .5)"
      crosshairThickness: 1

    for key, val of style_defaults
      if !style.hasOwnProperty(key)
        style[key] = val

    crosshair = document.createElement "div"
    crosshair.style.position = "fixed"
    crosshair.style.backgroundColor = "#{style.crosshairColor}"
    crosshair.style.zIndex = 4000
    crosshair.className = "crosshair"

    if axis == "x" || axis == "horizontal"
      crosshair.style.width = "#{style.crosshairThickness}px"
      crosshair.style.top = 0
      crosshair.style.bottom = 0
      crosshair.style.left = "#{pos}"
    else
      crosshair.style.height = "#{style.crosshairThickness}px"
      crosshair.style.left = 0
      crosshair.style.right = 0
      crosshair.style.top = "#{pos}"

    crosshair

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

    #todo: use extend
    for key, val of defaults
      if !@opts.hasOwnProperty key
        @opts[key] = val

    @opts

  setup_events: ->
    document.addEventListener 'mousemove', (e) =>
      @mousex = e.clientX
      @mousey = e.clientY
      event = new Event 'jrule:mousemove'
      document.body.dispatchEvent event

      @render_crosshairs() if @opts.show_crosshairs

    document.addEventListener 'keydown', (e) =>
      if e.keyCode == 187 #+
        @increase_crosshair_size()
      else if e.keyCode == 189 #-
        @decrease_crosshair_size()

  increase_crosshair_size: ->
    @opts.style.crosshairThickness += 1
    @crosshairs.x?.style.width = "#{@opts.style.crosshairThickness}px"
    @crosshairs.y?.style.height = "#{@opts.style.crosshairThickness}px"

  decrease_crosshair_size: ->
    @opts.style.crosshairThickness = Math.max 1, @opts.style.crosshairThickness - 1
    @crosshairs.x?.style.width = "#{@opts.style.crosshairThickness}px"
    @crosshairs.y?.style.height = "#{@opts.style.crosshairThickness}px"

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

  remove_crosshairs: ->
    for coord, c of @crosshairs
      document.body.removeChild c

    @crosshairs = null

      
class JRule.BorderRulers
  constructor: (@opts={}) ->
    @rulers = {}
    @mouse_ticks = {}
    @mouse_tracker = JRule.MouseTracker.get_tracker()
  
    @default_opts()
    @setup_rulers()
    @setup_events()
    
  default_opts: ->
    defaults = 
      style:
        backgroundColor: "#aaa"
        opacity: .5
        tickColor: "#ccc"
        mouseTickColor: "#00f"
      top: true
      left: true
      right: false
      bottom: false
      tick_distance: 100 #px
      rule_size: 25
      divisions: 8
      show_mouse: true
      show_labels: true
      start_in_center: true

    #todo: actual extend of defaults with given @opts
    @opts = defaults

  get_style: ->
    backgroundColor: @opts.style.backgroundColor
    opacity: @opts.style.opacity

  setup_rulers: (force=false) ->
    return if @setup && !force

    @destroy() if @setup && force
    
    create_ruler = =>
      rule = document.createElement("div")
      for key, val of @get_style()
        rule.style[key] = val

      rule.className = "ruler"
      rule.style.position = "fixed"
      rule.style.zIndex = 4000 

      rule
      
    if @opts.top
      top_ruler = create_ruler()
      top_ruler.style.left = 0
      top_ruler.style.right = 0
      top_ruler.style.top = 0
      top_ruler.style.height = "#{@opts.rule_size}px" 
      @rulers.top = top_ruler

    if @opts.left
      left_ruler = create_ruler()
      left_ruler.style.left = 0
      left_ruler.style.top = 0
      left_ruler.style.bottom = 0
      left_ruler.style.width = "#{@opts.rule_size}px"
      @rulers.left = left_ruler
  
    for name, ruler of @rulers
      #investigate why this causes an error initially
      document.body?.appendChild ruler

    @setup_ticks()

    @shown = true
    @setup = true
    @

  setup_events: ->
    if @opts.show_mouse
      document.body.addEventListener 'jrule:mousemove', (e) =>
        @render()

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
    set_text label, "#{pos}px"
    label.style.position = "absolute"
    label.style.fontSize = "10px"
    label.style.fontFamily = "sans-serif"

    if side == "top"
      label.style.left = "#{pos}px"
      label.style.bottom = "2px"
      label.style.marginLeft = "-14px"
    else
      label.style.top = "#{pos}px"
      label.style.left = "4px"
      label.style["-webkit-transform"] = "rotate(-90deg)"
      label.style["transform"] = "rotate(-90deg)"
      label.style["-moz-transform"] = "rotate(-90deg)"

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

        for j in [1...@opts.divisions]
          div_pos = j * division_distance + tick_pos
          @draw_tick side, div_pos, (if j % 2 then .3 else .5)

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
      mouse_pos.style.position = "fixed"
      mouse_pos.style.zIndex = 5000
      mouse_pos.style.left = 0
      mouse_pos.style.top = 0
      mouse_pos.style.padding = "6px"
      mouse_pos.style.backgroundColor = "#888"
      mouse_pos.style.color = "#fafafa"
      mouse_pos.style.fontSize = "12px"
      mouse_pos.style.fontFamily = "sans-serif"
      mouse_pos.style.fontWeight = 100
      @mouse_pos = mouse_pos
      document.body.appendChild @mouse_pos


  create_tick: (side, pos, height=1, style_overrides={}) ->
    new_tick = document.createElement("div")
    for key, val of @tick_style(side)
      if style_overrides.hasOwnProperty key
        new_tick.style[key] = style_overrides[key]
      else
        new_tick.style[key] = val
    new_tick.className = "tick"

    if side == "top" || side == "bottom"
      new_tick.style.left = "#{pos}px"
      new_tick.style.height = "#{100*height}%"
    else
      new_tick.style.top = "#{pos}px"
      new_tick.style.width = "#{100*height}%"

    new_tick

  draw_tick: (side, pos, height=1, style_overrides={}) ->
    if @rulers.hasOwnProperty side
      new_tick = @create_tick side, pos, height, style_overrides

      @rulers[side].appendChild new_tick 
    else
      false

  destroy: ->

  render: ->
    if @opts.show_mouse
      if @mouse_ticks.x
        @mouse_ticks.x.style.left = "#{@mouse_tracker.mousex}px"
      if @mouse_ticks.y
        @mouse_ticks.y.style.top = "#{@mouse_tracker.mousey}px"

      set_text @mouse_pos, "#{@mouse_tracker.mousex}, #{@mouse_tracker.mousey}"

  toggle_visibility: ->
    @shown = !@shown

    for side, ruler of @rulers
      ruler.style.display = if @shown then "block" else "none"



class JRule.Caliper
  constructor: (@opts={}) ->
    @mouse_tracker = JRule.MouseTracker.get_tracker()
    @crosshairs = []
    @setup_events()

  setup_events: ->
    document.addEventListener 'keydown', (e) =>
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

    document.body.addEventListener 'jrule:mousemove', =>
      @render()

  render: ->
    if @measuring
      x = Math.min(@mouse_tracker.mousex, @start_pos[0])
      y = Math.min(@mouse_tracker.mousey, @start_pos[1])
      width = Math.max(@mouse_tracker.mousex, @start_pos[0]) -  Math.min(@mouse_tracker.mousex, @start_pos[0])
      height = Math.max(@mouse_tracker.mousey, @start_pos[1]) -  Math.min(@mouse_tracker.mousey, @start_pos[1])
      @indicator.style.width = "#{width}px"
      @indicator.style.height = "#{height}px"
      @indicator.style.left = "#{x}px"
      @indicator.style.top = "#{y}px"
      @indicator.style.zIndex = 5000
      @indicator_size.style.display = 'block'

      h_dir = if @start_pos[0] > @mouse_tracker.mousex then "left" else "right"
      v_dir = if @start_pos[1] > @mouse_tracker.mousey then "up" else "down"
      @drag_direction = [h_dir, v_dir]

      if h_dir == "left"
        @indicator_size.style.left = 0
        @indicator_size.style.right = "auto"
      else
        @indicator_size.style.right = 0
        @indicator_size.style.left = "auto"

      if v_dir == "up"
        @indicator_size.style.top = 0
        @indicator_size.style.bottom = "auto"
      else
        @indicator_size.style.bottom = 0
        @indicator_size.style.top = "auto"

      set_text @indicator_size, "#{width}, #{height}"

  setup_indicators: ->
    indicator = document.createElement "div"
    indicator.style.position = "fixed"
    indicator.style.left = "#{@start_pos[0]}px"
    indicator.style.top = "#{@start_pos[1]}px"
    indicator.style.backgroundColor = "rgba(100, 100, 100, .4)"
    indicator.style.zIndex = 3999
    @indicator = indicator
    document.body.appendChild @indicator

    indicator_size = document.createElement "div"
    indicator_size.style.position = "absolute"
    indicator_size.style.right = 0
    indicator_size.style.bottom = 0
    indicator_size.style.fontFamily = "sans-serif"
    indicator_size.style.fontSize = "12px"
    indicator_size.style.backgroundColor = "#000"
    indicator_size.style.color = "#fff"
    indicator_size.style.padding = "3px"
    indicator_size.style.zIndex = 1
    @indicator_size = indicator_size
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

class JRule.Grid
  constructor: (@opts={}) ->
    @default_opts()
    @setup_grid()
    @setup_events()

  default_opts: ->
    defaults = 
      tick_distance: 100 #px
      divisions: 3
      show: false
      start_in_center: true #if true, 0,0 is center of screen. default is top, left
      style:
        tickLineColor: "rgba(191, 231, 243, .6)"
        divisionLineColor: "rgba(220, 220, 220, .3)"
        centerLineColor: "rgba(255, 0, 0, .3)"

    for key, val of defaults
      if !@opts.hasOwnProperty key
        @opts[key] = val
      #one level deep for now, should make recursive. 
      else if typeof @opts[key] == "object"
        for key2, val2 of @opts[key]
          if !@opts[key].hasOwnProperty key2
            @opts[key][key] = val2

    @opts

  setup_events: ->
    @window_resizing = false
    @resize_to = null

    window.addEventListener 'resize', (e) =>
      if @window_resizing
        clearTimeout(@resize_to) if @resize_to
        @resize_to = setTimeout =>
          @window_resizing = false
          @setup_grid()
          @show_ticks()
        , 400
      else
        @window_resizing = true
        @cleanup()


  setup_grid: ->
    center_x = Math.round document.documentElement.clientWidth / 2
    center_y = Math.round document.documentElement.clientHeight / 2
    num_ticks = Math.ceil document.documentElement.clientWidth / @opts.tick_distance
    division_distance = if @opts.divisions > 0 then Math.round(@opts.tick_distance / @opts.divisions) else 0
    @ticks = []

    if @opts.start_in_center
      num_ticks = num_ticks / 2
      @ticks.push JRule.Crosshair.create 'x', "#{center_x}px", { crosshairColor: @opts.style.centerLineColor }
      @ticks.push JRule.Crosshair.create 'y', "#{center_y}px", { crosshairColor: @opts.style.centerLineColor }      

      if @opts.divisions > 0
        for n in [1...@opts.divisions]
          @ticks.push JRule.Crosshair.create 'x', "#{center_x + n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }
          @ticks.push JRule.Crosshair.create 'y', "#{center_y + n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }
          @ticks.push JRule.Crosshair.create 'x', "#{center_x - n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }
          @ticks.push JRule.Crosshair.create 'y', "#{center_y - n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }

    for i in [1...num_ticks]
      offset = i * @opts.tick_distance
      x_offset = if @opts.start_in_center
        center_x + offset
      else
        offset

      y_offset = if @opts.start_in_center
        center_y + offset
      else
        offset

      @ticks.push JRule.Crosshair.create 'x', "#{x_offset}px", { crosshairColor: @opts.style.tickLineColor }
      @ticks.push JRule.Crosshair.create 'y', "#{y_offset}px", { crosshairColor: @opts.style.tickLineColor }

      if @opts.divisions > 0
        for n in [1...@opts.divisions]
          @ticks.push JRule.Crosshair.create 'x', "#{x_offset + n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }
          @ticks.push JRule.Crosshair.create 'y', "#{y_offset + n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }

      if @opts.start_in_center
        @ticks.push JRule.Crosshair.create 'x', "#{center_x - offset}px", { crosshairColor: @opts.style.tickLineColor }
        @ticks.push JRule.Crosshair.create 'y', "#{center_y - offset}px", { crosshairColor: @opts.style.tickLineColor }        

        if @opts.divisions > 0
          for n in [1...@opts.divisions]
            @ticks.push JRule.Crosshair.create 'x', "#{center_x - offset - n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }
            @ticks.push JRule.Crosshair.create 'y', "#{center_y - offset - n * division_distance}px", { crosshairColor: @opts.style.divisionLineColor }

    for t in @ticks
      document.body.appendChild t

    if @opts.show
      @show_ticks()
    else
      @hide_ticks()

  cleanup: ->
    for t in @ticks
      document.body.removeChild t

  hide_ticks: ->
    @shown = false
    for t in @ticks
      t.style.display = "none"

  show_ticks: ->
    @shown = true
    for t in @ticks
      t.style.display = "block"

  toggle_grid: ->
    @shown = !@shown

    if @shown
      @show_ticks()
    else
      @hide_ticks()

document.JRule = JRule

ready = ->
  document.jruler = new document.JRule();

if document.readyState != "complete"
  document.addEventListener 'DOMContentLoaded', ->
    ready()
else
  ready()



