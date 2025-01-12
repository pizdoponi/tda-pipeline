verbose = false

# ╭──────────────────────────────────────────────────────────╮
# │                        load data                         │
# ╰──────────────────────────────────────────────────────────╯

using Statistics
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
    if verbose
        println("$i: Computed persistent homology for country $(country_labels[i])")
    end
end

# ── visualize sampled points ──────────────────────────────────────────

num_sampled_points = 20
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

plot(barcodes..., layout=(4, 5), titlefontsize=6, legendfontsize=4, xlabel="", xtickfont=font(6))


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
    if verbose
        println("$i: Vectorizing homology for country: $(country_labels[i])")
    end
    persistent_homology = persistent_homologies[i]
    vectorized_homology = vectorize_persistent_homology_using_persistent_landscapes(persistent_homology, min_num_persistence_intervals_in_H1, 20)
    push!(vectors, vectorized_homology)
end

# ╭──────────────────────────────────────────────────────────╮
# │                        clustering                        │
# ╰──────────────────────────────────────────────────────────╯

using MLJ
using Distances
import Clustering: dbscan
using Statistics

dist_matrix = pairwise(CosineDist(), hcat(vectors...))


# normalize the distance matrix
dist_matrix = dist_matrix ./ maximum(dist_matrix)
dist_matrix = dist_matrix .+ 1e-6


labels = dbscan(dist_matrix, 0.05, min_neighbors=5; metric=nothing, min_cluster_size=5)

country_to_label = Dict{String,Int}()
for i in 1:length(country_labels)
    country_to_label[country_labels[i]] = labels.assignments[i]
end
label_to_country = Dict{Int,String}()
for (country, label) in country_to_label
    label_to_country[label] = country
end

# ╭──────────────────────────────────────────────────────────╮
# │                      visualization                       │
# ╰──────────────────────────────────────────────────────────╯

using TSne
using Plots

tsne_result = tsne(dist_matrix, 2, 0, 1000, 30.0, distance=true)
x_coords, y_coords = tsne_result[:, 1], tsne_result[:, 2]

numerical_labels = labels.assignments;

# Optional: Handle noise points (label `-1`)
numerical_labels[numerical_labels.==-1] .= maximum(numerical_labels) + 1

scatter(x_coords, y_coords, color=numerical_labels, legend=false, title="t-SNE Visualization of Clusters", dpi=1000)

function label_points_plot()
    scatter(x_coords, y_coords, color=numerical_labels, legend=false, title="t-SNE Visualization of Clusters", markersize=1, markerstrokewidth=0, dpi=1000)

    for i in 1:length(country_labels)
        annotate!(x_coords[i], y_coords[i] - 2, text(country_labels[i], :black, 3))
    end

    savefig("tsne_result.png")
end

# show plot

# ╭──────────────────────────────────────────────────────────╮
# │                     save the objects                     │
# ╰──────────────────────────────────────────────────────────╯
using Serialization
using Dates

current_time = Dates.now()
data_folder = "data/" * string(current_time) * "/"
mkdir(data_folder)

savefig(data_folder * "tsne_.png")
serialize(data_folder * "country_to_label.bin", country_to_label)
serialize(data_folder * "tsne_result.bin", tsne_result)
serialize(data_folder * "dist_matrix.bin", dist_matrix)

serialize("data/" * "persistent_homologies.bin", persistent_homologies)
serialize("data/" * "barcodes.bin", barcodes)


# get one country from each cluster
chosen_phs = []
already_chosen_labels = []
chosen_indices = []
for i in 1:length(country_labels)
    if !(labels.assignments[i] in already_chosen_labels)
        push!(chosen_phs, persistent_homologies[i])
        push!(already_chosen_labels, labels.assignments[i])
        push!(chosen_indices, i)
    end
end

chosen_barcodes = []
for i in 1:length(chosen_phs)
    ph = chosen_phs[i]
    b = barcode(ph)
    push!(chosen_barcodes, b)
end

label_to_color = Dict{Int,String}()
label_to_color[1] = "green"
label_to_color[2] = "blue"
label_to_color[3] = "orange"
label_to_color[4] = "navy"

chosen_barcodes_with_metadata = []
for i in 1:length(chosen_barcodes)
    color = label_to_color[i]
    country = country_labels[chosen_indices[i]]
    barcode_plot = plot(chosen_barcodes[i],
        linecolor=color,
        title=country,
        titlefontsize=8,
        titlefont=(8, color),
        legend=false,
        xlabel="")  # Disable legend for individual plots
    push!(chosen_barcodes_with_metadata, barcode_plot)
end

# Arrange the barcode plots in a grid layout
final_plot = plot(chosen_barcodes_with_metadata...,
    layout=(2, 2),
    titlefontsize=10,
    legend=false)

display(final_plot)

# plot(chosen_barcodes..., layout=(2, 2), titlefontsize=6, legendfontsize=4, xlabel="", xtickfont=font(6))
