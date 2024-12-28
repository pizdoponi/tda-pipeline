# ╭──────────────────────────────────────────────────────────╮
# │                        load data                         │
# ╰──────────────────────────────────────────────────────────╯

include("read_and_edit_data.jl")

data_matrix, country_labels, graph = get_data()

# ╭──────────────────────────────────────────────────────────╮
# │                        filtration                        │
# ╰──────────────────────────────────────────────────────────╯

using Random
using Plots
using Ripserer

include("filtration.jl")

persistent_homologies = []

for i in 1:length(country_labels)
    filtration = create_filtration(graph, i)
    K = Custom(collect(filtration))
    ph = ripserer(K)
    push!(persistent_homologies, ph)
    println("Computed persistent homology $i for country $(country_labels[i])")
end

# ── visualize sampled points ──────────────────────────────────────────

num_sampled_points = 6
sampled_points = []

for i in 1:num_sampled_points
    push!(sampled_points, rand(1:nv(graph)))
end

barcodes = []

for i in 1:num_sampled_points
    sampled_point = sampled_points[i]

    filtration = create_filtration(graph, sampled_point)
    K = Custom(collect(filtration))
    ph = ripserer(K)

    # for el in ph
    #     println(el)
    # end

    # ph = ripserer(K, alg = :homology, field = Rational{Int64}, dim_max = 2)
    # open("ripserer_result_$i.jls", "w") do file
    #     serialize(file, ph)
    # end

    country_name = country_labels[sampled_point]
    b = barcode(ph)
    title!("$country_name")

    push!(barcodes, b)

end

plot(barcodes[1], barcodes[2], barcodes[3], barcodes[4], barcodes[5], barcodes[6], layout=(3, 2))  # 3 rows, 2 columns


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

vectors::Vector{Vector{Float32}} = []

min_num_persistence_intervals_in_H1 = minimum([length(ph[2]) for ph in persistent_homologies])

for i in 1:length(country_labels)
    println("Vectorizing homology $i for country: $(country_labels[i])")
    persistent_homology = persistent_homologies[i]
    vectorized_homology = vectorize_persistent_homology_using_persistent_landscapes(persistent_homology, min_num_persistence_intervals_in_H1)
    push!(vectors, vectorized_homology)
end

# ╭──────────────────────────────────────────────────────────╮
# │                        clustering                        │
# ╰──────────────────────────────────────────────────────────╯

using MLJ
using Distances
import Clustering: dbscan

dist_matrix = pairwise(CosineDist(), hcat(vectors...))

# normalize the distance matrix
dist_matrix = dist_matrix ./ maximum(dist_matrix)
dist_matrix = dist_matrix .+ 1e-6


labels = dbscan(dist_matrix, 0.5, min_neighbors=5; metric=nothing, min_cluster_size=5)

# ╭──────────────────────────────────────────────────────────╮
# │                      visualization                       │
# ╰──────────────────────────────────────────────────────────╯

using TSne
using Plots

tsne_result = tsne(dist_matrix, 2, 0, 1000, 30.0, distance=true)
x_coords, y_coords = tsne_result[:, 1], tsne_result[:, 2]

numerical_labels = labels.assignments
# Optional: Handle noise points (label `-1`)
numerical_labels[numerical_labels .== -1] .= maximum(numerical_labels) + 1

scatter(x_coords, y_coords, color=numerical_labels, legend=false, title="t-SNE Visualization of Clusters")
