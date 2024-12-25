using PersistenceDiagrams

"""
    calculate_persistent_landscapes(diagram::PersistenceDiagram, num_landscapes::Int, resolution=1000)

Compute the first `num_landscapes` persistent landscapes from a persistence diagram.

# Arguments
- `diagram::PersistenceDiagram`: A persistent diagram object from `PersistenceDiagrams.jl`.
- `num_landscapes::Int`: The number of landscapes to compute.
- `resolution`: The number of points to sample the landscapes. Default is 100.
"""
function calculate_persistent_landscapes(diagram::PersistenceDiagram, num_landscapes::Int; resolution=100)::Tuple{Matrix{Float64}, StepRangeLen}
    num_intervals = length(diagram)
    @assert num_intervals >= num_landscapes "Number of intervals in diag is less than n."

    finite_upper_bound = 1e9
    intervals = [(d.birth, isfinite(d.death) ? d.death : finite_upper_bound) for d in diagram]

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


"""
    flatten_landscapes(persistent_landscapes::Matrix{Float64})

Flatten the matrix of persistent landscapes into a vector.
If the input matrix is of size `(n, m)`, the output vector will be of size `n * m`.
This retains all the information in the input matrix, but the output is a vector,
which is the desired format needed for machine learning (clustering).

# Arguments
- `persistent_landscapes::Matrix{Float64}`: A matrix of persistent landscapes.
  Obtained from `calculate_persistent_landscapes`.
"""
function flatten_landscapes(persistent_landscapes::Matrix{Float64})::Vector{Float64}
    n, m = size(persistent_landscapes)
    return reshape(persistent_landscapes, n * m)
end


"""
    aggregate_landscapes(persistent_landscapes::Matrix{Float64}, aggr::Union{"mean", "max"}="mean")

Aggregate the persistent landscapes into a single landscape,
using an aggregation method specified by `aggr`, either "mean" or "max".
The output is a vector of size `m`, where `m` is the number of landscapes in the input matrix.

# Arguments
- `persistent_landscapes::Matrix{Float64}`: A matrix of persistent landscapes.
  Obtained from `calculate_persistent_landscapes`.
- `aggr::Union{"mean", "max"}`: Aggregation method. Default is "mean".
"""
function aggregate_landscapes(persistent_landscapes::Matrix{Float64}, aggr::String="mean")::Vector{Float64}
    if aggr == "mean"
        return vec(mean(persistent_landscapes, dims=1))
    elseif aggr == "max"
        return vec(maximum(persistent_landscapes, dims=1))
    else
        throw(ArgumentError("Invalid aggregation method: $aggr"))
    end
end
