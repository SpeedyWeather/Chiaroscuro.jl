# Evaluation

To evaluate how good your albedo is, after the simulation ran do

```julia
evaluate(my_albedo, simulation)
```

This compares the simulated surface temperature to a reference surface temperature
and returns several scores, all a root mean square error (RMSE) in Kelvin. Lower is better!

## Score

The total `score` is the area-weighted RMSE of the surface air temperature ``T``
on the last time step against the reference ``T_{ref}`` over all grid points ``i``

```math
\text{RMSE} = \sqrt{\frac{\sum_i w_i \left(T_i - T_{ref,i}\right)^2}{\sum_i w_i}}
```

with weights ``w_i`` the area of each grid cell, so that the many small grid cells near
the poles don't count more than the large ones near the equator.
The reference surface temperature is read from `data/reference_surface_temperature.nc`
in the repository, an `OctahedralGaussianGrid` with `nlat_half = 24`, the default grid for
`SpectralGrid(truncation = 32)` used for all submissions. If you run your simulation on a
different grid, the reference is interpolated onto it. You can also pass your own
`reference` field to `evaluate(my_albedo, simulation; reference)`.
The reference is the time-mean surface air temperature of a SpeedyWeather simulation
from 15 January to 15 February 2000, run at higher resolution on a `FullGaussianGrid`
with `nlat_half = 96` and interpolated down, see `data/create_reference.jl`.

```@example evaluation
using Chiaroscuro, CairoMakie
reference = Chiaroscuro.reference_surface_temperature()
heatmap(reference, title = "Reference surface air temperature [K]", colormap = :thermal)
```

## Regional scores

To make things more interesting, the same RMSE is also computed only over
certain regions of the globe

| Score | Region |
| :---- | :----- |
| `score` | Global, used to rank submissions on the [Chiaroscuro leaderboard](@ref) |
| `land_score` | Land, every grid cell additionally weighted by its land fraction |
| `ocean_score` | Ocean, every grid cell additionally weighted by its ocean fraction (1 - land fraction) |
| `tropical_score` | Tropics, between 30˚S and 30˚N |
| `polar_score` | Polar regions, poleward of 60˚N and 60˚S |

An albedo that works well over the ocean may not over land, and the tropics are quite different
from the poles. All scores are shown on the [Chiaroscuro leaderboard](@ref),
so you can also try to win in a given category.
