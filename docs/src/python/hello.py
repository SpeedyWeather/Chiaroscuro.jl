import math

# the default albedo in Chiaroscuro is 0.3, how much sunlight is absorbed?
albedo = 0.3
solar_constant = 1361  # W/m^2
absorbed = (1 - albedo) * solar_constant / 4
print(f"Absorbed sunlight: {absorbed:.4f} W/m^2")

# and the resulting effective radiating temperature of the Earth
stefan_boltzmann = 5.670374419e-8  # W/m^2/K^4
temperature = (absorbed / stefan_boltzmann) ** 0.25
print(f"Effective temperature: {temperature:.4f} K")
print(f"In Celsius: {temperature - 273.15:.4f} °C, sqrt(2) = {math.sqrt(2):.4f}")
