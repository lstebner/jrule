# This class has a few static methods to help with color conversions between rgb and hex. 
class JRule.ColorWheel
  # Convert an rgb string to hex
  @rgb_string_to_hex: (rgb="255, 255, 255") ->
    #convert the string into the 3 int's that actually make up r, g & b
    pieces = rgb.split(',')
    rgb = []
    for p, i in pieces
      rgb[i] = parseInt(p)
 
    #pipe those values to rgb_to_hex method for conversion
    @rgb_to_hex rgb[0], rgb[1], rgb[2]
    
  # Convert rgb values to their hex equivelant
  @rgb_to_hex: (r=0, g=0, b=0) ->
    if typeof r == "string"
      return @rgb_string_to_hex r

    #this just makes sure that hex values are 0 padded when they are low
    convert = (i) ->
      i = i.toString(16)
      if i.length == 1 then i = "0#{i}"
      i
 
    #convert all the pieces for the final hex
    hex = "#{convert(r)}#{convert(g)}#{convert(b)}"
 
  # Convert a hex string to the rgb equivelant
  # hex can be a 3 or 6 char value, with or without the leading "#"
  @hex_to_rgb: (hex="ffffff", as_ints=false) ->
    #remove leading #
    hex = hex.replace("#", "")
    proper_hex = hex
 
    #if we got a 3 char hex, double up each piece for the legit hex
    if hex.length == 3
      proper_hex = ""
 
      for char in hex
        proper_hex += char + char
 
    #pull out the hex value that makes up each r, g, b piece
    r = proper_hex.substr(0, 2)
    g = proper_hex.substr(2, 2)
    b = proper_hex.substr(4, 2)

    val = (what) -> parseInt(what, 16)
 
    return if as_ints
      [val(r), val(g), val(b)]
    else
      #return each of those converted to hex and concatted together
      rgb = "#{val(r)}, #{val(g)}, #{val(b)}"
 
  # Convenience wrapper to convert to rgb + alpha channel
  @hex_to_rgba: (hex="fff", a=1) ->
    @hex_to_rgb(hex) + ", #{a}"

  @is_hex_valid: (hex_string, require_hash=false) ->
    if require_hash
      /(^#[0-9A-F]{6}$)|(^#[0-9A-F]{3}$)/i.test hex_string
    else
      /(^[0-9A-F]{6}$)|(^[0-9A-F]{3}$)/i.test hex_string

  @is_rgb_valid: (rgb_string) ->
    pieces = rgb_string.split(",")
    return false if pieces.length != 3

    for num in pieces
      return false if parseInt(num).toString() == "NaN"
      val = parseInt(num)
      return false if num > 255

    true

class JRule.Color
  constructor: (value="", alpha=1) ->
    @hex_value = ""
    @rgb_value = ""
    @r = 0
    @g = 0
    @b = 0
    @a = alpha

    @parse_value value

  parse_value: (@value) ->
    if @value.indexOf(",") > -1
      pieces = @value.split(",")
      @r = parseInt pieces[0]
      @g = parseInt pieces[1]
      @b = parseInt pieces[2]

      if pieces.length == 4
        @a = parseFloat pieces[3]

      @hex_value = JRule.ColorWheel.rgb_to_hex(@r, @g, @b)

    else if @value.indexOf("#") > -1
      @hex_value = @value.replace("#", "")
      [@r, @g, @b] = JRule.ColorWheel.hex_to_rgb(@hex_value, true)

  rgb: ->
    "#{@r}, #{@g}, #{@b}"

  rgba: ->
    "#{@rgb()}, #{@a}"

  hex: ->
    "#{@hex_value}"

  style: (property) ->
    c = if @a != 1
      "rgba(#{@rgba()})"
    else
      "##{@hex()}"

    return if property
      "#{property}: #{c};"
    else
      c

class JRule.ColorWheel.UI
  constructor: (@opts={}) ->
    @default_opts()
    @setup()

  default_opts: ->
    underhand.extend(
      {}
      @opts
    )

  setup: ->
    #create main container
    d = document.createElement "div"
    style =
      position: "fixed"
      top: "50%"
      left: "50%"
      width: "500px"
      height: "260px"
      marginLeft: "-250px"
      marginTop: "-130px"
      border: "1px solid #333"
      backgroundColor: "#fff"
      padding: "25px"

    underhand.apply_styles d, style

    @container = d
    document.body.appendChild @container

    #create form
    form = document.createElement "form"
    hex_label = document.createElement "label"
    underhand.set_text hex_label, "Hex"
    @hex_input = document.createElement "input"
    @hex_input.setAttribute "name", "hex_value"

    hex_label.appendChild @hex_input
    form.appendChild hex_label

    rgb_label = document.createElement "label"
    underhand.set_text rgb_label, "RGB"
    @rgb_input = document.createElement "input"
    @rgb_input.setAttribute "name", "rgb_value"

    rgb_label.appendChild @rgb_input
    form.appendChild rgb_label

    @swatch = document.createElement "swatch"
    swatch_style =
      display: "inline-block"
      width: "32px"
      height: "32px"
    underhand.apply_styles @swatch, swatch_style
    form.appendChild @swatch

    @form = form
    @container.appendChild @form

    @setup_events()

  destroy: ->
    underhand.remove_events @events, @container

  setup_events: ->
    @events ||= []

    keyup = (e) =>
      if e.target.nodeName.toLowerCase() == "input"
        @read_form(e.target.name)

    @events.push { type: "keyup", fn: keyup }

    underhand.add_events @events, @container

  read_form: (from='hex_value') ->
    if from == 'hex_value' && @is_hex_valid()
      @color = new JRule.Color "##{@hex_value()}"
      @rgb_input.value = @color.rgb()
      @color_swatch()

    else if from == "rgb_value" && @is_rgb_valid()
      @color = new JRule.Color @rgb_value()
      @hex_input.value = @color.hex()
      @color_swatch()

  is_hex_valid: ->
    JRule.ColorWheel.is_hex_valid @hex_value()

  is_rgb_valid: ->
    JRule.ColorWheel.is_rgb_valid @rgb_value()

  hex_value: ->
    @hex_input.value

  rgb_value: ->
    @rgb_input.value

  color_swatch: ->
    return unless @color
    @swatch.style.backgroundColor = @color.style()


