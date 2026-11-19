name = "Johanna Gring"
description = "Symbolic regression of a neural network"

function albedo(inputs)
    (; latd, lond, snow_cover, high_vegetation_cover, soil_moisture_1, lond) = inputs
    (; high_vegetation_cover, low_vegetation_cover, high_vegetation_leaf_area, low_vegetation_leaf_area) = inputs
    snowc = snow_cover
    a = exp(snowc + (-1.2128508 - ((-0.23823759 * ((0.83241564 - high_vegetation_cover) * ((((snowc - low_vegetation_cover) + ((cosd(lond) - snowc) - (soil_moisture_1 * (((cosd(lond) - high_vegetation_cover) - -1.3156883) + (high_vegetation_leaf_area + (((cosd(lond) - low_vegetation_leaf_area) - snowc) - (-1.3156883 - cosd(lond)))))))) * (1.1545302 - snowc)) - low_vegetation_leaf_area))) + high_vegetation_cover)))
    return clamp(a, 0, 1)
end
