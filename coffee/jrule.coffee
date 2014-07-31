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


class JRule
  constructor: (@opts={}) ->
    @setup_border_rulers()
    @setup_caliper()
    @setup_grid()
    @mouse_tracker = JRule.MouseTracker.get_tracker()
    @setup_events()

    console?.log 'jrule ready!'

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

class JRule.Crosshair
  @create: (axis, pos="50%", style={}) ->
    style_defaults = 
      crosshairColor: "rgba(100, 100, 100, .5)"
      crosshairThickness: 1

    for key, val of style_defaults
      if !style.hasOwnProperty(key)
        style[key] = val

    crosshair = document.createElement "div"
    styles =
      position: "fixed"
      backgroundColor: "#{style.crosshairColor}"
      zIndex: 4000

    crosshair.className = "crosshair"

    if axis == "x" || axis == "horizontal"
      underhand.extend styles,
        width: "#{style.crosshairThickness}px"
        top: 0
        bottom: 0
        left: "#{pos}"
    else
      underhand.extend styles,
        height: "#{style.crosshairThickness}px"
        left: 0
        right: 0
        top: "#{pos}"

    underhand.apply_styles crosshair, styles

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

  destroy: ->
    @remove_crosshairs()
    underhand.remove_events @events


      
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
      rule.className = "ruler" 

      styles = @get_style()
      underhand.extend styles,
        position: "fixed"
        zIndex: 4000

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
    @

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
      style = 
        position: "fixed"
        zIndex: 5000
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

  destroy: ->
    underhand.remove_events @events, document.body

    document.body.removeChild @mouse_pos

    for name, ruler of @rulers
      document.body.removeChild ruler

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
        zIndex: 5000
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
      zIndex: 3999
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
    @events ||= []
    @window_resizing = false
    @resize_to = null

    resize = (e) =>
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

    underhand.add_events @events, window


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

  destroy: ->
    @cleanup()
    underhand.remove_events @events, window

document.JRule = JRule

ready = ->
  document.jruler = new document.JRule();

if document.readyState != "complete"
  document.addEventListener 'DOMContentLoaded', ->
    ready()
else
  ready()



class JRule.Messenger
  @alert: (msg) ->
    @message_stack ||= []

    @message_stack.push new JRule.Messenger
      content: msg

    if @message_stack.length > 1
      y = 10

      for m in @message_stack
        if m.visible
          m.container.style.top = "#{y}px"
          y += m.container.clientHeight + 6

  constructor: (@opts={}) ->
    @container = null
    @default_opts()
    @create()

  default_opts: ->
    defaults = 
      content: ''
      duration: 5000
      show: true
      type: ''
      colors: 
        alert: "rgba(0, 0, 0, .75)"
        error: "rgba(0, 0, 0, .75)"

    @opts = underhand.defaults defaults, @opts

  create: ->
    d = document.createElement "div"
    d.className = "message #{@opts.type}"

    style = 
      position: "fixed"
      top: "10px"
      right: "10px"
      padding: "8px 12px"
      backgroundColor: "rgba(0, 0, 0, .8)"
      color: "#fff"
      display: "none"
      zIndex: 5000
      fontSize: "12px"
      fontFamily: "sans-serif"
      borderRadius: "3px"
      maxWidth: "300px"

    if @opts.colors.hasOwnProperty @opts.type
      style.backgroundColor = @opts.colors[@opts.type]

    underhand.apply_styles d, style
    underhand.set_text d, @opts.content

    @container = d
    document.body.appendChild @container

    @show() if @opts.show

  show: ->
    @create() if !@container
    @container.style.display = "block"
    @visible = true

    if @opts.duration
      @timeout = setTimeout =>
        @hide()
      , @opts.duration

  hide: ->
    @visible = false
    @container.style.display = "none"

  destroy: ->
    document.body.removeElement @container









