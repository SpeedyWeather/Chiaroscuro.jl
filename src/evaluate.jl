export evaluate

"""$(TYPEDSIGNATURES)
Made-up reference surface temperature [K] on `grid` until the real reference is provided:
300K at the equator decreasing to 250K at the poles."""
function reference_surface_temperature(grid::RingGrids.AbstractGrid)
    _, latds = RingGrids.get_londlatds(grid)
    return Field(300 .- 50 .* sind.(latds) .^ 2, grid)
end

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
`albedo` against a `reference` surface temperature. Returns a `NamedTuple` of area-weighted root
mean square errors [K] globally (`score`) and over land, ocean, the tropics (30˚S-30˚N) and
polar regions (poleward of 60˚N/S). Land and ocean are weighted by the land fraction of each grid cell."""
function evaluate(
        albedo::ChiaroscuroAlbedo,
        simulation::SpeedyWeather.AbstractSimulation;
        reference::AbstractField = reference_surface_temperature(simulation.model.spectral_grid.grid),
    )
    # bring to CPU for evaluation
    temperature = on_architecture(CPU(), simulation.variables.parameterizations.surface_air_temperature)
    land_fraction = on_architecture(CPU(), simulation.model.land_sea_mask.land_fraction).data
    reference = on_architecture(CPU(), reference)

    grid = temperature.grid
    @assert reference.grid == grid "Reference has to be on the same grid as the simulation, $(reference.grid) given."

    T = temperature.data
    T_ref = reference.data
    weights = area_weights(grid)
    _, latds = RingGrids.get_londlatds(grid)

    return (
        score = rmse(T, T_ref, weights, 1),
        land_score = rmse(T, T_ref, weights, land_fraction),
        ocean_score = rmse(T, T_ref, weights, 1 .- land_fraction),
        tropical_score = rmse(T, T_ref, weights, abs.(latds) .<= 30),
        polar_score = rmse(T, T_ref, weights, abs.(latds) .>= 60),
    )
end
