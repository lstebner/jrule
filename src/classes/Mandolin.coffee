# Mandolin
#
# Mandolin is the Slicing tool provided with JRule. It allows you to create horizontal Slices
# along with vertical Divides. These are essentially custom positioned Crosshair indicators
# at given intervals. It also can calculate in snapping. 
#
# author: lstebner

class JRule.Mandolin
  constructor: (@opts={}) ->
    @slices = []
    @tracker = JRule.MouseTracker.get_tracker()

    @default_opts()
    @setup_events()

  default_opts: ->
    defaults =
      snap: false
      snap_to: 10
      style:
        sliceColor: "rgba(150, 150, 150, .5)"

    @opts = underhand.defaults defaults, @opts

  setup_events: ->
    @events ||= []

    keydown = (e) =>
      if e.keyCode == 83 #s
        @create_slice_at_mouse()
      else if e.keyCode == 68 #d
        @create_divide_at_mouse()

    @events.push { type: "keydown", fn: keydown }

    underhand.add_events @events

  get_snap_for: (pos) ->
    snap_to = pos
    snapped = pos % @opts.snap_to == 0
    i = 0

    while !snapped
      i += 1
      if (pos + i) % @opts.snap_to == 0
        snap_to = pos + i
        snapped = true
      else if (pos - i) % @opts.snap_to == 0
        snap_to = pos - i
        snapped = true

    snap_to

  create_slice: (pos) ->
    pos = @get_snap_for(pos) if @opts.snap

    slice = JRule.Crosshair.create 'x', "#{pos}px", {
      backgroundColor: @opts.style.sliceColor
    }

    JRule.Messenger.alert "Slice created at #{pos}px"

    document.body.appendChild slice
    @slices.push slice

  create_divide: (pos) ->
    pos = @get_snap_for(pos) if @opts.snap

    slice = JRule.Crosshair.create 'y', "#{pos}px", {
      backgroundColor: @opts.style.sliceColor
    }

    JRule.Messenger.alert "Divide created at #{pos}px"

    document.body.appendChild slice
    @slices.push slice

  create_slice_at_mouse: ->
    @create_slice @tracker.mousex

  create_divide_at_mouse: ->
    @create_divide @tracker.mousey

  clear_slices: ->
    for s in @slices
      document.body.removeChild s

    @slices = []

  hide_slices: ->
    s.style.display = "none" for s in @slices

  show_slices: ->
    s.style.display = "block" for s in @slices

  destroy: ->
    @clear_slices()
    underhand.remove_events @events

