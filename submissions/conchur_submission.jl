name = "Conchúr Ó Cathasaigh"
description = "Stepwise linear regression for albedo"

function albedo(inputs)
    (; latd, lond, land_fraction, sea_ice_concentration) = inputs
    (; high_vegetation_cover, low_vegetation_cover, low_vegetation_leaf_area) = inputs
    (; high_vegetation_leaf_area, snow_depth, soil_moisture_1) = inputs

    # linear regression on standardised features (training-set mean and std),
    # fitted on all grid cells: land, ocean and sea ice
    sin_lond = sind(lond)
    a = 0.35404542313636833 -
        0.03747681963527709 * (sin_lond - 0.6670778758303375) / 0.274440687488348 -
        0.1581692711679168 * (high_vegetation_cover - 0.23742209374904633) / 0.3569721281528473 -
        0.10786478297918996 * (low_vegetation_cover - 0.4988933205604553) / 0.42057308554649353 -
        0.011140665355197012 * (high_vegetation_leaf_area - 1.2122645378112793) / 1.4638147354125977 -
        0.02054918790951849 * (low_vegetation_leaf_area - 1.0299466848373413) / 0.8743666410446167 +
        0.0473728732784119 * (snow_depth - 0.8201590180397034) / 2.7313692569732666 +
        0.04234441245539077 * (soil_moisture_1 - 0.1947755068540573) / 0.14566275477409363

    # keep the albedo between 0 and 1
    return clamp(a, 0, 1)
end
