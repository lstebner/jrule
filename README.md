# JRule - Line that thang up

While working with designers to develop pages I often find myself using the built in OSX screen capture tool to measure things and check if they're lined up. There are other applications out there that provide measuring functionality, but I don't really want to run yet another application and I definitely don't want to pay for it. The screenshot tool does the job, but it's not the job it intends to do and therefore it doesn't do it very well.

Enter JRule.

JRule provides a JavaScript solution to measuring things. It introduces rulers, crosshairs and a simple measuring mechanic that can can be used as easily as including a script.

## Try It Out

I could tell you all about it, but why don't you just try it out for yourself?

[Hosted Demo](http://beansandhops.com/jrule.html)

Just click "JRule" on that page and you'll see it instantiate, from there, check out the controls listed below.

## Controls/Features

By default, when instantiating JRule you'll get horizontal and vertical rulers on the top and left of your screen. It will also indicate your mouse position in screen coordinates in the upper left. Note that it *does not* take into account the body being scrolled at this time, but it will in the future. 

Hold down shift (click anywhere on the body once if this doesn't work the first time) and then drag your mouse to be able to measure. 

If you want to toggle the crosshairs, simply pop open the console and type `document.jruler.toggle_crosshairs()`.

## Config

JRule will be highly configurable at some point, but is still in very early development so none of the options are exposed yet. 

## Bookmarklet

The only thing easier than needing to include this code into your project is the fact that you can just add a bookmarklet to your toolbar and use that instead! Visit the [Hosted Demo](http://www.beansandhops.com/jrule.html) and just drag that link to your bookmarks bar to be able to use JRule on any of your own pages, or anyone elses! Just click it and it will inject the needed code onto the page you're currently viewing. Refresh the page after (or destroy JRule via the console) and everything will go back to as it was before.

## Feedback

Was this helpful to you? Give me feedback and feature ideas! Thanks for checking out JRule! 


