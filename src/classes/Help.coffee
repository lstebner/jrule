# Help! - extends Messenger
#
# This class is really just a Messenger message that contains a lot of content so it was
# easiest to break it out. For convenience, there is also a static method to retrieve a
# single instance of Help to be reused.
#
# author: lstebner

class JRule.Help extends JRule.Messenger.Notification
  @get: ->
    @help ||= new JRule.Help()

  default_opts: ->
    content = "
      Welcome to JRule! Thanks for using it.
      <br><br>
      JRule helps you measure and line things up. It's simple to use, here are some controls:
      <br>
      Press 'c' to toggle the Crosshairs<br>
      Press 'g' to toggle the Grid<br>
      Press 'r' to toggle the Rulers<br>
      Hold 'shift' and move the mouse to Measure<br>
      Press 'h' to see this message again<br>
      Click this message to get rid of it<br>
      Press 'escape' to remove JRule when you're done<br>
    "

    underhand.extend super,
      html_content: content
      is_flash: false
      show: false #this false value is actually a trick because when .toggle() is called
                  #immediately after creation, the message ends up visible
      duration: 0
