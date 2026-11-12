name = "Robin Hood"
description = "The forest, dark and deep"

function albedo(inputs)
    (; land_fraction, sea_ice_concentration, snow_depth) = inputs
    (; high_vegetation_cover, low_vegetation_cover, high_vegetation_leaf_area) = inputs

    ocean = 0.06 + 0.54 * sea_ice_concentration

    # bare soil is bright, forests are dark, grass is in between
    bare_soil = max(1 - high_vegetation_cover - low_vegetation_cover, 0)
    land = 0.35 * bare_soil + 0.2 * low_vegetation_cover + 0.13 * high_vegetation_cover

    # snow is brighter the deeper it is, but dense forests (high leaf area) hide it
    snow_cover = snow_depth / (snow_depth + 0.02)
    visible = exp(-0.5 * high_vegetation_leaf_area * high_vegetation_cover)
    land += 0.5 * snow_cover * visible

    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end
