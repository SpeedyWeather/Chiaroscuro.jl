name = "Bella"
description = "Symbolic regression of a neural network with additional variables and longer training"

function albedo(inputs)
    (; land_fraction, sea_ice_concentration) = inputs
    (; snow_cover, high_vegetation_cover, low_vegetation_cover, soil_moisture_1) = inputs
    snowc = snow_cover
    
    # land: Bella fitted equation
    land = exp(
        (snowc - (high_vegetation_cover +
         exp(low_vegetation_cover + soil_moisture_1 - 1.7837389))) *
        exp(low_vegetation_cover / -1.6185225 + low_vegetation_cover) -
        0.9558738
    )

    # ocean: open water and sea ice
    ocean = 0.06 * (1 - sea_ice_concentration) + 0.6 * sea_ice_concentration

    # weight by land fraction and constrain albedo to [0, 1]
    a = (1 - land_fraction) * ocean + land_fraction * land
    return clamp(a, 0, 1)
end

# chosen equation:  albedo = exp(snowc + -2.1602917) * exp(exp((low_vegetation_cover * (exp(low_vegetation_leaf_area - snowc) * -0.28895104)) - (exp(high_vegetation_cover) * high_vegetation_cover)))

# bella submission equation: chosen equation:  albedo = exp(((snowc - (high_vegetation_cover + exp(low_vegetation_cover + (soil_moisture_1 + -1.7837389)))) * exp((low_vegetation_cover / -1.6185225) + low_vegetation_cover)) + -0.9558738)
