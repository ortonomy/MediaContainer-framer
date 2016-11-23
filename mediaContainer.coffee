class exports.MediaContainer extends Layer
    constructor: (opts={}) ->

        # color and size constants
        INVISIBLE = "rgba(255, 255, 255, 0)"
        SKYBLUE =  "#46C3D4"
        GREY = "#AAA"
        WHITE = "#FFF"
        DEFAULT = "FAFAFA"
        BASEFONT = 10
        RATIO169 = 0.5625
        # options for font
        opts.fontMultiplier ?= 4

        # options for MediaContainer itself
        opts.name = "MediaContainer"
        opts.width ?= Screen.width
        opts.height ?= Screen.width * RATIO169

        # options for colors
        opts.backgroundColor ?= INVISIBLE
        opts.controlColor ?= SKYBLUE

        # options for slider
        opts.knobSize ?= ( opts.height / 6 ) * .6
        opts.knobRadius ?= "50%"
        opts.knobColor ?= WHITE
        opts.scrubHeight ?= (opts.height / 6 ) / 4
        opts.scrubRadius ?= 25
        opts.scrubBackgroundColor ?= GREY

        #options for control bar
        opts.controlBarFactor ?= 6

        # add opts to parent
        super opts

        # import dependency
        @FontAwesome = require 'FontAwesome'

        #internal variables
        that = @

        #structure
        mControllerBar = new Layer
            name: "mControllerBar"
            width: @.width
            height: @.height / opts.controlBarFactor
            backgroundColor:'rgba(0,0,0,0.5)'
            clip: false
            parent: @
            y: Align.bottom

        mControllerPlayPause = new Layer
            name: "mControllerPlayPause"
            parent: mControllerBar
            width: mControllerBar.height
            height: mControllerBar.height
            backgroundColor: INVISIBLE

        mControllerRestart = new Layer
            name: "mControllerRestart"
            parent: mControllerBar
            width:  mControllerBar.height
            height:  mControllerBar.height
            x: mControllerBar.maxX - mControllerBar.height
            backgroundColor: INVISIBLE

        mControllerPauseIcon = new @FontAwesome
            name: "mControllerPauseIcon"
            parent: mControllerPlayPause
            icon: "pause"
            color: opts.controlColor
            fontSize: opts.fontMultiplier * BASEFONT
            x: Align.center
            y: Align.center
            visible: false

        mControllerPlayIcon = new @FontAwesome
            name: "mControllerPlayIcon"
            parent: mControllerPlayPause
            icon: "play"
            color: opts.controlColor
            fontSize: opts.fontMultiplier * BASEFONT
            x: Align.center
            y: Align.center

        mControllerRestartIcon = new @FontAwesome
            name: "mControllerRestartIcon"
            parent: mControllerRestart
            icon: "repeat"
            color: opts.controlColor
            fontSize: opts.fontMultiplier * BASEFONT
            x: Align.center
            y: Align.center

        mControllerScrubber = new Layer
            name: "mControllerScrubber"
            parent: mControllerBar
            width: mControllerBar.width - ( mControllerBar.height * 3 )
            height: opts.scrubHeight
            backgroundColor: opts.scrubBackgroundColor
            borderRadius: opts.scrubRadius
            x: Align.center
            y: Align.center

        mControllerScrubberFill = new Layer
            name: "mControllerScrubberFill"
            parent: mControllerScrubber
            width: 0
            height: mControllerScrubber.height
            backgroundColor: opts.controlColor
            borderRadius: opts.scrubRadius

        mControllerScrubberKnob = new Layer
            name: "mControllerScrubberKnob"
            parent: mControllerScrubber
            width: opts.knobSize
            height: opts.knobSize
            backgroundColor: opts.knobColor
            style:
                "border-radius": opts.knobRadius
            x: 0
            y: Align.center
        #update x pos after creation
        mControllerScrubberKnob.x = 0 - ( mControllerScrubberKnob.width / 2 )

        # set up draggable options for the player knob controlling where it can go.
        mControllerScrubberKnob.draggable.enabled = true
        mControllerScrubberKnob.draggable.vertical = false
        mControllerScrubberKnob.draggable.horizontal = true
        mControllerScrubberKnob.draggable.constraints =
            x: ( 0 - mControllerScrubberKnob.width / 2 )
            y: mControllerScrubber.midY
            width: 0
            width: mControllerScrubber.width + ( mControllerScrubberKnob.width / 2 )
        mControllerScrubberKnob.draggable.momentum = false
        mControllerScrubberKnob.draggable.overdragScale = 0
        mControllerScrubberKnob.draggable.overdrag = false
        mControllerScrubberKnob.draggable.bounce = false
        mControllerScrubberKnob.draggable.momentumOptions =
            friction: 100
            tolerance: 0

        mcMediaSource = new VideoLayer
            name: "mcMediaSource"
            backgroundColor: ""
            parent: @
            width: opts.width
            height: opts.height
            style:
                "z-index":"-1"

        # now set up behaviours and register event listeners
        # constantly update the scrubber when the player is playing
        mcMediaSource.player.addEventListener "timeupdate", ->
            mControllerScrubberFill.width = Utils.modulate(mcMediaSource.player.currentTime,[0,mcMediaSource.player.duration],[0,mControllerScrubber.width])
            mControllerScrubberKnob.x = mControllerScrubberFill.width - (mControllerScrubberKnob.width / 2)

        # update the time of video and scrubber fill when the knob is dragged
        mControllerScrubberKnob.on Events.Move, (e) ->
            mcMediaSource.player.pause()
            mControllerScrubberFill.width = Utils.modulate(mControllerScrubberKnob.midX,[0,mControllerScrubber.width],[0,mControllerScrubber.width])
            mcMediaSource.player.currentTime = Utils.modulate(mControllerScrubberKnob.midX,[0,mControllerScrubber.width],[0,mcMediaSource.player.duration])

        # reset the video when it  ends
        mcMediaSource.player.addEventListener "ended", ->
            mControllerScrubberKnob.x = 0 - ( mControllerScrubberKnob.width / 2 )
            mControllerScrubberFill.width = 0
            mControllerPlayIcon.visible = true
            mControllerPauseIcon.visible = false
            mControllerPlayIcon.scale = 1
            mControllerPauseIcon.scaele = 1
            mcMediaSource.player.currentTime = 0
            that.onEnded()

        # show or hide the approprite icon with an animation depending if the video is playing or paused when it's tapped
        mControllerPlayPause.on Events.Tap, ->
            if mcMediaSource.player.paused
                mcMediaSource.player.play()
                mControllerPlayIcon.animate
                    time: .3
                    curve: "spring(300, 0, 0)"
                    properties:
                        scale: .8
                mControllerPlayIcon.visible = false
                mControllerPlayIcon.scale = .1
                mControllerPauseIcon.scale = 1.2
                mControllerPauseIcon.visible = true
                mControllerPauseIcon.animate
                    time: .3
                    curve: "spring(300, 0, 0)"
                    properties:
                        scale: 1
                that.onPlaying()
            else if not mcMediaSource.player.paused
                mcMediaSource.player.pause()
                mControllerPauseIcon.animate
                    time: .3
                    curve: "spring(300, 0, 0)"
                    properties:
                        scale: .8
                mControllerPauseIcon.visible = false
                mControllerPauseIcon.scale = 1
                mControllerPlayIcon.scale = 1.2
                mControllerPlayIcon.visible = true
                mControllerPlayIcon.animate
                    time: .3
                    curve: "spring(300, 0, 0)"
                    properties:
                        scale: 1
                that.onPaused()

        # reset UI and the make video start again on reset button tap
        mControllerRestart.on Events.Tap, ->
            mcMediaSource.player.pause()
            mControllerRestartIcon.scale = 1.2
            mControllerRestartIcon.animate
                time: .3
                curve: "spring(300, 0, 0)"
                properties:
                    scale: 1
            mcMediaSource.player.currentTime = 0
            mControllerScrubberKnob.x = 0 - ( mControllerScrubberKnob.width / 2 )
            mControllerScrubberFill.width = 0
            mControllerPlayIcon.visible = false
            mControllerPlayIcon.scale = 1
            mControllerPauseIcon.visible = true
            mControllerPauseIcon.scaele = 1
            mcMediaSource.player.play()

    setVideoSrc: (src) ->
        mcMediaSource = (@childrenWithName("mcMediaSource"))[0]
        mcMediaSource.video = src

    playVideo: () ->
        mcMediaSource = (@childrenWithName("mcMediaSource"))[0]
        mcMediaSource.player.play()
        @setPlaying()

    getPlayIcon: () ->
        return (@childrenWithName("mControllerBar"))[0].childrenWithName("mControllerPlayPause")[0].childrenWithName("mControllerPlayIcon")[0]
    getPauseIcon: () ->
        return (@childrenWithName("mControllerBar"))[0].childrenWithName("mControllerPlayPause")[0].childrenWithName("mControllerPauseIcon")[0]
    setPlaying: () ->
        (@getPauseIcon()).visible = true
        (@getPlayIcon()).visible = false
    setPaused: () ->
        (@getPauseIcon()).visible = false
        (@getPlayIcon()).visible = true

    pauseVideo: () ->
        mcMediaSource = (@childrenWithName("mcMediaSource"))[0]
        @setPaused()
        mcMediaSource.player.pause()

    onEnded: () ->
        return
    onPlaying: () ->
        return
    onPaused: () ->
        return
    setEndedCallBack: (callback) ->
        @onEnded = callback
    setPlayCallBack: (callback) ->
        @onPlaying = callback
    setPauseCallBack: (callback) ->
        @onPaused = callback
