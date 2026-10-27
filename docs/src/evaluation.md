# Evaluation

To evaluate how good your albedo is, after the simulation ran do

```julia
evaluate(my_albedo, simulation)
```

This compares the simulated surface temperature to a reference surface temperature
and returns several scores, all a root mean square error (RMSE) in Kelvin. Lower is better!

## Score

The total `score` is the RMSE of the surface temperature ``T`` against the
reference ``T_{ref}`` over all ``N`` grid points ``i``

```math
\text{RMSE} = \sqrt{\frac{1}{N} \sum_i \left(T_i - T_{ref,i}\right)^2}
```

The reference surface temperature is not yet provided.

## Regional scores

To make things more interesting, the same RMSE is also computed only over
certain regions of the globe

| Score | Region |
| :---- | :----- |
| `score` | Global, used to rank submissions on the [Chiaroscuro leaderboard](@ref) |
| `land_score` | Land grid points only |
| `ocean_score` | Ocean grid points only |
| `tropical_score` | Tropics, between 30˚S and 30˚N |
| `polar_score` | Polar regions, poleward of 60˚N and 60˚S |

An albedo that works well over the ocean may not over land, and the tropics are quite different
from the poles. All scores are shown on the [Chiaroscuro leaderboard](@ref),
so you can also try to win in a given category.
