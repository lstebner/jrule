# Messenger
#
# This class is used for sending messages to the user. These are mostly done in 
# the form of notifications which live in the top right of the screen for a short
# period of time and then expire. 
#
# Messages can contain either plain text content or html content. The duration
# can also be configured and passing 0 would make a message last infinitely, or 
# until dismissed from some other means such as manually or by being clicked. There
# is no content length restriction for messages, but a css maxWidth is enforced.
#
# Messenger provides a static 'alert' method which can be used to flash messages
# easily. If you use this, you get the added bonus of Messenger managing a message
# stack and destroying them when they've completed their jobs. 
#
# author: lstebner

class JRule.Messenger
  @alert: (msg, opts={}) ->
    return if !JRule.talkative && !opts.force

    @message_stack ||= []

    @message_stack.push new JRule.Messenger underhand.extend
      content: msg
      is_flash: true
    , opts

    #if there is more than one message in the stack then we will literally stack them
    #up so they aren't overlapping
    if @message_stack.length > 1
      y = 36
      request_cleanup = false

      for m, i in @message_stack
        #when a message gets marked destroyed below then it becomes undefined in the
        #message_stack so this checks for it and requests those to be cleaned up
        if !m
          request_cleanup = true
        else if m.visible
          m.container.style.top = "#{y}px"
          y += m.container.clientHeight + 6
        else if m.destroyed
          delete @message_stack[i]
          request_cleanup = true

      if request_cleanup
        @cleanup_message_stack()

  #this method checks the message_stack for any messages that have been destroyed
  #and removes them to keep it small. it is called periodically from @alert when
  #a message that needs cleaned up is detected, but it is possible that the
  #message_stack at any time could contain several invalid messages that haven't
  #been cleaned out yet
  @cleanup_message_stack: ->
    copy = []
    for m in @message_stack
      copy.push(m) if m && !m.destroyed

    @message_stack = copy

  constructor: (@opts={}) ->
    @container = null
    @default_opts()
    @create()
    @setup_events()

  setup_events: ->
    @events ||= []

    return unless @container

    onclick = (e) =>
      e.preventDefault()
      @hide()

    @events.push { type: 'click', fn: onclick }

    underhand.add_events @events, @container

  default_opts: ->
    defaults =
      content: ''
      html_content: false
      duration: 5000
      show: true
      is_flash: false
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
      top: "36px"
      right: "10px"
      padding: "8px 12px"
      backgroundColor: "rgba(0, 0, 0, .8)"
      color: "#fff"
      display: "none"
      zIndex: 5000
      fontSize: "14px"
      fontFamily: "sans-serif"
      borderRadius: "3px"
      maxWidth: "300px"
      cursor: "pointer"

    if @opts.colors.hasOwnProperty @opts.type
      style.backgroundColor = @opts.colors[@opts.type]

    underhand.apply_styles d, style
    if @opts.html_content
      d.innerHTML = @opts.html_content
    else
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
    clearTimeout(@timeout) if @timeout

    @destroy() if @opts.is_flash

  toggle: ->
    if @visible then @hide() else @show()

  destroy: ->
    document.body.removeChild @container
    @destroyed = true
    underhand.remove_events @events, @container
