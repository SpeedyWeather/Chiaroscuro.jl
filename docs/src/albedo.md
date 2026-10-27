# Albedo

TODO: Explain `ChiaroscuroAlbedo` and how a function `f(x, y, z)` of Cartesian coordinates
on the unit sphere defines the surface albedo of a SpeedyWeather simulation.

```julia
using Chiaroscuro
f(x, y, z) = 0.3
albedo = ChiaroscuroAlbedo(f)
```

## Coordinates

TODO: Convention of `x, y, z`, e.g. `z = sin(latitude)`, `x = cos(latitude)cos(longitude)`,
`y = cos(latitude)sin(longitude)`, and the valid range of albedo values.

## Visualising albedo

TODO
