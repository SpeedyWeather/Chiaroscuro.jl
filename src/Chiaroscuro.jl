module Chiaroscuro

using SpeedyWeather, Adapt, Dates
using DocStringExtensions: DocStringExtensions, TYPEDFIELDS
using RingGrids
using NCDatasets: NCDataset
import Makie

using Base: @propagate_inbounds
using SpeedyWeather: PrimitiveEquation, get_prognostic_step, time_stepper

# show default argument values with DocStringExtensions v0.10, plain typed signatures with v0.9
const TYPEDSIGNATURES = if hasmethod(DocStringExtensions.TypedMethodSignatures, Tuple{}, (:defaults,))
    DocStringExtensions.TypedMethodSignatures(defaults = true)
else
    DocStringExtensions.TYPEDSIGNATURES
end

include("albedo.jl")
include("evaluate.jl")
include("visualisation.jl")

end
