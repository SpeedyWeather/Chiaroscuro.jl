name = "Bradley"
description = "baseline with lat lon"

function albedo(inputs)
    (; latd, lond, land_fraction, sea_ice_concentration) = inputs
    (; high_vegetation_cover, low_vegetation_cover, low_vegetation_leaf_area) = inputs

    # land: the equation from section 7, with latitude and longitude computed as in section 3
    cos_latd = cosd(latd)
    sin_lond = sind(lond)
    land = 0.9197872 / (((low_vegetation_leaf_area + exp(high_vegetation_cover + cos_latd)) - (sin_lond * (0.28641453 - ((cos_latd * sin_lond) + high_vegetation_cover)))) + low_vegetation_cover)

    # ocean: open water and sea ice (the equation was fitted on land only)
    ocean = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration

    # weight by the fraction of land in the grid cell, and keep the albedo between 0 and 1
    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
