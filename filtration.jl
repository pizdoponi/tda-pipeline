using DataStructures

function create_filtration(g, starting_index)
    filtration = Dict{Tuple{Vararg{Int}}, Int}()

    for i in 1:nv(g)
        vertex = Tuple(i)
        filtration[vertex] = 0
    end

    visited = Set{Int}()
    queue = Deque{Int}()
    push!(queue, starting_index)
    parent = Dict{Int, Union{Nothing, Int}}(starting_index => nothing)  # Allow parent to be nothing or Int
    distance = Dict(starting_index => 0)
    push!(visited, starting_index)

    while !isempty(queue)
        current = popfirst!(queue)
        # for i in 1:size(points, 1)
        for neighbor in neighbors(g, current)
            if !(neighbor in visited)
                push!(visited, neighbor)
                push!(queue, neighbor)
                parent[neighbor] = current
                distance[neighbor] = distance[current] + 1
            end
        end
    end

    already_added = Set{Int}()

    sorted_pairs = sort(collect(distance), by=x -> x[2])

    for (vertex, dist) in sorted_pairs
        if vertex == starting_index
            continue
        end
        pair = Tuple([parent[vertex], vertex])
        filtration[pair] = distance[vertex]
        push!(already_added, vertex)

        vertex_neighbors = neighbors(g, vertex)
        for neighbor in vertex_neighbors
            if neighbor in already_added && neighbor != parent[vertex]
                pair = Tuple([vertex, neighbor])
                filtration[pair] = distance[vertex]
            end
        end

        for neighbor in vertex_neighbors
            if neighbor in already_added
            common_neighbors = intersect(Set(neighbors(g, vertex)), Set(neighbors(g, neighbor)))
            for common_neighbor in common_neighbors
                if common_neighbor in already_added
                clique = Tuple([vertex, neighbor, common_neighbor])
                filtration[clique] = distance[vertex]
                end
            end
            end
        end

    end

    return filtration

end

