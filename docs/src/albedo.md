# Albedo

The surface albedo is the fraction of incoming shortwave radiation (sunlight) that is reflected
at the surface, so a number between 0 (black, everything absorbed) and 1 (white, everything reflected).
Typical values are about 0.06 for open ocean, 0.1-0.2 for forests, 0.3-0.4 for deserts,
0.5-0.7 for sea ice and up to 0.9 for fresh snow.

## Your albedo function

In Chiaroscuro you define albedo as a Julia function `albedo(inputs)` that takes in a
[`NamedTuple`](https://docs.julialang.org/en/v1/manual/functions/#Named-Tuples) of scalar
`inputs` and returns a single scalar, the albedo, for example

```julia
function albedo(inputs)
    (; sea_surface_temperature, sea_ice_concentration) = inputs

    # brighter where there's sea ice
    a = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration
    return clamp(a, 0, 1)
end
```

The syntax `(; a, b) = inputs` unpacks the fields `a` and `b` from `inputs`, use only
those you need. This function is called on every grid point and every time step of the simulation,
meaning that albedo can change in space and time, following the state of the simulation.

Your function has to

- return a floating-point number between 0 and 1 inclusive, e.g. use `clamp(a, 0, 1)`
- only use scalar arithmetic, i.e.
    - `+`, `-`, `/`, `*`, `^`, `sqrt`, `cbrt`, ...
    - trigonometric and other functions like `sin`, `cos`, `exp`, `log`, `tanh`, ...
    - `abs`, `mod`, `max`, `min`, `clamp`, ... including `if`
    - random numbers `rand`, `randn`, ...

Arrays, global variables that change during the simulation or reading in data are not allowed.

## Inputs

The following inputs are currently available in `inputs` at every grid point

| Name | Description | Unit |
| :--- | :---------- | :--- |
| `sea_surface_temperature` | Sea surface temperature | K |
| `sea_ice_concentration` | Fraction of the grid cell covered by sea ice | [0, 1] |

More inputs from the atmosphere and land (e.g. land fraction, snow depth, soil moisture,
vegetation) are to follow.

## ChiaroscuroAlbedo

To use your function in a SpeedyWeather simulation wrap it into a `ChiaroscuroAlbedo`
and pass it on to the model constructor as `albedo`

```julia
using SpeedyWeather, Chiaroscuro

spectral_grid = SpectralGrid(truncation=32, nlayers=8)
my_albedo = ChiaroscuroAlbedo(albedo)
model = PrimitiveWetModel(spectral_grid; albedo=my_albedo)
simulation = initialize!(model)
run!(simulation, period=Day(30))
```

## Visualising albedo

After the simulation ran, you can visualise the albedo on the last time step with

```julia
using CairoMakie
heatmap(my_albedo, simulation)
```

which creates a map of your albedo (left) and its difference to SpeedyWeather's
default albedo (right), both evaluated on the last time step of the simulation.
The default albedo blends open ocean (0.06) and sea ice (0.6) by sea ice concentration,
and over land bare soil, vegetation and snow cover.
The same plot is also shown for every submission in the [List of submissions](@ref).
