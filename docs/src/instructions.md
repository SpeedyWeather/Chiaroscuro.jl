# Chiaroscuro instructions

First, get yourself familiar with

0. the general workflow to run a [SpeedyWeather](https://speedyweather.github.io/SpeedyWeatherDocumentation/stable/how_to_run_speedy/) simulation
1. how to define an albedo function and wrap it into a `ChiaroscuroAlbedo`, see [Albedo](@ref)
2. the [Evaluation](@ref) of your simulated surface temperatures
3. and [Visualising albedo](@ref) to see how bright or dark your planet is

With the information from 2&3 you can then change your albedo function and repeat
to find a lower score.

## Strategy 1: Start simple

A constant albedo of about 0.3 is roughly what the Earth reflects on average.
Start from there and evaluate how far off the surface temperatures are,
then add one input at a time, e.g. make sea ice brighter than the open ocean.

## Strategy 2: Know your physics

The [Albedo](@ref) page lists typical albedo values of ocean, forest, desert, sea ice and snow.
Use the inputs to tell where on the planet you are and what the surface likely looks like.

## Strategy 3: Divide and conquer

Look at the [Regional scores](@ref): where are your surface temperatures off the most?
Too warm means too little sunlight is reflected, so your albedo is likely too low there, and vice versa.
You could also aim for the best land, ocean, tropical or polar score first.

## Strategy 4: Sharing is caring

Check the [List of submissions](@ref) for what others have tried.
Team work is allowed, share your achievements, that's how open source software works!
