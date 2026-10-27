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

## Example

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

