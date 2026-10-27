using SpeedyWeather
using Chiaroscuro
using Documenter
using Printf

DocMeta.setdocmeta!(Chiaroscuro, :DocTestSetup, :(using Chiaroscuro); recursive = true)

# READ ALL SUBMISSIONS CODE
submissions = filter(x -> endswith(x, ".jl"), readdir(joinpath(@__DIR__, "../submissions")))
sort!(submissions)  # alphabetical order

# RUN SUBMISSIONS
# each submission is included into its own anonymous module so that
# variables (name, description, albedo) don't leak between submissions
function run_submission(path::String)
    submission = Module()
    Base.include(submission, path)

    # TODO: adapt to the final interface of ChiaroscuroAlbedo and evaluate in src/
    albedo = Chiaroscuro.ChiaroscuroAlbedo(submission.albedo)
    evaluation = Chiaroscuro.evaluate(albedo)

    return Dict(
        :author => submission.name,
        :description => submission.description,
        :evaluation => evaluation,
        :score => evaluation,   # TODO: extract the scalar score if evaluate returns a struct
        :path => path,
        :code => read(path, String),
        :rank => 0,
    )
end

# only evaluate submissions once ChiaroscuroAlbedo and evaluate are implemented in src/
run_submissions = isdefined(Chiaroscuro, :ChiaroscuroAlbedo) && isdefined(Chiaroscuro, :evaluate)
run_submissions || @warn "Chiaroscuro.ChiaroscuroAlbedo/evaluate not defined yet, skipping submissions."

# dictionary of dictionaries to evaluate all submissions
all_submissions = Dict{String, Dict}()

if run_submissions
    for submission in submissions
        @info "Running submission $submission"
        name = split(submission, ".jl")[1]
        path = joinpath(@__DIR__, "..", "submissions", submission)
        all_submissions[name] = run_submission(path)
    end
end

# rank submissions by score, highest first (TODO: flip if lower is better)
all_names_ranked = sort(collect(keys(all_submissions)), by = name -> all_submissions[name][:score], rev = true)
for (i, name) in enumerate(all_names_ranked)
    all_submissions[name][:rank] = i
end
nsubmissions = length(all_names_ranked)

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

        # show evaluation
        println(mdfile, "Evaluation:")
        println(mdfile, "```julia")
        println(mdfile, dict[:evaluation])
        println(mdfile, "```")

        # TODO: add a plot of the albedo map / simulated climate per submission
    end
end

# GENERATE LEADERBOARD
@info "Building leaderboard.md"
open(joinpath(@__DIR__, "src/leaderboard.md"), "w") do mdfile
    header = read(joinpath(@__DIR__, "headers/leaderboard_header.md"), String)
    println(mdfile, header)

    for name in all_names_ranked
        dict = all_submissions[name]
        score = dict[:score]
        score_str = score isa Real ? @sprintf("%.4g", score) : string(score)
        println(mdfile, "| $(dict[:rank]) | $(dict[:author]) | $(dict[:description]) | $score_str |")

        # also print into the docs build report
        @info "$name: rank = $(dict[:rank]), score = $score_str"
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
