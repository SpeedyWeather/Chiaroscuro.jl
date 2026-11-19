# Chiaroscuro leaderboard

The Chiaroscuro leaderboard ranks submissions in
[/submissions](https://github.com/SpeedyWeather/Chiaroscuro.jl/tree/main/submissions)
to the Chiaroscuro albedo challenge by their score, the root mean square error (RMSE)
of the simulated surface temperature against a reference, see [Evaluation](@ref).
Lower is better! The land, ocean, tropical and polar scores are the same RMSE but only
evaluated over the respective region, see [Regional scores](@ref).
The generalisation score is the RMSE over the western hemisphere (180˚-360˚E) only,
the half of the globe for which no reference data is given to participants, see
[Generalisation score](@ref). It shows how well an albedo generalises to unseen regions.
To [Submit to Chiaroscuro](@ref) see that section of the docs and particular the rules and
formalities explained within. Also see [List of submissions](@ref) for a list of all
submissions, their respective code and albedo maps.

## Leaderboard

| Rank | Author | Description | Score | Land | Ocean | Tropics | Poles | Generalisation |
| :--- | :----- | :---------- | ----: | ---: | ----: | ------: | ----: | -------------: |
