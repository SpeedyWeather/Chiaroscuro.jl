"""Path to the default albedo file, SpeedyWeather's default albedo after a 30-day default
`PrimitiveWetModel` simulation on an `OctahedralGaussianGrid` with `nlat_half = 24`, stored as NetCDF."""
const DEFAULT_ALBEDO_FILE = joinpath(@__DIR__, "..", "data", "default_albedo.nc")

"""$(TYPEDSIGNATURES)
SpeedyWeather's default albedo read from `path` (default `Chiaroscuro.DEFAULT_ALBEDO_FILE`)
as a `Field` on the grid it is stored on, see `data/create_default_albedo.jl`."""
default_albedo(path::AbstractString = DEFAULT_ALBEDO_FILE) = read_field(path, "albedo")

"""$(TYPEDSIGNATURES)
SpeedyWeather's default albedo on `grid`, interpolated from the file's grid if they differ."""
default_albedo(grid::RingGrids.AbstractGrid) = regrid(default_albedo(), grid)

"""$(TYPEDSIGNATURES)
SpeedyWeather's default albedo read from file on the grid of `simulation`."""
default_albedo(simulation::SpeedyWeather.AbstractSimulation) = default_albedo(simulation.model.spectral_grid.grid)

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
        reference::AbstractField = reference_surface_temperature(),
        size = (1200, 620),
    )
    albedo = on_architecture(CPU(), simulation.variables.parameterizations.albedo)
    albedo_difference = albedo .- on_architecture(CPU(), default_albedo(simulation))
    temperature = on_architecture(CPU(), simulation.variables.parameterizations.surface_air_temperature)
    temperature_difference = temperature .- regrid(on_architecture(CPU(), reference), temperature.grid)

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
