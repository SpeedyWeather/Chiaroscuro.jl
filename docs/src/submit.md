# Submit to Chiaroscuro

Once you are ready to submit your solution to Chiaroscuro do the following

1. Create a file like `bright_poles.jl`
2. In it, there needs to be several variables defined
- `name`: a `String` with your name, your group's name etc
- `description`: a `String` describing your submission in <10 words
- `albedo`: a function `albedo(x, y, z)` of Cartesian coordinates on the unit sphere returning the albedo

For example such a file could look like

```julia
name = "Brian"
description = "Bright poles, dark tropics"

# z = sin(latitude) on the unit sphere
albedo(x, y, z) = 0.1 + 0.6 * abs(z)
```

and create a pull request placing that file into the
[`/submissions` folder](https://github.com/SpeedyWeather/Chiaroscuro.jl/tree/main/submissions)
of the Chiaroscuro.jl repository.

The file you submit is executed as a Julia script. This means your formatting does not matter
as long as it is valid Julia code and particularly you can code in it, e.g. define helper
functions that `albedo` calls.

The easiest is to have a look at existing submissions listed in
[List of submissions](@ref) and get some inspirations from
[Chiaroscuro instructions](@ref). The `name` and `description`
strings are used in the [List of submissions](@ref) and the [Chiaroscuro leaderboard](@ref).

## Rules

1. TODO: valid range of albedo values
2. TODO: simulation setup (resolution, model, period)
3. Points are given following the [Evaluation](@ref).
4. You can submit up to 10 unique submissions alone or in groups (don't overload GitHub actions with a million submissions).

In the end you can't really cheat because GitHub actions will evaluate your submission following these rules anyway...
