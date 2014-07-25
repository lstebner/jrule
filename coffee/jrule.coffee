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
  
    @default_opts()
    @setup_rulers()
    
  default_opts: ->
    defaults = 
      style:
        backgroundColor: "#f1f1f1"
        opacity: .5
        tickColor: "#888"
      top: true
      left: true
      right: false
      bottom: false
      tick_distance: 100 #px
      rule_size: 25
      divisions: 8

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
      rule.style.zIndex = 9999 

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

  tick_style: (side) ->
    style =
      position: "absolute"
      display: "block" 

    if side == "top" || side == "bottom"
      style.borderRight = "1px solid #{@opts.style.tickColor}"
      style.width = "1px"
      style.height = "100%"
    else
      style.borderTop = "1px solid #{@opts.style.tickColor}"
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

  draw_tick: (side, pos, height=1) ->
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

    if @rulers.hasOwnProperty side
      @rulers[side].appendChild new_tick 
    else
      false

  destroy: ->









document.JRule = JRule




