name = "Brian"
description = "Bright sea ice, dark ocean"

function albedo(inputs)
    (; sea_ice_concentration) = inputs

    # linear blend between dark open ocean and bright sea ice
    a = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration
    return clamp(a, 0, 1)
end
