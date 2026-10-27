# Chiaroscuro.jl
[![Build Status](https://github.com/SpeedyWeather/Chiaroscuro.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/SpeedyWeather/Chiaroscuro.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![docs](https://img.shields.io/badge/documentation-latest_release-blue.svg)](https://speedyweather.github.io/Chiaroscuro.jl/stable/)
[![docs](https://img.shields.io/badge/documentation-main-blue.svg)](https://speedyweather.github.io/Chiaroscuro.jl/dev/)

_Always look on the bright side of light!_ A repository on the [art of light and darkness](https://en.wikipedia.org/wiki/Chiaroscuro) of planet Earth.

> 'Some say snow, and some say cloud,  
> Some say 'paint the deserts proud!',  
> A wise old sage said 'point three... or so, you see?  
> There's the forest, dark and deep,  
> And the ice, so bright and cheap,  
> And the sneaky little whitecaps on the sea!'
>
> Chorus  
> (whistle) Always look on the bright side of light...  
> (whistle) Always look on the white side of light...  

Monty Python

## The Albedo Problem

[Albedo](https://en.wikipedia.org/wiki/Albedo) determines how much sunshine is reflected by the Earth's surface.
You may think of it as a time-constant boundary condition to a simple climate model but in fact, it's not.

Albedo depends on many things: The ocean is pretty dark if you look from above, but it nicely reflects a sunset.
A stormy ocean is full of white sea spray and the Arctic ocean has floating sea ice, preventing snow from melting in the ocean below.
Snow is much brighter than a dark forest it covers, deforestation often leaves behind a more reflective bare soil.
And wet and dry seasons widely change the presence of vegetation.

At the same time, albedo directly scales the amount of energy the Earth's surface receives from the sun.
A small difference in albedo makes a big difference in the Earth's energy budget.
Can you learn what albedo should be to better predict surface temperatures?

<img width="1347" height="1343" alt="octant_shortwave_1793124601 Background Removed" src="https://github.com/user-attachments/assets/89872a92-6b00-45d5-9cde-7514f30e6dd9" />

Shortwave albedo over land as measured by the [MODIS](https://en.wikipedia.org/wiki/Moderate_Resolution_Imaging_Spectroradiometer) satellite sensors.

## The Chiaroscuro Albedo Challenge

N different variables from the ERA5 reanalysis are available at X.
These serve as N scalar predictors for albedo (1 scalar predictand) which is also provided.
Formulate these as a function `albedo(inputs)` using only scalar arithmetic, i.e.

- `+`, `-`, `/`, `*`, `sqrt`, `cbrt` ...
- trigonometric functions like `sin`, `cos`, `exp`, `log`, ...
- `abs`, `mod`, `max`, `min`, ... including `if`
- random numbers `rand`, `randn` ...

And return albedo as a floating-point number between 0 and 1 inclusive.

## Example

Write up your function in Julia, using any of the predictors as listed here,
wrap it into a `ChiaroscuroAlbedo` type as shown below, setup and run a
SpeedyWeather simulation. You can then `evaluate` and visualise your results!

```julia
using SpeedyWeather, Chiaroscuro

# define your albedo function
function albedo(inputs)
  (; land_fraction, snow_depth) = inputs
  a = land_fraction*0.4 + (1 - land_fraction)*0.1 + 0.9*5*min(snow_depth, 0.2)
  return clamp(a, 0, 1)
end

# create a simulation 
spectral_grid = SpectralGrid(truncation=32, nlayers=8)
my_albedo = ChiaroscuroAlbedo(albedo)
model = PrimitiveWetModel(spectral_grid; albedo=my_albedo)
simulation = initialize!(model)

# then run! simulation for 30 days
run!(simulation, period=Day(30))

# evaluate 
evaluate(my_albedo, simulation)

# and visualise
using GLMakie
globe(my_albedo, simulation)
```

## Installation

Not a registered package so do

```julia
julia> ] add https://github.com/SpeedyWeather/Chiaroscuro.jl
```

where `]` opens Julia's package manager Pkg.jl.

