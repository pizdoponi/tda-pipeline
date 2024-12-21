using PersistenceDiagrams

function calculate_persistent_landscapes(diagram::PersistenceDiagram, num_landscapes::Int; resolution=1000)
    num_intervals = length(diagram)
    @assert num_intervals >= num_landscapes "Number of intervals in diag is less than n."

    intervals = [(d.birth, d.death) for d in diagram]

    # determine the global min birth and max death for the sampling range
    bmin = minimum(i -> i[1], intervals)
    dmax = maximum(i -> i[2], intervals)
    x_values = range(bmin, dmax, length=resolution)

    piecewise_functions = [x -> max(0, min(x - b, d - x)) for (b, d) in intervals]

    # function_values[i, :] are the function values at x_values[i] for all intervals
    # function_values[:, j] are the function values for all x_values for the j-th interval
    function_values = Matrix{Float64}(undef, resolution, num_intervals)
    @inbounds for j in 1:num_intervals
        f = piecewise_functions[j]
        for i in 1:resolution
            function_values[i, j] = f(x_values[i])
        end
    end

    # L[i, :] are the top-n function values at x_values[i]
    # L[:, k] are the top-n function values for all x_values for the k-th landscape
    # in other words, L[:, k] is the k-th landscape]
    L = Matrix{Float64}(undef, resolution, num_landscapes)

    @inbounds for i in 1:resolution
        # make a copy of the i-th row so that partialsort! can mutate it
        function_values_copy = copy(function_values[i, :])
        max_k_function_values = partialsort!(function_values_copy, 1:num_landscapes, rev=true)
        # write the top-n values into L[i, :]
        for k in 1:num_landscapes
            L[i, k] = max_k_function_values[k]
        end
    end

    return L, x_values
end
