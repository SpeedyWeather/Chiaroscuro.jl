name = "Conchúr Ó Cathasaigh"
description = "Stepwise linear regression part ii"

function albedo(inputs)
    (; latd, lond, land_fraction, sea_ice_concentration) = inputs
    (; high_vegetation_cover, low_vegetation_cover, low_vegetation_leaf_area) = inputs
    (; snow_depth, surface_roughness, snow_cover, soil_moisture_2) = inputs

    # stepwise linear regression
    sin_lond = sind(lond)
    a = 0.22197745760556203 -
        0.032274522809054865 * (sin_lond - 0.6670778758303375) / 0.274440687488348 -
        0.11380252048459291 * (high_vegetation_cover - 0.23742209374904633) / 0.3569721281528473 -
        0.10965433007409642 * (low_vegetation_cover - 0.4988933205604553) / 0.42057308554649353 -
        0.01059268657283943 * (low_vegetation_leaf_area - 1.0299466848373413) / 0.8743666410446167 +
        0.010786533748243857 * (snow_depth - 0.8201590180397034) / 2.7313692569732666 -
        0.042870947574265864 * (surface_roughness - 0.41663917899131775) / 0.5517367720603943 +
        0.38398457427484783 * (snow_cover - 0.11288916319608688) / 0.3131408989429474 +
        0.13552342532092526 * (land_fraction - 0.9793006181716919) / 0.07042635232210159 -
        0.10775197736168596 * (soil_moisture_2 - 0.22972384095191956) / 0.14154864847660065

    # keep the albedo between 0 and 1
    return clamp(a, 0, 1)
end
