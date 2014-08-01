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
