# ╭──────────────────────────────────────────────────────────╮
# │                        load data                         │
# ╰──────────────────────────────────────────────────────────╯

include("load_data.jl")

data = load_data("");

# TODO: make the pipeline work for more point clouds, not just one
# (the original whole data)
point_clouds::Vector{Vector{Float32}} = []
for i in 1:5:size(data, 1)
    push!(point_clouds, data[i:min(i + 4, size(data, 1)), :])
end

# ╭──────────────────────────────────────────────────────────╮
# │                        filtration                        │
# ╰──────────────────────────────────────────────────────────╯

# ── rips ──────────────────────────────────────────────────────────────

using Ripserer
using Distances

dist_matrix = pairwise(Euclidean(), data, data, dims=1);
filtration = Ripserer.ripserer(dist_matrix);

diag0 = filtration[1];
diag1 = filtration[2];

using Plots

plot(diag0)
plot!(diag1)
title!("Filtration")

# ── geodesic ──────────────────────────────────────────────────────────
# TODO: @rok implement this

# ╭──────────────────────────────────────────────────────────╮
# │                    persistent diagram                    │
# ╰──────────────────────────────────────────────────────────╯

using PersistenceDiagrams

pd1 = PersistenceDiagram(diag0)

# ╭──────────────────────────────────────────────────────────╮
# │                      vectorization                       │
# ╰──────────────────────────────────────────────────────────╯

# ── images ────────────────────────────────────────────────────────────

# image = PersistenceDiagrams.PersistenceImage(filtration)
#
# m1 = image(diag0)
# m2 = image(diag1)

# ── landscapes ────────────────────────────────────────────────────────

include("persistent_landscapes.jl")

landscapes, xs = calculate_persistent_landscapes(pd1, 10)
landscape_vectors = flatten_landscapes(landscapes)

# ╭──────────────────────────────────────────────────────────╮
# │                        clustering                        │
# ╰──────────────────────────────────────────────────────────╯

using MLJ

