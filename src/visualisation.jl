"""$(TYPEDSIGNATURES)
Albedo on the last time step of `simulation` as computed by SpeedyWeather's default
`OceanLandAlbedo`, combining ocean and land albedo with the land fraction as in the shortwave radiation."""
function default_albedo(simulation::SpeedyWeather.AbstractSimulation)
    (; model, variables) = simulation
    scheme = OceanLandAlbedo(model.spectral_grid)
    SpeedyWeather.initialize!(scheme, model)

    # the default albedo may write into variables (e.g. black/white-sky albedo of the
    # LearnedLandAlbedo) that a simulation with ChiaroscuroAlbedo doesn't allocate, add them
    variables = with_default_albedo_variables(variables, scheme)

    ocean = similar(variables.parameterizations.ocean.albedo)
    land = similar(variables.parameterizations.land.albedo)
    for ij in eachindex(ocean)
        SpeedyWeather.albedo!(ij, ocean, variables, scheme.ocean, model)
        SpeedyWeather.albedo!(ij, land, variables, scheme.land, model)
    end

    land_fraction = model.land_sea_mask.land_fraction
    return @. (1 - land_fraction) * ocean + land_fraction * land
end

"""$(TYPEDSIGNATURES)
Return `variables` with the parameterization variables of the `scheme` added that are missing
in `variables.parameterizations` (e.g. because the simulation used a different albedo),
allocated as 2D fields like the albedo itself. Existing variables are not copied."""
function with_default_albedo_variables(variables::SpeedyWeather.Variables, scheme)
    parameterizations = variables.parameterizations
    for var in SpeedyWeather.variables(scheme)
        var isa SpeedyWeather.ParameterizationVariable || continue
        namespace = var.namespace
        toplevel = namespace == Symbol("")
        group = toplevel ? parameterizations : getproperty(parameterizations, namespace)
        haskey(group, var.name) && continue
        group = merge(group, NamedTuple{(var.name,)}((similar(parameterizations.albedo),)))
        parameterizations = toplevel ? group : merge(parameterizations, NamedTuple{(namespace,)}((group,)))
    end
    fields = fieldnames(SpeedyWeather.Variables)
    return SpeedyWeather.Variables(; (field => getfield(variables, field) for field in fields)..., parameterizations)
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
