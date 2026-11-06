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
Maps on the last time step of `simulation`: the albedo (top left) and its difference to
SpeedyWeather's default albedo (top right), the surface air temperature (bottom left) and
its difference to the `reference` surface temperature it is evaluated against (bottom right),
see [`evaluate`](@ref)."""
function Makie.heatmap(
        ::ChiaroscuroAlbedo,
        simulation::SpeedyWeather.AbstractSimulation;
        reference::AbstractField = reference_surface_temperature(simulation.model.spectral_grid.grid),
        size = (1200, 620),
    )
    albedo = on_architecture(CPU(), simulation.variables.parameterizations.albedo)
    albedo_difference = albedo .- on_architecture(CPU(), default_albedo(simulation))
    temperature = on_architecture(CPU(), simulation.variables.parameterizations.surface_air_temperature)
    temperature_difference = temperature .- on_architecture(CPU(), reference)

    fig = Makie.Figure(; size, figure_padding = 10)
    axis_kwargs = (aspect = 2, xticks = 0:60:360, yticks = -60:30:60, titlesize = 12)

    # field, colormap, colorrange (nothing = symmetric around zero), title per panel
    panels = (
        (albedo, :grays, (0, 1), "Albedo"),
        (albedo_difference, :balance, nothing, "Albedo - default albedo"),
        (temperature, :thermal, :auto, "Surface air temperature [K]"),
        (temperature_difference, :balance, nothing, "Surface air temperature - reference [K]"),
    )

    for (n, (field, colormap, colorrange, title)) in enumerate(panels)
        row, col = fldmod1(n, 2)
        ax = Makie.Axis(fig[row, 2col - 1]; title, axis_kwargs...)
        lond, latd, mat = lonlat_matrix(field)
        if isnothing(colorrange)
            max_abs = max(maximum(abs, mat), eps(Float32))
            colorrange = (-max_abs, max_abs)
        elseif colorrange == :auto
            colorrange = extrema(mat)
        end
        hm = Makie.heatmap!(ax, lond, latd, mat; colormap, colorrange)
        Makie.Colorbar(fig[row, 2col], hm)
        Makie.hidedecorations!(ax, ticks = false, ticklabels = false)
    end
    return fig
end
