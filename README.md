# flux.lua
A lightweight tweening library for lua.

## Installation
The [flux.lua](flux.lua?raw=1) file should be dropped into an existing
project and required by it.
```lua
flux = require "flux"
``` 
The `flux.update()` function should be called at the start of each frame. As
its only argument It should be given the time in seconds that has passed since
the last call.
```lua
flux.update(deltatime)
```

## Usage
Any number of numerical values in a table can be tweened simultaneously. Tweens
are started by using the `flux.to()` function. This function requires 3
arguments:
* `obj` The object which contains the fields to tween
* `time` The amount of time the tween should take to complete
* `vars` A table where the keys are the keys in `obj` which should be tweened,
  and their values are the destination
```lua
-- Moves the ball object to the position 200, 300 over 4 seconds
flux.to(ball, 4, { x = 200, y = 300 })
```
If you try to tween a variable which is already being tweened, the original
tween stops tweening the variable and the new tween begins from the current
value.

### Additional options
In addition to the 3 required arguments by `flux.to()`, additional options
can be set through the use of chained functions.
```lua
flux.to(t, 4, { x = 10 }):ease("linear"):delay(1)
```

#### :ease(type)
The easing type which should be used by the tween; `type` should be a string
containing the name of the easing to be used. The library provides the
following easing types:

  `linear`     ,
  `quadin`     , `quadout`     , `quadinout`     ,
  `quartin`    , `quartout`    , `quartinout`    ,
  `quintin`    , `quintout`    , `quintinout`    , 
  `expoin`     , `expoout`     , `expoinout`     ,
  `sinein`     , `sineout`     , `sineinout`     ,
  `circin`     , `circout`     , `circinout`     ,
  `backin`     , `backout`     , `backinout`     ,
  `elasticin`  , `elasticout`  , `elasticinout`  .

The default easing type is `quadout`.


#### :delay(time)
The amount of time which should be waited until the tween starts; `time` should
be a number of seconds. The default delay is `0`.

#### :onbegin(fn)
Sets the function `fn` to be called when the tween begins (once the delay has
finished). `:onbegin()` can be called multiple times to add more than one
function.

#### :onupdate(fn)
Sets the function `fn` to be called each frame the tween updates a value.
`onupdate()` can be called multiple times to add more than one function.

#### :oncomplete(fn)
Sets the function `fn` to be called once the tween has finished and reached its
destination values. `oncomplete()` can be called multiple times to add more
than one function.

#### :after(obj, time, vars)
Creates a new tween and chains it to the end of the existing tween; the chained
tween will be called after the original one has finished. Any additional
chained function used after `:after()` will effect the chained tween.
```lua
-- Tweens t.x to 10 over 2 seconds, then to 20 over 1 second
flux.to(t, 2, { x = 10 }):after(t, 1, { x = 20 })
```

### Groups
flux.lua provides the ability to create tween groups; these are objects
which can have tweens added to them, and who are in charge of updating and
handling their contained tweens. A group is created using the `flux.group()`
function.
```lua
group = flux.group()
```
Once a group is created it acts independently of the `flux` object, and must
be updated each frame using its own update method.
```lua
group:update(deltatime)
```
To add a tween to a group, the group's `to()` method should be used.
```lua
group:to(t, 3, { x = 10, y = 20 })
```
A good example of where groups are useful is for games where you may have a set
of tweens which effect objects in the game world and which you want to pause
when the game is paused.  A group's tweens can be paused by simply neglecting
to call its `update()` method; when a group is destroyed its tweens are also
destroyed.


## License
This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

