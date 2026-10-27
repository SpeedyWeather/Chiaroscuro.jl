name = "Brian"
description = "Bright poles, dark tropics"

# z = sin(latitude) on the unit sphere, so |z| is 0 at the equator and 1 at the poles
albedo(x, y, z) = 0.1 + 0.6 * abs(z)
