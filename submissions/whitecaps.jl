name = "Captain Ahab"
description = "Sneaky little whitecaps and a low sun"

function albedo(inputs)
    (; land_fraction, sea_ice_concentration, snow_cover) = inputs
    (; cos_zenith, surface_wind_speed, sea_surface_temperature) = inputs

    # water reflects more when the sun is low (small cos_zenith), like a sunset over the sea
    water = 0.05 + 0.15 * (1 - cos_zenith)^5

    # whitecaps from breaking waves cover more of the ocean the stronger the wind
    whitecaps = clamp(3.8e-6 * surface_wind_speed^3.4, 0, 1)
    water = (1 - whitecaps) * water + whitecaps * 0.5

    # melting sea ice (close to freezing) is darker because of melt ponds
    ice = sea_surface_temperature > 272 ? 0.45 : 0.65
    ocean = (1 - sea_ice_concentration) * water + sea_ice_concentration * ice

    land = 0.3 + 0.5 * snow_cover

    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
