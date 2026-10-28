module Chiaroscuro

using SpeedyWeather, Adapt, DocStringExtensions
using RingGrids
import Makie

using Base: @propagate_inbounds
using SpeedyWeather: PrimitiveEquation, get_prognostic_step, time_stepper

include("albedo.jl")
include("evaluate.jl")
include("visualisation.jl")

end
