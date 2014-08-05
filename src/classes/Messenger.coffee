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
  @notify: (msg, opts={}) ->
    return if !JRule.talkative && !opts.force

    if opts.is_html
      opts.html_content = msg
      opts.content = ''

    msg = new JRule.Messenger.Notification underhand.extend
      content: msg
      is_flash: true
    , opts

    @add_message_to_stack msg

  @flash: (msg, opts={}) ->
    return if !JRule.talkative && !opts.force

    if opts.is_html
      opts.html_content = msg
      opts.content = ''

    msg = new JRule.Messenger.Flash underhand.extend
      content: msg
      is_flash: true
    , opts

    @add_message_to_stack msg

  @add_message_to_stack: (msg) ->
    @message_stack ||= []

    @message_stack.push msg

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

# generic message class, inherited by specific message types
class JRule.Messenger.Message extends JRule.GUIObject
  setup_events: ->
    @events ||= []

    return unless @container

    onclick = (e) =>
      return true if e.target.tagName.toLowerCase() == "a"

      e.preventDefault()
      @hide()

    @events.push { type: 'click', fn: onclick }

    mouseenter = (e) =>
      clearTimeout(@timeout) if @timeout

    @events.push { type: 'mouseenter', fn: mouseenter }

    mouseleave = (e) =>
      @timeout = setTimeout =>
        @hide()
      , 500

    @events.push { type: 'mouseleave', fn: mouseleave }

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

  classes: ->
    ["message", @opts.type]

  style: ->
    style =
      display: "none"

    if @opts.colors.hasOwnProperty @opts.type
      style.backgroundColor = @opts.colors[@opts.type]

    underhand.extend super(), style

  create: ->
    super

    if @opts.html_content
      @container.innerHTML = @opts.html_content
    else
      underhand.set_text @container, @opts.content

    @show() if @opts.show

  show: ->
    super

    if @opts.duration
      @timeout = setTimeout =>
        @hide()
      , @opts.duration

  hide: ->
    super

    clearTimeout(@timeout) if @timeout
    @destroy() if @opts.is_flash

# top right corner notification bubble
class JRule.Messenger.Notification extends JRule.Messenger.Message
  style: ->
    style = 
      top: "36px"
      right: "10px"
      display: "none"
      borderRadius: "3px"
      minWidth: "200px"
      maxWidth: "300px"
      textAlign: "left"

    underhand.extend super(), style

# top flash message which spans entire width
class JRule.Messenger.Flash extends JRule.Messenger.Message
  style: ->
    underhand.extend(
      super
      {
        top: 0
        left: 0
        right: 0
        textAlign: "center"
        fontSize: "18px"
        padding: "12px"
        backgroundColor: "#333"
      }
    )

  default_opts: ->
    @opts = underhand.extend(
      super,
      {
        is_flash: true
        duration: 3000
      }
    )
