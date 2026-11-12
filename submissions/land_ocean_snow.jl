name = "Snowman"
description = "Land, ocean, sea ice and snow"

function albedo(inputs)
    (; land_fraction, sea_ice_concentration, snow_cover) = inputs

    # ocean: blend open ocean and sea ice
    ocean = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration

    # land: blend bare land and snow
    land = 0.3 * (1 - snow_cover) + 0.8 * snow_cover

    # weight by the fraction of land in the grid cell
    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
