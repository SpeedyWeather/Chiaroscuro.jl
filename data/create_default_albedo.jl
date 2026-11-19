# Creates default_albedo.nc, SpeedyWeather's default albedo that submissions are compared against
# in the visualisation. Runs a default PrimitiveWetModel at the challenge's resolution (truncation 32,
# 8 layers, OctahedralGaussianGrid with nlat_half = 24) for 30 days and stores the albedo of the last
# time step. Rounded to 9 mantissa bits (precision ≤ 0.5e-3 for albedos in 0-1) and losslessly
# compressed, as in SpeedyWeather's NetCDF output.
# Run with: julia --project data/create_default_albedo.jl
using SpeedyWeather, NCDatasets

spectral_grid = SpectralGrid(truncation = 32, nlayers = 8)
model = PrimitiveWetModel(spectral_grid)
simulation = initialize!(model)
run!(simulation, period = Day(30))

albedo = Field(Array(simulation.variables.parameterizations.albedo.data), spectral_grid.grid)
SpeedyWeather.round!(albedo.data, 9)

path = joinpath(@__DIR__, "default_albedo.nc")
rm(path, force = true)
NCDataset(path, "c") do ds
    ds.attrib["grid"] = string(nameof(typeof(spectral_grid.grid)))
    ds.attrib["nlat_half"] = spectral_grid.grid.nlat_half
    ds.attrib["description"] = "Default albedo for Chiaroscuro.jl, grid points in ring order. " *
        "Albedo after 30 days of a default SpeedyWeather v$(pkgversion(SpeedyWeather)) PrimitiveWetModel (truncation 32, 8 layers)"
    defDim(ds, "points", length(albedo))
    v = defVar(ds, "albedo", Float32, ("points",),
        attrib = ["units" => "1"], deflatelevel = 9, shuffle = true)
    v[:] = albedo.data
end
