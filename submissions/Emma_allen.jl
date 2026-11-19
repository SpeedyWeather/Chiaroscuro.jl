name = "Emma"
description = "Symbolic regression of a neural network with additional variables and longer training"

function albedo(inputs)
    (; land_fraction, sea_ice_concentration) = inputs
    (; snow_cover, high_vegetation_cover, low_vegetation_cover, low_vegetation_leaf_area) = inputs
    snowc = snow_cover

    # land: fitted equation
    land = exp(snowc - 2.1602917) *
           exp(exp(-0.28895104 * low_vegetation_cover * exp(low_vegetation_leaf_area - snowc) -
                   exp(high_vegetation_cover) * high_vegetation_cover))

    # ocean: open water and sea ice
    ocean = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration

    # weight by land fraction and constrain albedo to [0, 1]
    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end

# chosen equation:  albedo = exp(snowc + -2.1602917) * exp(exp((low_vegetation_cover * (exp(low_vegetation_leaf_area - snowc) * -0.28895104)) - (exp(high_vegetation_cover) * high_vegetation_cover)))

