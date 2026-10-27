using Chiaroscuro, SpeedyWeather
using Test

@testset "Chiaroscuro.jl" begin
    function albedo(inputs)
        (; sea_ice_concentration) = inputs
        return clamp(0.06 + 0.54 * sea_ice_concentration, 0, 1)
    end

    spectral_grid = SpectralGrid(truncation = 21, nlayers = 4)
    my_albedo = ChiaroscuroAlbedo(albedo)
    model = PrimitiveWetModel(spectral_grid; albedo = my_albedo)
    simulation = initialize!(model)
    run!(simulation, period = Day(1))

    @testset "evaluate" begin
        evaluation = evaluate(my_albedo, simulation)
        for key in (:score, :land_score, :ocean_score, :tropical_score, :polar_score)
            @test isfinite(evaluation[key])
            @test evaluation[key] >= 0
        end

        # perfect agreement with the reference gives zero error
        T = simulation.variables.parameterizations.surface_air_temperature
        @test evaluate(my_albedo, simulation; reference = copy(T)).score == 0

        # area weights sum to 1
        @test sum(Chiaroscuro.area_weights(spectral_grid.grid)) ≈ 1
    end

    @testset "heatmap" begin
        # default albedo is a valid albedo
        default = Chiaroscuro.default_albedo(simulation)
        @test all(0 .<= default.data .<= 1)
        fig = Chiaroscuro.Makie.heatmap(my_albedo, simulation)
        @test fig isa Chiaroscuro.Makie.Figure
    end
end
