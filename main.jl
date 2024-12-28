using Random
using Plots
using Ripserer

include("read_and_edit_data.jl")
include("filtration.jl")

data_matrix, country_labels, g = get_data()

bs = []

for i in 1:6

    current_start = rand(1:nv(g))

    filtration = create_filtration(g, current_start)
    K = Custom(collect(filtration))
    ph = ripserer(K)

    for el in ph
        println(el)
    end

    # ph = ripserer(K, alg = :homology, field = Rational{Int64}, dim_max = 2)
    # open("ripserer_result_$i.jls", "w") do file
    #     serialize(file, ph)
    # end

    country_name = country_labels[current_start]
    b = barcode(ph)

    title!("$country_name")
    push!(bs, b)
    
end

plot(bs[1], bs[2], bs[3], bs[4], bs[5], bs[6], layout=(3, 2))  # 3 rows, 2 columns
