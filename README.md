# Video player for Framer Studio

A video player for framer with rudimentary controls (play, pause, restart) that supports any video format that is supported in HTML5. Easy to install and with customisable colors, you can drop this into any prototype.

!(framer-media-container/moduleTester_framer.png)

## Why this is useful
The module is an extension of the Layer object, so you can do all the other stuff you usually do with a framer layer, like change it opacity, position, background color, etc. You can even animate the container, just like you would a normal layer.

## Installation
Drop the ``mediaContainer.coffee`` file into your framer app to automatically import or find your framer project and drop it in the ``../modules/`` folder

> *IMPORTANT* This module has a dependency on the awesome FontAwesome module for Framer by __Andreas Wahlström [https://github.com/awt2542/fontAwesome-for-Framer](https://github.com/awt2542/fontAwesome-for-Framer)__. If you are having problems like disappearing icons, then you've probably not installed this module properly. I've included the module files here including the ``*.coffee`` file and the necessary ``fonts`` folder

## Use

### To import the module
Make sure you include the line exactly as below, including curly brackets
````
{ MediaContainer } = require 'mediaContainer'
````

### To create a new media container video player
Create the media container like you would any other layer
````
# create a new layer
mc = new MediaContainer
````

By default:
- the default color scheme is a skyblue color for the UI controls and the progress fill of the scrubber and a transparent background for the media container itself
- the mediacontainer's control icons's and other sizes are proportional and look good using mobile devices inside Framer Studio - for example a Google Nexus 6P or an iPhone 7 Plus. However, they may need adjusting to work on other devices or screen sizes. Look later on in this _readme_ for instructions how to modify the UI.
- the video fits to the width of the screen in 16:9 ratio, unless you provide a ``width`` and a ``height`` value.

If you want to use a different device, or change the colors and sizes of UI elements, look later in this ``readme.md`` file

### To set the source video file 
Put your chosen video file inside your framer project. It's probably a good idea to create a new folder like "videos" and put the video in there. In this example, I've got a video called ``talkingtocamera.mp4``. I can set this as a the source for the video player like this:
````
mc.setVideoSrc("videos/talkingtocamera.mp4")
````

### To play and pause the video
#### Use UI controls
You can play, pause and restart the video using the UI controls in the prototype

//TODO: Add UI control screenshot here
#### Use a function call
To play the video
````
mc.playVideo()
````
To pause the video
````
mc.pauseVideo()
````

### To restart the video
Again, you can use the UI controls (including the scrubber). I will include restart functions in a later version of the module. 

### To reset the video
You can use the scrubber reset the video. The video will also automatically pause and return to the beginning when it reaches the end, but it will not auto play (i.e. repeat).

### To change the colors and other UI options
The module provides options to change ``KNOBSIZE`` and "SCRUBHEIGHT" of the slider, the ``controlColor`` of the slider fill and UI control elements, ``backgroundColor`` of the mediaContainer itself, ``BASEFONT`` size of the fontawesome control icons.

To change them, you can declare them on creation of the mediaContainer:
````
# create a new layer
mc = new MediaContainer
  BASEFONT: 100
  SCRUBHEIGHT: 100
  KNOBSIZE: 100
  controlColor: "red"
  backgroundColor: "white"
````

### ADVANCED 
The module calls a callback function called ``ended`` when a video ends. Out of the box, this is a useless function that does nothing, except instantly returns.

The module also provides a method for defining your own callback function. For example, you might want to animate text, or transition to a new view when the video ends. To do this, update the callback with your own function like so:

````
# define your own callback
callback = () ->
  #do something here

# replace the default 'ended' callback with this new one
mc.setEndedCallBack(callback)
````
Now, whenever a video ends, it will call your custom callback function. Be careful! If you try to pass a parameter to this function, it won't work, as it'll be called in the context of the module and the parameter won't be in scope.




