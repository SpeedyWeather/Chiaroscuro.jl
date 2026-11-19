# Research directions

A low score on the [Chiaroscuro leaderboard](@ref) is a good start, but it is not the whole story.
Below are three directions that go beyond "fit the albedo, minimise the RMSE".
Each of them is an open research question for data-driven parameterizations
in general, and the Chiaroscuro albedo problem is a small, cheap and transparent
playground to explore them.

## Online performance

A parameterization like `albedo(inputs)` is often trained *offline*: you take
data, e.g. ERA5 predictors and an observed albedo, and fit a function to it.
But it is then used *online*, inside a model that feeds its own state back as
the inputs of your function. These are not the same problem.

- **The model world is not the real world.** SpeedyWeather's temperatures,
  snow cover, sea ice or soil moisture are biased compared to observations.
  A function that is perfect on observed inputs will see different inputs
  online and may therefore perform worse than expected.
- **Feedback loops.** Online, your albedo changes the surface temperature,
  which changes snow and sea ice, which changes your albedo again.
  The ice-albedo feedback is the classic example. Offline, these loops don't
  exist: the inputs are fixed, whatever albedo you predict. Online, small
  errors can amplify (or be damped), and a function can even drift into
  states it has never seen during training.
- **Compensating errors.** The best albedo for the *model* is not necessarily
  the observed albedo. It may compensate for errors elsewhere, e.g. in clouds
  or radiation, to give better surface temperatures. Is that what you want?

Ideas to explore: Compare the offline error (fit to observed albedo) with the
online score from [`evaluate`](@ref). Does a better offline fit always give a better
online score? Can you train *online*, i.e. tune parameters of your albedo
function directly against the simulated surface temperature? How long do you
need to run before feedbacks show up?

## Robustness and generalisation

Adding predictors or parameters often increases skill, but skill on the data
you trained on is not the same as skill elsewhere.

- **Overfitting.** A function with many tuned parameters can memorise the
  training period, but performs poorly on another period, season or resolution.
- **Correlation is not causation.** Some predictors correlate with albedo
  without causing it. Latitude, for example, correlates with snow and ice
  today, but in a warmer climate the snow line moves while latitude doesn't.
  Prefer predictors that physically control albedo (snow depth, sea ice
  concentration, vegetation, wind speed for whitecaps, ...) over those that
  merely happen to be correlated with it.
- **Out-of-distribution.** A parameterization is applied in conditions it was
  not trained for: climate change, a different season, changed boundary
  conditions (orography, land-sea mask, vegetation), another climate
  (palaeoclimate, a snowball Earth) or even other planets. A physically
  motivated function has a better chance to generalise than one that is only
  tuned to the present day.

Ideas to explore: Evaluate your albedo function in another season, at another
resolution or for a longer period. Change the boundary conditions, e.g. increase
CO₂, change the land-sea mask or the solar constant, and check whether your
function still behaves sensibly (see the
[SpeedyWeather documentation](https://speedyweather.github.io/SpeedyWeatherDocumentation/dev/)
for how). Does a simpler function generalise better than a more skilful one?

## Uncertainty and model confidence

No model is perfect, so what to do with the residual error? A deterministic
function predicts one albedo given the inputs, but in reality many albedos
are consistent with the same inputs: the predictors do not contain all the
information (sub-grid heterogeneity, the age of snow, the type of vegetation, ...).

- **Represent the error statistically.** Instead of ignoring the residual,
  represent it through a random process. Use noise, e.g. `randn()`, as an additional
  input that is scaled to represent the uncertainty of the output,
  e.g. larger over a snow edge than over the open ocean.
- **Sample the uncertainty.** Repeated inference with varying noise then
  samples from the distribution of possible outputs. Running an ensemble of
  simulations with different random seeds samples the resulting uncertainty
  in surface temperature too.
- **Match the target distribution.** A good stochastic parameterization
  is not only right on average, its spread also matches the error statistics:
  Can you match the distribution of the target, not just its mean?
  Is the ensemble spread consistent with the error of the ensemble mean?
- **Time and space correlation.** White noise, independent at every grid point
  and time step, averages out quickly. Should the noise be correlated in space
  and time, e.g. through an AR(1) process, to have a meaningful effect?

Ideas to explore: Add a noise term to your albedo function and run an ensemble.
Compare the spread of the ensemble to the error of the ensemble mean.
Does the stochastic albedo improve the ensemble-mean score compared to the
deterministic one?
