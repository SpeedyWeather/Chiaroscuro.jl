using SpeedyWeather
using Chiaroscuro
using Documenter
using Printf
using GLMakie

DocMeta.setdocmeta!(Chiaroscuro, :DocTestSetup, :(using Chiaroscuro); recursive = true)

# SIMULATION SETUP, identical for all submissions
const TRUNCATION = 32
const NLAYERS = 8
const PERIOD = Day(30)

# the scores returned by evaluate, first one is the total score used for ranking
const SCORES = (:score, :land_score, :ocean_score, :tropical_score, :polar_score)

# READ ALL SUBMISSIONS CODE
submissions = filter(x -> endswith(x, ".jl"), readdir(joinpath(@__DIR__, "../submissions")))
sort!(submissions)  # alphabetical order

function run_simulation(albedo_function)
    spectral_grid = SpectralGrid(truncation = TRUNCATION, nlayers = NLAYERS)
    albedo = ChiaroscuroAlbedo(albedo_function)
    model = PrimitiveWetModel(spectral_grid; albedo)
    simulation = initialize!(model)
    run!(simulation, period = PERIOD)
    return albedo, simulation
end

function run_and_evaluate(albedo_function)
    albedo, simulation = run_simulation(albedo_function)
    evaluation = evaluate(albedo, simulation)
    figure = globe(albedo, simulation)
    return evaluation, figure
end

# RUN SUBMISSIONS
# each submission is included into its own anonymous module so that
# variables (name, description, albedo) don't leak between submissions
function run_submission(path::String)
    submission = Module()
    Base.include(submission, path)

    # invokelatest as the submission's definitions are newer than this function's world age
    get(variable) = Base.invokelatest(getproperty, submission, variable)

    dict = Dict{Symbol, Any}(
        :author => get(:name),
        :description => get(:description),
        :path => path,
        :code => read(path, String),
        :rank => 0,
        :error => nothing,
    )

    # a failing submission shouldn't fail the whole docs build, rank it last instead
    try
        evaluation, figure = Base.invokelatest(run_and_evaluate, get(:albedo))
        dict[:evaluation] = evaluation
        dict[:figure] = figure
        for s in SCORES
            dict[s] = getproperty(evaluation, s)
        end
    catch e
        @warn "Submission $path failed" exception = (e, catch_backtrace())
        dict[:error] = sprint(showerror, e)
        for s in SCORES
            dict[s] = Inf
        end
    end
    return dict
end

# dictionary of dictionaries to evaluate all submissions
all_submissions = Dict{String, Dict}()

for submission in submissions
    @info "Running submission $submission"
    name = split(submission, ".jl")[1]
    path = joinpath(@__DIR__, "..", "submissions", submission)
    all_submissions[name] = run_submission(path)
end

# rank submissions by score (an RMSE), lowest first
all_names_ranked = sort(collect(keys(all_submissions)), by = name -> all_submissions[name][:score])
for (i, name) in enumerate(all_names_ranked)
    all_submissions[name][:rank] = i
end
nsubmissions = length(all_names_ranked)

format_score(x) = isfinite(x) ? @sprintf("%.3f", x) : "failed"

# GENERATE SUBMISSIONS LIST
@info "Building submissions.md"
open(joinpath(@__DIR__, "src/submissions.md"), "w") do mdfile
    header = read(joinpath(@__DIR__, "headers/submissions_header.md"), String)
    println(mdfile, header)

    for name in all_names_ranked
        dict = all_submissions[name]
        println(mdfile, "## $(dict[:author]): $(dict[:description])\n")
        println(mdfile, "path: `/submissions/$name.jl`\n")
        println(mdfile, "rank: $(dict[:rank]). of $nsubmissions submissions\n")

        # show code
        println(mdfile, "```julia")
        println(mdfile, dict[:code])
        println(mdfile, "```")

        if isnothing(dict[:error])
            # show evaluation
            println(mdfile, "Evaluation:")
            println(mdfile, "```julia")
            println(mdfile, dict[:evaluation])
            println(mdfile, "```")

            # albedo on the last time step
            name_without_spaces = replace(name, " " => "_")
            path = joinpath(@__DIR__, "src", "submission_$name_without_spaces.png")
            @info "Saving figure to $path"
            save(path, dict[:figure])
            println(mdfile, "![submission: $name](submission_$name_without_spaces.png)\n")
        else
            println(mdfile, "This submission failed with\n")
            println(mdfile, "```")
            println(mdfile, dict[:error])
            println(mdfile, "```\n")
        end
    end
end

# GENERATE LEADERBOARD
@info "Building leaderboard.md"
open(joinpath(@__DIR__, "src/leaderboard.md"), "w") do mdfile
    header = read(joinpath(@__DIR__, "headers/leaderboard_header.md"), String)
    println(mdfile, header)

    for name in all_names_ranked
        dict = all_submissions[name]
        scores = join([format_score(dict[s]) for s in SCORES], " | ")
        println(mdfile, "| $(dict[:rank]) | $(dict[:author]) | $(dict[:description]) | $scores |")

        # also print into the docs build report
        @info "$name: rank = $(dict[:rank]), score = $(format_score(dict[:score]))"
    end
end

makedocs(;
    modules = [Chiaroscuro],
    authors = "Milan Klöwer <milankloewer@gmx.de> and contributors",
    sitename = "Chiaroscuro.jl",
    format = Documenter.HTML(;
        canonical = "https://speedyweather.github.io/Chiaroscuro.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "New to Julia?" => "new_to_julia.md",
        "Albedo" => "albedo.md",
        "Evaluation" => "evaluation.md",
        "Chiaroscuro challenge" => [
            "Instructions" => "instructions.md",
            "Submit" => "submit.md",
            "Leaderboard" => "leaderboard.md",
            "List of submissions" => "submissions.md",
        ],
        "Functions and types" => "functions_types.md",
    ],
    warnonly = [:missing_docs, :cross_references],
)

deploydocs(
    repo = "github.com/SpeedyWeather/Chiaroscuro.jl",
    devbranch = "main",
    push_preview = true,
    versions = ["stable" => "v^", "v#.#.#", "dev" => "dev"],
)
