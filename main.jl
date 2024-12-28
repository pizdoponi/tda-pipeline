# ╭──────────────────────────────────────────────────────────╮
# │                        load data                         │
# ╰──────────────────────────────────────────────────────────╯

include("read_and_edit_data.jl")

data_matrix, country_labels, g = get_data()

# ╭──────────────────────────────────────────────────────────╮
# │                        filtration                        │
# ╰──────────────────────────────────────────────────────────╯

using Random
using Plots
using Ripserer

include("filtration.jl")

barcodes = []
persistent_diagrams = []

num_sampled_points = 6
sampled_points = []

for i in 1:num_sampled_points
    push!(sampled_points, rand(1:nv(g)))
end

for i in 1:6

    sampled_point = sampled_points[i]

    filtration = create_filtration(g, sampled_point)
    K = Custom(collect(filtration))
    ph = ripserer(K)

    for el in ph
        println(el)
    end

    # ph = ripserer(K, alg = :homology, field = Rational{Int64}, dim_max = 2)
    # open("ripserer_result_$i.jls", "w") do file
    #     serialize(file, ph)
    # end

    country_name = country_labels[sampled_point]
    b = barcode(ph)
    title!("$country_name")

    push!(barcodes, b)
    push!(persistent_diagrams, ph)

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

for i in 1:6
    println("Vectorizing homology $i at index $(sampled_points[i]), country: $(country_labels[sampled_points[i]])")
    persistent_homology = persistent_diagrams[i]
    vectorized_homology = vectorize_persistent_homology_using_persistent_landscapes(persistent_homology, 2)
    push!(vectors, vectorized_homology)
end

# ╭──────────────────────────────────────────────────────────╮
# │                        clustering                        │
# ╰──────────────────────────────────────────────────────────╯

using MLJ
