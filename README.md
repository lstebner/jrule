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

### Keyboard Controls

(if any of these don't seem to be working, click the body once to give focus then try)

- "r" - toggle visibility of rulers
- "c" - toggle visibility of crosshairs
- "g" - toggle visibility of grid
- "+/-" - increase/decrease the thickness of the crosshairs (good for measuring padding/margins)
- "shift" - hold to measure while moving the mouse

## Config

JRule will be highly configurable at some point, but is still in very early development so none of the options are exposed yet. 

## Bookmarklet

*note: The bookmarklet doesn't currently play well with https websites, but I will look into a fix for that in the near future*

The only thing easier than needing to include this code into your project is the fact that you can just add a bookmarklet to your toolbar and use that instead! Visit the [Hosted Demo](http://www.beansandhops.com/jrule.html) and just drag that link to your bookmarks bar to be able to use JRule on any of your own pages, or anyone elses! Just click it and it will inject the needed code onto the page you're currently viewing. Refresh the page after (or destroy JRule via the console) and everything will go back to as it was before.

## Using the Library Directly

## update 7/31/14

JRule was up until today a single file library, but it was getting far too unruly (pun-intended). So, I had to break it apart. In my development workflow I have used Codekit for several years now because I find it the easiest way to do this sort of thing without any extra configuration. 

tl;dr

JRule is now made up of multiple files and I'm relying on Codekit to compile the main one. All the components are now found under the `src` directory with main JRule classes in the `src/classes` folder and helpers in `src/helpers`.

If you only want the final compiled library, that's still one easy to use file but it's now `src/main.js`. 

=======================

Alternatively to the Bookmarklet, you may decide to clone the source and instantiate it yourself so that you have more control. Doing this is easy also because there is only one file you need to include, `jrule.js`. Once you have this included, you're done! It handles creating the `document.jruler` object on its own and you can then access any of the JRule methods/properties from there.

## Feedback

Was this helpful to you? Give me feedback and feature ideas! Thanks for checking out JRule! 

## Plans

These are the things that I've thought of to add, but feel free to file requests here on github if you think you have a good feature. 

- A customizable grid overlay
- Expose other configuration options (colors, tick distance, divisions, etc)
- Fixed ratio for Measuring Tool
- Fixed dimensions for Measuring Tool
- Snapping for measuring tool
- Factor in body offset for measuring elements taller than a page or getting the true offset of an item
- Additional Rulers on the right/bottom 
- Customizable crosshair thickness for easily checking padding/margins

## Bugs

Please file any bugs you find via Github! Also, please look to make sure someone else hasn't already filed the bug that you're going to file so there aren't duplicates. Thanks!
