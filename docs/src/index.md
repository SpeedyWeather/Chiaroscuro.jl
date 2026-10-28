```@meta
CurrentModule = Chiaroscuro
```

# Chiaroscuro

_Always look on the bright side of light!_

Documentation for [Chiaroscuro](https://github.com/SpeedyWeather/Chiaroscuro.jl),
a repository on the [art of light and darkness](https://en.wikipedia.org/wiki/Chiaroscuro)
of planet Earth: Design the surface albedo of a
[SpeedyWeather.jl](https://github.com/SpeedyWeather/SpeedyWeather.jl) planet.

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

## The Chiaroscuro albedo challenge

The actual problem is:

> Write a function `albedo(inputs)` that computes the surface albedo from the local state of
> the atmosphere, ocean and land, such that a SpeedyWeather simulation predicts
> surface temperatures as close as possible to a reference.

The [Albedo](@ref) page explains which inputs are available and which operations you can use,
the [Evaluation](@ref) explains how your albedo is scored. Lower scores are better!

Contents

- [Installation](@ref)
- [New to Julia?](@ref)
- [Albedo](@ref)
- [Evaluation](@ref)

And specifically for submitting to Chiaroscuro:

- [Chiaroscuro instructions](@ref)
- [Submit to Chiaroscuro](@ref)
- [Chiaroscuro leaderboard](@ref)
- [List of submissions](@ref)

## Quick start

After the [Installation](@ref) copy and paste this into your Julia REPL, notebook etc

```julia
using SpeedyWeather, Chiaroscuro

# define your albedo function
function albedo(inputs)
    (; sea_ice_concentration) = inputs
    a = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration
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
using CairoMakie
heatmap(my_albedo, simulation)
```

And you have the basic setup to define an albedo, run a simulation with it, evaluate and visualise.
Change the albedo function to score lower, see more information in the
[Chiaroscuro instructions](@ref).

## Installation

First [install Julia](https://julialang.org/install/) via `juliaup` (the recommended default way).
Chiaroscuro.jl is a Julia package so from the Julia REPL you can then do

```julia
julia> ] add https://github.com/SpeedyWeather/Chiaroscuro.jl, SpeedyWeather, CairoMakie
```

where `]` opens Julia's package manager interactively.
[SpeedyWeather](https://speedyweather.github.io/SpeedyWeatherDocumentation/dev/)
is a dependency anyway and you will need its exported function and types to run a simulation.
[CairoMakie](https://docs.makie.org/stable/explanations/backends/backends) is a [Makie](https://docs.makie.org/stable/)
backend we use for visualisation, but any other Makie backend (e.g. GLMakie) works too.
Equivalently, you can do

```julia
using Pkg
Pkg.add(url="https://github.com/SpeedyWeather/Chiaroscuro.jl")
Pkg.add(["SpeedyWeather", "CairoMakie"])
```

and after all dependencies are installed with `julia> using Chiaroscuro, SpeedyWeather, CairoMakie` you load the packages,
ready to look on the bright side of light!

You can use this software in different ways,

- in [VS Code](https://code.visualstudio.com/docs/languages/julia)
- via [IJulia](https://github.com/JuliaLang/IJulia.jl) in [Jupyter notebooks](https://jupyter.org/)
- in [Pluto notebooks](https://github.com/fonsp/Pluto.jl)
- in the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) (the standard terminal)
- or [oldschool](https://docs.julialang.org/en/v1/manual/command-line-interface/) via `julia my_script.jl`

Coming from Python? Have a look at a concise list of
[noteworthy differences](https://docs.julialang.org/en/v1/manual/noteworthy-differences/#Noteworthy-differences-from-Python).

## Julia Jupyter kernel

To install a Julia kernel for Jupyter notebooks (assuming you already have jupyter notebooks installed) you need
a package called [IJulia](https://github.com/JuliaLang/IJulia.jl)

```julia
julia> ] add IJulia
```

After IJulia is installed do once

```julia
using IJulia
installkernel("Julia")
```

this will add a Julia kernel you can choose among other Python kernels in jupyter lab or jupyter notebooks.
