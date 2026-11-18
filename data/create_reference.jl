# Creates reference_surface_temperature.nc, the surface temperature [K] all submissions are evaluated against.
# Stored on an OctahedralGaussianGrid with nlat_half = 24, the default grid for SpectralGrid(truncation = 32).
# Run with: julia --project=docs data/create_reference.jl
using SpeedyWeather, NCDatasets

grid = OctahedralGaussianGrid(24)
_, latds = RingGrids.get_londlatds(grid)

# made-up placeholder: 300K at the equator decreasing to 250K at the poles
temperature = Float32.(300 .- 50 .* sind.(latds) .^ 2)

path = joinpath(@__DIR__, "reference_surface_temperature.nc")
rm(path, force = true)
NCDataset(path, "c") do ds
    ds.attrib["grid"] = "OctahedralGaussianGrid"
    ds.attrib["nlat_half"] = 24
    ds.attrib["description"] = "Reference surface temperature for Chiaroscuro.jl, grid points in ring order"
    defDim(ds, "points", length(temperature))
    v = defVar(ds, "surface_temperature", Float32, ("points",), attrib = ["units" => "K"])
    v[:] = temperature
end
