export ChiaroscuroAlbedo

"""Albedo parameterization based on function `albedo`. Fields are $(TYPEDFIELDS)"""
struct ChiaroscuroAlbedo{F} <: SpeedyWeather.AbstractAlbedo
    "[OPTION] Albedo function to define"
    albedo::F
end

Adapt.@adapt_structure ChiaroscuroAlbedo
SpeedyWeather.initialize!(::ChiaroscuroAlbedo, ::PrimitiveEquation) = nothing

# snow depth [m] to snow cover fraction [1] as in SpeedyWeather's default LandSnowAlbedo
const SNOW_COVER = SpeedyWeather.SaturatingSnowCover()
const SNOW_DEPTH_SCALE = 0.05

"""$(TYPEDSIGNATURES)
Collect all predictors for albedo at grid point `ij` into a `NamedTuple`, see the
documentation for a list of all variables with units and description."""
@propagate_inbounds function albedo_inputs(ij, vars, scheme::ChiaroscuroAlbedo, model)
    ts_atmosphere = model.time_stepping
    ts_ocean = time_stepper(model.time_stepping, :ocean)
    ts_land = time_stepper(model.time_stepping, :land)
    (; parameterizations) = vars

    # position and time
    latd = model.geometry.latds[ij]
    lond = model.geometry.londs[ij]
    time = vars.prognostic.clock.time
    seconds_of_day = Dates.hour(time) * 3600 + Dates.minute(time) * 60 + Dates.second(time)
    day_angle = 2π * seconds_of_day / 86400     # 0 at midnight UTC, π at noon UTC
    year_angle = 2π * (Dates.dayofyear(time) - 1 + seconds_of_day / 86400) / Dates.daysinyear(time) # 0 at 1 Jan 00UTC
    cos_zenith = parameterizations.cos_zenith[ij]

    # surface boundary conditions
    orography = model.orography.orography[ij]
    land_fraction = model.land_sea_mask.land_fraction[ij]

    # atmosphere, lowermost layer; vorticity and divergence are scaled by the radius during the simulation
    inv_scale = inv(vars.prognostic.scale[])
    surface_vorticity = get_prognostic_step(vars.grid.vorticity, ts_atmosphere, scheme)[ij, end] * inv_scale
    surface_divergence = get_prognostic_step(vars.grid.divergence, ts_atmosphere, scheme)[ij, end] * inv_scale
    surface_humidity = get_prognostic_step(vars.grid.humidity, ts_atmosphere, scheme)[ij, end]
    surface_pressure = parameterizations.surface_pressure[ij]
    surface_air_temperature = parameterizations.surface_air_temperature[ij]
    surface_air_density = parameterizations.surface_air_density[ij]
    surface_wind_speed = parameterizations.surface_wind_speed[ij]
    surface_roughness = parameterizations.momentum_roughness[ij]
    rain_rate = parameterizations.rain_rate[ij]
    snow_rate = parameterizations.snow_rate[ij]

    # ocean
    sea_surface_temperature = get_prognostic_step(vars.prognostic.ocean.sea_surface_temperature, ts_ocean, scheme)[ij]
    sea_ice_concentration = get_prognostic_step(vars.prognostic.ocean.sea_ice_concentration, ts_ocean, scheme)[ij]

    # land
    soil_temperature = get_prognostic_step(vars.prognostic.land.soil_temperature, ts_land, scheme)
    soil_temperature_1 = soil_temperature[ij, 1]
    soil_temperature_2 = soil_temperature[ij, 2]
    soil_moisture = get_prognostic_step(vars.prognostic.land.soil_moisture, ts_land, scheme)
    soil_moisture_1 = soil_moisture[ij, 1]
    soil_moisture_2 = soil_moisture[ij, 2]
    snow_depth = get_prognostic_step(vars.prognostic.land.snow_depth, ts_land, scheme)[ij]
    snow_cover = min(SNOW_COVER(snow_depth, SNOW_DEPTH_SCALE), 1)
    high_vegetation_cover = parameterizations.land.high_vegetation_cover[ij]
    low_vegetation_cover = parameterizations.land.low_vegetation_cover[ij]
    high_vegetation_leaf_area = parameterizations.land.high_vegetation_leaf_area[ij]
    low_vegetation_leaf_area = parameterizations.land.low_vegetation_leaf_area[ij]

    return (;
        latd, lond, day_angle, year_angle, cos_zenith,
        orography, land_fraction,
        surface_vorticity, surface_divergence, surface_humidity, surface_pressure,
        surface_air_temperature, surface_air_density, surface_wind_speed, surface_roughness,
        rain_rate, snow_rate,
        sea_surface_temperature, sea_ice_concentration,
        soil_temperature_1, soil_temperature_2, soil_moisture_1, soil_moisture_2,
        snow_depth, snow_cover,
        high_vegetation_cover, low_vegetation_cover,
        high_vegetation_leaf_area, low_vegetation_leaf_area,
    )
end

@propagate_inbounds function SpeedyWeather.albedo!(ij, albedo, vars, scheme::ChiaroscuroAlbedo, model)
    inputs = albedo_inputs(ij, vars, scheme, model)
    albedo[ij] = scheme.albedo(inputs)
    return nothing
end
