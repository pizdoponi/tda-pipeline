using CSV
using DataFrames
using LinearAlgebra
using LightGraphs

function get_data()

    data = CSV.read("./merged_data.csv", DataFrame)

    data = dropmissing(data)

    country_labels = data[:, 2]
    data = select(data, Not([1, 2]))

    data_matrix = Matrix(data)

    g = SimpleGraph(size(data, 1))

    # seems best after trying different values and looking at PCA
    threshold_distance = 0.25

    edges = []
    for i in 1:(size(data_matrix, 1) - 1)
        for j in (i+1):size(data_matrix, 1)
            if norm(data_matrix[i, :] .- data_matrix[j, :]) < threshold_distance
                push!(edges, (i, j))
            end
        end
    end

    for edge in edges
        add_edge!(g, edge[1], edge[2])
    end

    while !is_connected(g)
        min_dist = Inf
        closest_pair = (0, 0)
        for i in 1:(size(data_matrix, 1) - 1)
            for j in (i+1):size(data_matrix, 1)
                if !has_path(g, i, j) && norm(data_matrix[i, :] .- data_matrix[j, :]) < min_dist
                    min_dist = norm(data_matrix[i, :] .- data_matrix[j, :])
                    closest_pair = (i, j)
                end
            end
        end
        add_edge!(g, closest_pair[1], closest_pair[2])
    end

    return data_matrix, country_labels, g

end
