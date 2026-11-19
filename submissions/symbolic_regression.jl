name = "Bradley"
description = "Symbolic regression from the example notebook"

function albedo(inputs)
    (; low_vegetation_leaf_area, surface_roughness) = inputs
    return (-0.13820925 / ((-0.20815352 - low_vegetation_leaf_area) - (surface_roughness / 0.039272778))) - -0.1343905
end
