class exports.MediaContainer extends Layer
    constructor: (opts={}) ->

        # color constants
        INVISIBLE = "rgba(255, 255, 255, 0)"
        SKYBLUE =  "#46C3D4"
        DEFAULT = "FAFAFA"
        # font constants
        opts.BASEFONT ?= 40

        #options
        opts.name = "MediaContainer"
        opts.width ?= Screen.width
        opts.height ?= Screen.width * 0.5625
        opts.backgroundColor ?= INVISIBLE
        opts.controlColor ?= SKYBLUE

        #slider constants
        opts.KNOBSIZE ?= ( opts.height / 6 ) * .6
        opts.SCRUBHEIGHT ?= (opts.height / 6 ) / 4

        super opts

        #imports
        FontAwesome = require 'FontAwesome'

        #make context available
        that = @

        #structure
        mControllerBar = new Layer
            name: "mControllerBar"
            width: @.width
            height: @.height / 6
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

        mControllerPauseIcon = new FontAwesome
            name: "mControllerPauseIcon"
            icon: "pause"
            parent: mControllerPlayPause
            color: opts.controlColor
            fontSize: opts.BASEFONT
            x: Align.center
            y: Align.center
            visible: false

        mControllerPlayIcon = new FontAwesome
            name: "mControllerPlayIcon"
            icon: "play"
            parent: mControllerPlayPause
            color: opts.controlColor
            fontSize: opts.BASEFONT
            x: Align.center
            y: Align.center

        mControllerRestartIcon = new FontAwesome
            name: "mControllerRestartIcon"
            icon: "repeat"
            parent: mControllerRestart
            color: opts.controlColor
            fontSize: opts.BASEFONT
            x: Align.center
            y: Align.center

        mControllerScrubber = new SliderComponent
            name: "mControllerScrubber"
            parent: mControllerBar
            width: mControllerBar.width - ( mControllerBar.height * 3 )
            height: opts.SCRUBHEIGHT
            min: 0
            max: 1
            value: 0
            x: Align.center
            y: Align.center

        mControllerScrubber.knobSize = opts.KNOBSIZE
        mControllerScrubber.fill.backgroundColor = opts.controlColor
        mControllerScrubber.knob.draggable.momentum = false

        mcMediaSource = new VideoLayer
            name: "mcMediaSource"
            backgroundColor: ""
            parent: @
            width: opts.width
            height: opts.height
            style:
                "z-index":"-1"

        mcMediaSource.player.addEventListener "timeupdate", ->
            mControllerScrubber.value = mcMediaSource.player.currentTime / mcMediaSource.player.duration

        mcMediaSource.player.addEventListener "ended", ->
            mControllerScrubber.value = 0
            mControllerPlayIcon.visible = true
            mControllerPauseIcon.visible = false
            mcMediaSource.currentTime = 0
            that.ended()

        mControllerScrubber.knob.on Events.DragStart, ->
            mcMediaSource.player.pause()
            mControllerPlayIcon.visible = true
            mControllerPauseIcon.visible = false

        mControllerScrubber.knob.on Events.DragEnd, ->
            mcMediaSource.player.currentTime = mcMediaSource.player.duration * mControllerScrubber.value
            mControllerPlayIcon.visible = true
            mControllerPauseIcon.visible = false

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
            else
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

        mControllerRestart.on Events.Tap, ->
            mcMediaSource.player.pause()
            mControllerRestartIcon.scale = 1.2
            mControllerRestartIcon.animate
                time: .3
                curve: "spring(300, 0, 0)"
                properties:
                    scale: 1
            mcMediaSource.player.currentTime = 0
            mControllerScrubber.value = 0
            mControllerPlayIcon.visible = false
            mControllerPauseIcon.visible = true
            mcMediaSource.player.play()

    setVideoSrc: (src) ->
        mcMediaSource = (@childrenWithName("mcMediaSource"))[0]
        mcMediaSource.video = src
    playVideo: () ->
        mcMediaSource = (@childrenWithName("mcMediaSource"))[0]
        @setPlaying()
        mcMediaSource.player.play()
    pauseVideo: () ->
        mcMediaSource = (@childrenWithName("mcMediaSource"))[0]
        @setPaused()
        mcMediaSource.player.pause()
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
    ended: () ->
        return
    setEndedCallBack: (callback) ->
        @ended = callback
