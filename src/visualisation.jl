"""$(TYPEDSIGNATURES)
Albedo on the last time step of `simulation` as computed by SpeedyWeather's default
`OceanLandAlbedo`, combining ocean and land albedo with the land fraction as in the shortwave radiation."""
function default_albedo(simulation::SpeedyWeather.AbstractSimulation)
    (; model, variables) = simulation
    scheme = OceanLandAlbedo(model.spectral_grid)
    SpeedyWeather.initialize!(scheme, model)

    ocean = similar(variables.parameterizations.ocean.albedo)
    land = similar(variables.parameterizations.land.albedo)
    for ij in eachindex(ocean)
        SpeedyWeather.albedo!(ij, ocean, variables, scheme.ocean, model)
        SpeedyWeather.albedo!(ij, land, variables, scheme.land, model)
    end

    land_fraction = model.land_sea_mask.land_fraction
    return @. (1 - land_fraction) * ocean + land_fraction * land
end

# full field as matrix with lon, lat axes in degrees
function lonlat_matrix(field::AbstractField)
    full_field = RingGrids.interpolate(RingGrids.full_grid_type(field.grid), field.grid.nlat_half, field)
    return RingGrids.get_lond(full_field), RingGrids.get_latd(full_field), Matrix(full_field)
end

"""$(TYPEDSIGNATURES)
Map of the albedo on the last time step of `simulation` (left) and its difference
to SpeedyWeather's default albedo (right), evaluated on the same last time step."""
function Makie.heatmap(::ChiaroscuroAlbedo, simulation::SpeedyWeather.AbstractSimulation; size = (1200, 330))
    albedo = on_architecture(CPU(), simulation.variables.parameterizations.albedo)
    difference = albedo .- on_architecture(CPU(), default_albedo(simulation))

    fig = Makie.Figure(; size, figure_padding = 10)
    axis_kwargs = (aspect = 2, xticks = 0:60:360, yticks = -60:30:60, titlesize = 12)
    ax1 = Makie.Axis(fig[1, 1]; title = "Albedo", axis_kwargs...)
    ax2 = Makie.Axis(fig[1, 3]; title = "Albedo - default albedo", axis_kwargs...)

    lond, latd, mat = lonlat_matrix(albedo)
    hm1 = Makie.heatmap!(ax1, lond, latd, mat, colormap = :grays, colorrange = (0, 1))
    Makie.Colorbar(fig[1, 2], hm1)

    lond, latd, mat = lonlat_matrix(difference)
    max_diff = max(maximum(abs, mat), eps(Float32))
    hm2 = Makie.heatmap!(ax2, lond, latd, mat, colormap = :balance, colorrange = (-max_diff, max_diff))
    Makie.Colorbar(fig[1, 4], hm2)

    Makie.hidedecorations!(ax1, ticks = false, ticklabels = false)
    Makie.hidedecorations!(ax2, ticks = false, ticklabels = false)
    return fig
end
