
svg-donut
===

> A robust svg donut implementation

API
---

```
donut = new Donut
    data: [                             # data to display, portions of the donut
        {
            amount      : 0             # percent of circle filled
            color       : ‘black’       # fill color
            thickness   : parent        # percent of space consumed
            offset      : 0             # shift in by this percent
            origin      : -90           # start from a different origin
            static      : false         # do not animate
            reset       : false         # resets origin for stacks
        }, { ... }
    ],
    thickness           : 10            # percent of space consumed
    origin              : prev + curr   # starting location
    duration            : 1000          # animation speed
    easing              : linear        # animation easing
    parallel            : false         # animate parts simultaneous
    progressive         : false         # animate from origin
    auto                : false         # auto start animation

document.body.appendChild donut.dom
```

Version 2
---

- Reformatted code to use more robust svg engine
- Supported resetting origin for easier stacks

Version 3 (coming soon)
---

- updatability of data
- interactivity

