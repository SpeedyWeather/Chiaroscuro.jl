# Creates reference_surface_temperature.nc, the surface temperature [K] all submissions are evaluated against.
# Source: tsurf_mean.nc, the time-mean SpeedyWeather surface air temperature [˚C] on a FullGaussianGrid
# with nlat_half = 96 (384x192, 2000-01-15 to 2000-02-15, not stored in the repo), interpolated onto an
# OctahedralGaussianGrid with nlat_half = 24, the default grid for SpectralGrid(truncation = 32).
# Rounded to 10 mantissa bits (precision ≤ 0.25 K for 256-512 K) and losslessly compressed,
# as in SpeedyWeather's NetCDF output.
# Run with: julia --project data/create_reference.jl path/to/tsurf_mean.nc
using SpeedyWeather, NCDatasets

source = length(ARGS) > 0 ? ARGS[1] : joinpath(@__DIR__, "tsurf_mean.nc")
tsurf_celsius = NCDataset(ds -> Array(ds["tsurf_mean"][:, :]), source)   # (lon, lat), north to south

highres = Field(vec(Float32.(tsurf_celsius .+ 273.15)), FullGaussianGrid(96))  # full grids store rings lon-first
temperature = RingGrids.interpolate(OctahedralGaussianGrid(24), highres)
SpeedyWeather.round!(temperature.data, 10)

path = joinpath(@__DIR__, "reference_surface_temperature.nc")
rm(path, force = true)
NCDataset(path, "c") do ds
    ds.attrib["grid"] = "OctahedralGaussianGrid"
    ds.attrib["nlat_half"] = 24
    ds.attrib["description"] = "Reference surface temperature for Chiaroscuro.jl, grid points in ring order. " *
        "Time-mean SpeedyWeather surface air temperature 2000-01-15 to 2000-02-15 interpolated from FullGaussianGrid(96)"
    defDim(ds, "points", length(temperature))
    v = defVar(ds, "surface_temperature", Float32, ("points",),
        attrib = ["units" => "K"], deflatelevel = 9, shuffle = true)
    v[:] = temperature.data
end
