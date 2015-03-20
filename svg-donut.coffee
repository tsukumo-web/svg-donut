
require "raphael"
_ = require "underscore"

setAnimation = ( step, dur, done ) ->
    t = 0
    v = setInterval ->
        p = (t += 16) / dur
        if p >= 1
            step 1, dur
            clearInterval v
            done?()
        else
            step p, t
    , 16

clearAnimation = clearInterval

Graphic = window.Raphael.ninja()

Graphic.paths =
    arc: ( cx, cy, r, start = 0, end = 360, thickness = r / 4 ) ->
        if start is end
            start = 0
            end = 360
        if end is 360
            end = 359.99

        large = if ((end - start) % 360) > 180 then 1 else 0

        start = Graphic.rad start
        end = Graphic.rad end

        cr = r - thickness

        "M#{cx + r * Math.cos start},#{cy + r * Math.sin start}
         A#{r},#{r},0,#{large},1,#{cx + r * Math.cos end},#{cy + r * Math.sin end}
         L#{cx + cr * Math.cos end},#{cy + cr * Math.sin end}
         A#{cr},#{cr},0,#{large},0,#{cx + cr * Math.cos start},#{cy + cr * Math.sin start}
         Z"

module.exports = class Donut
    d = 200
    r = d / 2
    cx = r
    cy = r

    # data: { amount, color, thickness, offset, origin, static, reset }
    constructor: ( options ) ->
        @settings = _.extend {
            thickness: 10
            data: [ ]
            origin: -90
            duration: 1000
            easing: ( t ) -> t
            parallel: false
            progressive: false
            auto: false
        }, options

        @g = new Graphic 0, 0, d, d
        @g.setViewBox 0, 0, d, d

        origin = @settings.origin
        for part in @settings.data
            # part.amount = Math.min part.amount, 99.99
            if part.reset
                origin = @settings.origin
            if not part.origin?
                part.origin = origin
                origin += part.amount
            else
                part.initial = part.origin
            part.path = @g.path().attr
                fill: part.color
                stroke: "none"

        if @settings.auto
            @animate()

    _anim_part: ( part, duration, callback ) ->

        origin = part.initial or @settings.origin
        diff = part.amount

        tr = if part.offset then r - part.offset else r

        if @settings.progressive
            orig_diff = part.origin - origin
            diff += orig_diff
            anim = ( p ) =>
                p = @settings.easing p
                part.path.attr
                    path: Graphic.paths.arc cx, cy, tr,
                        origin + orig_diff * p,
                        origin + diff * p,
                        (part.thickness or @settings.thickness)
        else
            anim = ( p ) =>
                p = @settings.easing p
                part.path.attr
                    path: Graphic.paths.arc cx, cy, tr,
                        part.origin,
                        part.origin + diff * p,
                        (part.thickness or @settings.thickness)

        setAnimation anim, duration, callback

    animate: ( i = 0 ) ->
        if @settings.parallel
            for part in @settings.data
                @_anim_part part, if part.static then 0 else @settings.duration
        else
            duration = if @settings.data[i].static then 0 else @settings.duration * @settings.data[i].amount / 360
            @_anim_part @settings.data[i], duration, ( ) =>
                if i < @settings.data.length - 1
                    @animate i + 1

