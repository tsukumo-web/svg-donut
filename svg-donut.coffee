
Snap = require "Snap.svg"

class SVG
    constructor: ( ) ->
        @dom = document.createElementNS "http://www.w3.org/2000/svg", "svg"
        @s = Snap @dom
    viewbox: ( box, aspect ) ->
        @s.attr
            preserveAspectRatio: aspect or "none"
            viewBox: box

module.exports = class Donut extends SVG
    d = 100
    r = d/2
    cx = r
    cy = r

    _calc_path: ( start, end, part ) ->
        large = if (end - start) > 180 then 1 else 0

        start = (start % 360) * Math.PI / 180
        end = (end % 360) * Math.PI / 180
        tr = if part.offset then r - part.offset else r
        cr = tr - (part.thickness or @settings.thickness)

        "M#{cx + tr * Math.cos start},#{cy + tr * Math.sin start}
         A#{tr},#{tr},0,#{large},1,#{cx + tr * Math.cos end},#{cy + tr * Math.sin end}
         L#{cx + cr * Math.cos end},#{cy + cr * Math.sin end}
         A#{cr},#{cr},0,#{large},0,#{cx + cr * Math.cos start},#{cy + cr * Math.sin start}
         Z"

    _anim_part: ( part, duration, callback ) ->
        diff = part.amount * 3.6

        if @settings.progressive
            orig_diff = part.origin - @settings.origin
            diff += orig_diff
            anim = ( t ) => part.path.attr
                d: @_calc_path @settings.origin + orig_diff * t, @settings.origin + diff * t, part
        else
            anim = ( t ) => part.path.attr
                d: @_calc_path part.origin, part.origin + diff * t, part

        Snap.animate 0, 1, anim, duration, @settings.easing, callback

    animate: ( i = 0 ) ->
        if @settings.parallel
            for part in @settings.data
                @_anim_part part, if part.static then 0 else @settings.duration
        else
            duration = if @settings.data[i].static then 0 else @settings.duration * @settings.data[i].amount / 100
            @_anim_part @settings.data[i], duration, ( ) =>
                if i < @settings.data.length - 1
                    @animate i + 1

    # data: {amount, color, thickness, offset, origin, static }
    constructor: ( options ) ->
        super
        @viewbox "0 0 100 100", "xMidYMid"

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

        @settings.thickness = @settings.thickness / 2

        path = @s.group()

        origin = @settings.origin
        for part in @settings.data
            part.thickness = part.thickness / 2
            part.offset = part.offset / 2
            part.amount = Math.min part.amount, 99.99
            if not part.origin?
                part.origin = origin 
                origin += part.amount * 3.6
            part.path = @s.path().attr
                fill: part.color
            path.add part.path

        if @settings.auto
            @animate()

