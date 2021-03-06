# Crosshair
#
# The crosshairs have two functions. The first (and maybe obvious) is to follow the 
# mouse and act as aiming crosshairs do with live updating. The second is that they
# can be placed statically. An example of this would be creating a Grid.
#
# This class is really just a "line" though because it allows you to easily create
# a single crosshair at a given position. The Grid and MouseTracker classes handle
# the more complex components of the above mentioned crosshair uses.  
#
# author: lstebner

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
      zIndex: JRule.zIndex

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
