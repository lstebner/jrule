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

    @shown

  destroy: ->
    @cleanup()
    underhand.remove_events @events, window
