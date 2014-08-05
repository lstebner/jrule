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
    #this just makes sure that hex values are 0 padded when they are low
    convert = (i) ->
      i = i.toString(16)
      if i.length == 1 then i = "0#{i}"
      i
 
    #convert all the pieces for the final hex
    hex = "#{convert(r)}#{convert(g)}#{convert(b)}"
 
  # Convert a hex string to the rgb equivelant
  # hex can be a 3 or 6 char value, with or without the leading "#"
  @hex_to_rgb: (hex="ffffff") ->
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
 
    #return each of those converted to hex and concatted together
    rgb = "#{parseInt(r, 16)}, #{parseInt(g, 16)}, #{parseInt(b, 16)}"
 
  # Convenience wrapper to convert to rgb + alpha channel
  @hex_to_rgba: (hex="fff", a=1) ->
    @hex_to_rgb(hex) + ", #{a}"
