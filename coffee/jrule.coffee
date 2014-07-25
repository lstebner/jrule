class JRule
  constructor: (@opts={}) ->
    @setup_border_rulers()
    console?.log 'jrule ready!'

  default_opts: ->

  setup_border_rulers: ->
    @border_rulers = new JRule.BorderRulers()
      
class JRule.BorderRulers
  constructor: (@opts={}) ->
    @rulers = {}
    @mouse_ticks = {}
    @mousex = 0
    @mousey = 0
  
    @default_opts()
    @setup_rulers()
    @setup_events()
    
  default_opts: ->
    defaults = 
      style:
        backgroundColor: "#f1f1f1"
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
      document.body.appendChild ruler

    @setup_ticks()

    @setup = true
    @

  setup_events: ->
    if @opts.show_mouse
      document.addEventListener 'mousemove', (e) =>
        @mousex = e.clientX
        @mousey = e.clientY
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

  setup_ticks: ->
    doc_rect = document.body.getBoundingClientRect()

    ticks = Math.ceil doc_rect.width / @opts.tick_distance
    tick_distance = Math.round doc_rect.width / ticks
    division_distance = Math.round tick_distance / @opts.divisions

    for side in ['top', 'left']
      for i in [0...ticks]
        tick_pos = i * tick_distance
        @draw_tick side, tick_pos, .8

        for j in [0...@opts.divisions]
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


  create_tick: (side, pos, height=1) ->
    new_tick = document.createElement("div")
    for key, val of @tick_style(side)
      new_tick.style[key] = val
    new_tick.className = "tick"

    if side == "top" || side == "bottom"
      new_tick.style.left = "#{pos}px"
      new_tick.style.height = "#{100*height}%"
    else
      new_tick.style.top = "#{pos}px"
      new_tick.style.width = "#{100*height}%"

    new_tick

  draw_tick: (side, pos, height=1) ->
    if @rulers.hasOwnProperty side
      new_tick = @create_tick side, pos, height
      @rulers[side].appendChild new_tick 
    else
      false

  destroy: ->

  render: ->
    if @opts.show_mouse
      if @mouse_ticks.x
        @mouse_ticks.x.style.left = "#{@mousex}px"
      if @mouse_ticks.y
        @mouse_ticks.y.style.top = "#{@mousey}px"

      @mouse_pos.innerText = "#{@mousex}, #{@mousey}"









document.JRule = JRule




