# Submit to Chiaroscuro

Once you are ready to submit your solution to Chiaroscuro do the following

1. Create a file like `sea_ice.jl`
2. In it, there needs to be several variables defined
- `name`: a `String` with your name, your group's name etc
- `description`: a `String` describing your submission in <10 words
- `albedo`: a function `albedo(inputs)` returning the albedo, see [Albedo](@ref)

For example such a file could look like

```julia
name = "Brian"
description = "Bright sea ice, dark ocean"

function albedo(inputs)
    (; sea_ice_concentration) = inputs
    a = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration
    return clamp(a, 0, 1)
end
```

and create a pull request placing that file into the
[`/submissions` folder](https://github.com/SpeedyWeather/Chiaroscuro.jl/tree/main/submissions)
of the Chiaroscuro.jl repository.

The file you submit is executed as a Julia script. This means your formatting does not matter
as long as it is valid Julia code and particularly you can code in it, e.g. define helper
functions or constants that `albedo` uses.

The easiest is to have a look at existing submissions listed in
[List of submissions](@ref) and get some inspirations from
[Chiaroscuro instructions](@ref). The `name` and `description`
strings are used in the [List of submissions](@ref) and the [Chiaroscuro leaderboard](@ref).

## Rules

1. Albedo has to be between 0 and 1 inclusive.
2. Only scalar arithmetic is allowed in your albedo function, see [Albedo](@ref).
3. Simulations use SpeedyWeather's `PrimitiveWetModel` in its default configuration at T32 spectral resolution and 8 vertical layers, run for 30 days.
4. Submissions are ranked by `score` following the [Evaluation](@ref), lower is better.
5. You can submit up to 10 unique submissions alone or in groups (don't overload GitHub actions with a million submissions).

In the end you can't really cheat because GitHub actions will evaluate your submission following these rules anyway...
