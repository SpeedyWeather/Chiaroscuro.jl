export ChiaroscuroAlbedo

"""Albedo parameterization based on function `albedo`. Fields are $(TYPEDFIELDS)"""
struct ChiaroscuroAlbedo{F} <: SpeedyWeather.AbstractAlbedo
    "[OPTION] Albedo function to define"
    albedo::F
end

Adapt.@adapt_structure ChiaroscuroAlbedo
SpeedyWeather.initialize!(::ChiaroscuroAlbedo, ::PrimitiveEquation) = nothing

@propagate_inbounds function albedo!(ij, albedo, vars, scheme::ChiaroscuroAlbedo, model)
    ts = model.time_stepping

    # atmosphere

    # ocean
    sea_surface_temperature = get_prognostic_step(vars.prognostic.ocean.sea_surface_temperature, ts, scheme)[ij]
    sea_ice_concentration = get_prognostic_step(vars.prognostic.ocean.sea_ice_concentration, ts, scheme)[ij]

    # land


    # pack into named tuple and evaluate the function
    nt = (; sea_surface_temperature, sea_ice_concentration)
    albedo[ij] = scheme.albedo(nt)
    return nothing
end