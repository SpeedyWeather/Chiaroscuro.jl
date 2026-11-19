
name = "GiorgiaAdam"
description = "Symbolic regression of a neural network but BETTER"

function albedo(inputs)
    (; latd, lond, land_fraction, sea_ice_concentration) = inputs
    (; high_vegetation_cover, low_vegetation_cover, low_vegetation_leaf_area, snow_cover) = inputs

    # land: the equation from section 7, with latitude and longitude computed as in section 3
    cos_latd = cosd(latd)
    sin_lond = sind(lond)
    sin_latd = sind(latd)
    cos_lond = cosd(lond)
    snowc = snow_cover
    land = (snowc + 0.6877954) / (exp(high_vegetation_cover) * (((low_vegetation_cover * (low_vegetation_leaf_area + sin_lond)) / exp(snowc)) + 2.0469608))


    # ocean: open water and sea ice (the equation was fitted on land only)
    ocean = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration

    # weight by the fraction of land in the grid cell, and keep the albedo between 0 and 1
    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
