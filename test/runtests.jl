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

    @testset "albedo inputs" begin
        vars, model = simulation.variables, simulation.model
        inputs = Chiaroscuro.albedo_inputs(1, vars, my_albedo, model)
        @test length(inputs) == 29
        for ij in (1, length(vars.parameterizations.albedo) ÷ 2)
            inputs = Chiaroscuro.albedo_inputs(ij, vars, my_albedo, model)
            @test all(isfinite, values(inputs))
        end
        @test 0 <= inputs.day_angle < 2π
        @test 0 <= inputs.year_angle < 2π
        @test 0 <= inputs.snow_cover <= 1
    end

    @testset "evaluate" begin
        evaluation = evaluate(my_albedo, simulation)
        for key in (:score, :land_score, :ocean_score, :tropical_score, :polar_score, :generalisation_score)
            @test isfinite(evaluation[key])
            @test evaluation[key] >= 0
        end

        # perfect agreement with the reference gives zero error
        T = simulation.variables.parameterizations.surface_air_temperature
        @test evaluate(my_albedo, simulation; reference = copy(T)).score == 0

        # generalisation score only sees the western hemisphere (180˚-360˚E)
        reference_west = copy(T)
        londs, _ = RingGrids.get_londlatds(reference_west.grid)
        reference_west.data[londs .< 180] .+= 10     # error only in the eastern hemisphere
        evaluation = evaluate(my_albedo, simulation; reference = reference_west)
        @test evaluation.generalisation_score == 0
        @test evaluation.score > 0

        # reference is read from file on the default grid of truncation 32
        reference = Chiaroscuro.reference_surface_temperature()
        @test reference.grid == OctahedralGaussianGrid(24)
        @test all(200 .< reference.data .< 330)

        # truncation 21 runs on a different grid, the reference is interpolated
        @test reference.grid != spectral_grid.grid
        @test Chiaroscuro.reference_surface_temperature(spectral_grid.grid).grid == spectral_grid.grid

        # area weights sum to 1
        @test sum(Chiaroscuro.area_weights(spectral_grid.grid)) ≈ 1
    end

    @testset "heatmap" begin
        # default albedo is a valid albedo
        default = Chiaroscuro.default_albedo()
        @test default.grid == OctahedralGaussianGrid(24)
        @test all(0 .<= default.data .<= 1)

        # interpolated onto the simulation's grid (truncation 21)
        @test Chiaroscuro.default_albedo(simulation).grid == simulation.model.spectral_grid.grid
        fig = Chiaroscuro.Makie.heatmap(my_albedo, simulation)
        @test fig isa Chiaroscuro.Makie.Figure
    end

    @testset "any AbstractAlbedo" begin
        # evaluate and heatmap also work with SpeedyWeather's default albedo
        default_model = PrimitiveWetModel(spectral_grid)
        default_simulation = initialize!(default_model)
        run!(default_simulation, period = Day(1))
        evaluation = evaluate(default_model.albedo, default_simulation)
        @test isfinite(evaluation.score)
        fig = Chiaroscuro.Makie.heatmap(default_model.albedo, default_simulation)
        @test fig isa Chiaroscuro.Makie.Figure
    end
end
