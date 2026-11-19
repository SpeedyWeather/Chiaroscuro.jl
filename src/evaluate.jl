export evaluate

"""Path to the reference surface temperature file, an `OctahedralGaussianGrid` with `nlat_half = 24`
(the default grid of a `SpectralGrid(truncation = 32)`) stored as NetCDF."""
const REFERENCE_FILE = joinpath(@__DIR__, "..", "data", "reference_surface_temperature.nc")

"""$(TYPEDSIGNATURES)
Read the reference surface temperature [K] from `path` (default `Chiaroscuro.REFERENCE_FILE`)
as a `Field` on the grid it is stored on. The file contains a vector `surface_temperature`
with the grid points in ring order and the global attributes `grid` (the grid type) and `nlat_half`."""
function reference_surface_temperature(path::AbstractString = REFERENCE_FILE)
    return NCDataset(path) do ds
        Grid = getproperty(RingGrids, Symbol(ds.attrib["grid"]))
        grid = Grid(Int(ds.attrib["nlat_half"]))
        data = Vector{Float32}(ds["surface_temperature"][:])
        Field(data, grid)
    end
end

"""$(TYPEDSIGNATURES)
Reference surface temperature [K] on `grid`, interpolated from the file's grid if they differ."""
reference_surface_temperature(grid::RingGrids.AbstractGrid) = regrid(reference_surface_temperature(), grid)

"""$(TYPEDSIGNATURES)
Return `field` if it is already on `grid`, otherwise interpolate it onto `grid`."""
regrid(field::AbstractField, grid::RingGrids.AbstractGrid) =
    field.grid == grid ? field : RingGrids.interpolate(grid, field)

"""$(TYPEDSIGNATURES)
Area (solid angle) of every grid cell of `grid`, normalised to sum to 1."""
function area_weights(grid::RingGrids.AbstractGrid)
    solid_angles = RingGrids.get_solid_angles(grid)     # per ring
    weights = zeros(RingGrids.get_npoints(grid))
    for (j, ring) in enumerate(RingGrids.eachring(grid))
        weights[ring] .= solid_angles[j]
    end
    return weights ./ sum(weights)
end

"""$(TYPEDSIGNATURES)
Area-weighted root mean square error between `field` and `reference`, with an additional
weight `mask` (e.g. 1 inside and 0 outside a region, or the land fraction) per grid point."""
function rmse(field, reference, weights, mask)
    w = weights .* mask
    return sqrt(sum(w .* (field .- reference) .^ 2) / sum(w))
end

"""$(TYPEDSIGNATURES)
Evaluate the surface air temperature on the last time step of `simulation` that used the
`albedo` against a `reference` surface temperature, read from file by default and
interpolated onto the simulation's grid if they differ. Returns a `NamedTuple` of area-weighted root
mean square errors [K] globally (`score`) and over land, ocean, the tropics (30˚S-30˚N) and
polar regions (poleward of 60˚N/S). Land and ocean are weighted by the land fraction of each grid cell.
The `generalisation_score` is evaluated over the western hemisphere (180˚-360˚E) only, for which
no reference data is given to the participants, who only receive data for the eastern hemisphere (0˚-180˚E)."""
function evaluate(
        albedo::ChiaroscuroAlbedo,
        simulation::SpeedyWeather.AbstractSimulation;
        reference::AbstractField = reference_surface_temperature(),
    )
    # bring to CPU for evaluation
    temperature = on_architecture(CPU(), simulation.variables.parameterizations.surface_air_temperature)
    land_fraction = on_architecture(CPU(), simulation.model.land_sea_mask.land_fraction).data
    reference = on_architecture(CPU(), reference)

    grid = temperature.grid
    reference = regrid(reference, grid)

    T = temperature.data
    T_ref = reference.data
    weights = area_weights(grid)
    londs, latds = RingGrids.get_londlatds(grid)

    return (
        score = rmse(T, T_ref, weights, 1),
        land_score = rmse(T, T_ref, weights, land_fraction),
        ocean_score = rmse(T, T_ref, weights, 1 .- land_fraction),
        tropical_score = rmse(T, T_ref, weights, abs.(latds) .<= 30),
        polar_score = rmse(T, T_ref, weights, abs.(latds) .>= 60),
        generalisation_score = rmse(T, T_ref, weights, mod.(londs, 360) .>= 180),
    )
end
