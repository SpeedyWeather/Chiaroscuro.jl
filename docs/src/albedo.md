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

The following inputs are available in `inputs` at every grid point. Atmospheric variables
are taken from the lowermost model layer and all are evaluated on the current time step,
after the surface fluxes, condensation and convection have been computed,
just before radiation.

### Position and time

| Name | Unit | Description |
| :--- | :--- | :---------- |
| `latd` | ˚N | Latitude, -90˚N (South Pole) to 90˚N (North Pole) |
| `lond` | ˚E | Longitude, 0˚E to 360˚E |
| `day_angle` | rad | Time of day as angle, 0 at midnight UTC, π at noon UTC, to 2π. Use e.g. `cos(day_angle)` for a smooth daily cycle |
| `year_angle` | rad | Time of year as angle, 0 at 1 January 00UTC to 2π at the end of the year. Use e.g. `cos(year_angle)` for a smooth seasonal cycle |
| `cos_zenith` | 1 | Cosine of the solar zenith angle, 0 at night, 1 for the sun directly overhead |

### Surface boundary conditions

| Name | Unit | Description |
| :--- | :--- | :---------- |
| `orography` | m | Surface height above sea level |
| `land_fraction` | 1 | Fraction of the grid cell covered by land, 0 (ocean) to 1 (land) |
| `surface_roughness` | m | Momentum roughness length of the surface |

### Atmosphere

| Name | Unit | Description |
| :--- | :--- | :---------- |
| `surface_air_temperature` | K | Air temperature at the surface |
| `surface_pressure` | Pa | Surface pressure |
| `surface_air_density` | kg/m³ | Air density at the surface |
| `surface_humidity` | kg/kg | Specific humidity in the lowermost layer |
| `surface_wind_speed` | m/s | Wind speed at the surface |
| `surface_vorticity` | 1/s | Relative vorticity in the lowermost layer |
| `surface_divergence` | 1/s | Divergence in the lowermost layer |
| `rain_rate` | m/s | Rain rate, large-scale and convective |
| `snow_rate` | m/s | Snow fall rate, large-scale and convective |

### Ocean and sea ice

| Name | Unit | Description |
| :--- | :--- | :---------- |
| `sea_surface_temperature` | K | Sea surface temperature |
| `sea_ice_concentration` | 1 | Fraction of the ocean covered by sea ice, 0 to 1 |

### Land

| Name | Unit | Description |
| :--- | :--- | :---------- |
| `soil_temperature_1` | K | Temperature of the upper soil layer |
| `soil_temperature_2` | K | Temperature of the lower soil layer |
| `soil_moisture_1` | 1 | Soil moisture of the upper soil layer, fraction of capacity |
| `soil_moisture_2` | 1 | Soil moisture of the lower soil layer, fraction of capacity |
| `snow_depth` | m | Snow depth in liquid water equivalent |
| `snow_cover` | 1 | Fraction of the land covered by snow, 0 to 1, computed from `snow_depth` as `snow_depth / (snow_depth + 0.05m)` as in SpeedyWeather's default albedo |
| `high_vegetation_cover` | 1 | Fraction of the grid cell covered by high vegetation (e.g. forest), 0 to 1 |
| `low_vegetation_cover` | 1 | Fraction of the grid cell covered by low vegetation (e.g. grass), 0 to 1 |
| `high_vegetation_leaf_area` | m²/m² | Leaf area index of high vegetation |
| `low_vegetation_leaf_area` | m²/m² | Leaf area index of low vegetation |

Land variables are also defined over the ocean but are only meaningful where `land_fraction > 0`,
likewise ocean variables are only meaningful where `land_fraction < 1`.

## Examples

The following examples illustrate how to use the [Inputs](@ref). They are
not meant to be good (see the [Chiaroscuro leaderboard](@ref) for that) but to give some ideas.
All of them are also in the
[`/submissions` folder](https://github.com/SpeedyWeather/Chiaroscuro.jl/tree/main/submissions).

### Land, ocean and snow

Every grid cell is a mix of land and ocean, so a good start is to define an albedo
for each and weight them by `land_fraction`

```julia
function albedo(inputs)
    (; land_fraction, sea_ice_concentration, snow_cover) = inputs

    # ocean: blend open ocean and sea ice
    ocean = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration

    # land: blend bare land and snow
    land = 0.3 * (1 - snow_cover) + 0.8 * snow_cover

    # weight by the fraction of land in the grid cell
    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
```

### Vegetation and snow depth

Over land, forests are darker than grass and bare soil. You can also compute your own
snow cover from `snow_depth`, and let dense forests (high leaf area) hide the snow on the ground

```julia
function albedo(inputs)
    (; land_fraction, sea_ice_concentration, snow_depth) = inputs
    (; high_vegetation_cover, low_vegetation_cover, high_vegetation_leaf_area) = inputs

    ocean = 0.06 + 0.54 * sea_ice_concentration

    # bare soil is bright, forests are dark, grass is in between
    bare_soil = max(1 - high_vegetation_cover - low_vegetation_cover, 0)
    land = 0.35 * bare_soil + 0.2 * low_vegetation_cover + 0.13 * high_vegetation_cover

    # snow is brighter the deeper it is, but dense forests (high leaf area) hide it
    snow_cover = snow_depth / (snow_depth + 0.02)
    visible = exp(-0.5 * high_vegetation_leaf_area * high_vegetation_cover)
    land += 0.5 * snow_cover * visible

    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
```

### Sun angle, wind and melting ice

Albedo also changes with the weather: water reflects more of a low sun, strong winds create
bright whitecaps, and melt ponds on sea ice close to freezing are darker than dry ice.
Use `if` or the ternary operator `condition ? a : b` for such switches

```julia
function albedo(inputs)
    (; land_fraction, sea_ice_concentration, snow_cover) = inputs
    (; cos_zenith, surface_wind_speed, sea_surface_temperature) = inputs

    # water reflects more when the sun is low (small cos_zenith), like a sunset over the sea
    water = 0.05 + 0.15 * (1 - cos_zenith)^5

    # whitecaps from breaking waves cover more of the ocean the stronger the wind
    whitecaps = clamp(3.8e-6 * surface_wind_speed^3.4, 0, 1)
    water = (1 - whitecaps) * water + whitecaps * 0.5

    # melting sea ice (close to freezing) is darker because of melt ponds
    ice = sea_surface_temperature > 272 ? 0.45 : 0.65
    ocean = (1 - sea_ice_concentration) * water + sea_ice_concentration * ice

    land = 0.3 + 0.5 * snow_cover

    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
```

### Seasons and position

`year_angle` and `day_angle` go from 0 to 2π so that `sin` and `cos` of them are smooth
cycles without a jump at the end of the year or day. Combined with latitude `latd` you could,
for example, make the high latitudes of the winter hemisphere brighter

```julia
function albedo(inputs)
    (; latd, year_angle) = inputs

    # cos(year_angle) is 1 in January (northern winter) and -1 in July (southern winter)
    winter = clamp(sign(latd) * cos(year_angle), 0, 1)

    # brighter towards the poles, more so in winter
    a = 0.1 + 0.3 * (abs(latd) / 90)^2 * (1 + winter)
    return clamp(a, 0, 1)
end
```

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

which creates a map of your albedo (top left) and its difference to SpeedyWeather's
default albedo (top right), and below the surface air temperature (bottom left) and its
difference to the reference surface temperature (bottom right) which is what your albedo
is scored on, see [Evaluation](@ref). All on the last time step of the simulation.
The default albedo blends open ocean (0.06) and sea ice (0.6) by sea ice concentration,
and over land bare soil, vegetation and snow cover.
The same plot is also shown for every submission in the [List of submissions](@ref).
