```@meta
CurrentModule = Chiaroscuro
```

# Chiaroscuro

_Always look on the bright side of light!_

Documentation for [Chiaroscuro](https://github.com/SpeedyWeather/Chiaroscuro.jl),
a repository on the [art of light and darkness](https://en.wikipedia.org/wiki/Chiaroscuro)
of planet Earth: Design the surface albedo of a
[SpeedyWeather.jl](https://github.com/SpeedyWeather/SpeedyWeather.jl) planet.

## The Problem

The actual problem is:

> TODO: One or two sentences describing the challenge, i.e. what is optimized
> when choosing the albedo as a function `albedo(x, y, z)` on the sphere.

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

# define albedo as a function of Cartesian coordinates on the unit sphere
f(x, y, z) = 0.1 + 0.6 * abs(z)     # bright poles, dark tropics
albedo = ChiaroscuroAlbedo(f)

# TODO: complete once the interface in src/ is final
evaluate(albedo)
```

## Installation

First [install Julia](https://julialang.org/install/) via `juliaup` (the recommended default way).
Chiaroscuro.jl is a Julia package so from the Julia REPL you can then do

```julia
julia> ] add https://github.com/SpeedyWeather/Chiaroscuro.jl, SpeedyWeather
```

where `]` opens Julia's package manager interactively.
[SpeedyWeather](https://speedyweather.github.io/SpeedyWeatherDocumentation/dev/)
is a dependency anyway and you will need its exported function and types to run a simulation.
Equivalently, you can do

```julia
using Pkg
Pkg.add(url="https://github.com/SpeedyWeather/Chiaroscuro.jl")
Pkg.add("SpeedyWeather")
```

and after all dependencies are installed with `julia> using Chiaroscuro, SpeedyWeather` you load the packages,
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
