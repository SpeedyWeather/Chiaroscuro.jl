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
| `time_of_day` | h | Time of day (UTC), 0 to 24 |
| `day_of_year` | 1 | Day of the year, 1 to 366 |
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
