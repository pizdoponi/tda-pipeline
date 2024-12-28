using Random
using Plots
using LinearAlgebra

function generate_perpendicular_cylinders(num_points = 4000, num_end_points = 500, inner_radius = 1.75, outer_radius = 2.0, height = 40.0, threshold = 0.1)
    function generate_cylinder(num_points, inner_radius, outer_radius, height, orientation)
        points = zeros(Float64, num_points + 2 * num_end_points, 3)  # +2*num_end_points for the top and bottom surfaces

        for i in 1:num_points
            θ = 2π * rand()  # Random angle around the circle
            r = rand() * (outer_radius - inner_radius) + inner_radius # Random radius in the hollow range
    
            if orientation == :vertical
                z = height * (rand() - 0.5)  # Uniformly distributed along the height
                x = r * cos(θ)
                y = r * sin(θ)
                points[i, :] = [x, y, z]
    
            elseif orientation == :horizontal
                θ = 2π * rand()  # Random angle around the circle
                r = rand() * (outer_radius - inner_radius) + inner_radius # Random radius in the hollow range
                y = height * (rand() - 0.5)  # Uniformly distributed along the height
                z = r * cos(θ)
                x = r * sin(θ)
                points[i, :] = [x, y, z]
    
            elseif orientation == :perpendicular
                θ = 2π * rand()  # Random angle around the circle
                r = rand() * (outer_radius - inner_radius) + inner_radius # Random radius in the hollow range
                x = height * (rand() - 0.5)  # Uniformly distributed along the height
                z = r * cos(θ)
                y = r * sin(θ)
                points[i, :] = [x, y, z]
            end
        end
    
        # Add points for the top and bottom surfaces
        for j in 1:num_end_points
            θ = 2π * rand()  # Random angle around the circle
            r = rand() * outer_radius  # Random radius within the outer edge

            if orientation == :vertical
                x = r * cos(θ)
                y = r * sin(θ)
                points[num_points + j, :] = [x, y, height / 2]  # Top surface
                points[num_points + num_end_points + j, :] = [x, y, -height / 2]  # Bottom surface

            elseif orientation == :horizontal
                z = r * cos(θ)
                x = r * sin(θ)
                points[num_points + j, :] = [x, height / 2, z]  # Top surface
                points[num_points + num_end_points + j, :] = [x, -height / 2, z]  # Bottom surface

            elseif orientation == :perpendicular
                z = r * cos(θ)
                y = r * sin(θ)
                points[num_points + j, :] = [height / 2, y, z]  # Top surface
                points[num_points + num_end_points + j, :] = [-height / 2, y, z]  # Bottom surface
            end
        end
    
        return points   
    end

    function filter_intersecting_points(points1, points2, points3, threshold)
        filtered_points1 = Vector{Vector{Float64}}()
        filtered_points2 = Vector{Vector{Float64}}()
        filtered_points3 = Vector{Vector{Float64}}()

        for p1 in eachrow(points1)
            intersecting = false
            for p2 in eachrow(points2)
                if norm(p1 - p2) < threshold
                    intersecting = true
                    break
                end
            end
            for p3 in eachrow(points3)
                if norm(p1 - p3) < threshold
                    intersecting = true
                    break
                end
            end
            if !intersecting
                push!(filtered_points1, collect(p1))
            end
        end

        for p2 in eachrow(points2)
            intersecting = false
            for p1 in eachrow(points1)
                if norm(p2 - p1) < threshold
                    intersecting = true
                    break
                end
            end
            for p3 in eachrow(points3)
                if norm(p2 - p3) < threshold
                    intersecting = true
                    break
                end
            end
            if !intersecting
                push!(filtered_points2, collect(p2))
            end
        end

        for p3 in eachrow(points3)
            intersecting = false
            for p1 in eachrow(points1)
                if norm(p3 - p1) < threshold
                    intersecting = true
                    break
                end
            end
            for p2 in eachrow(points2)
                if norm(p3 - p2) < threshold
                    intersecting = true
                    break
                end
            end
            if !intersecting
                push!(filtered_points3, collect(p3))
            end
        end

        return vcat(filtered_points1, filtered_points2, filtered_points3)
    end

        # return vcat(filtered_points1, filtered_points2)

    cylinder1 = generate_cylinder(num_points, inner_radius, outer_radius, height, :vertical)
    cylinder2 = generate_cylinder(num_points, inner_radius, outer_radius, height, :horizontal)
    cylinder3 = generate_cylinder(num_points, inner_radius, outer_radius, height, :perpendicular)

    pointcloud = filter_intersecting_points(cylinder1, cylinder2, cylinder3, threshold)

    x = []
    y = []
    z = []
    for p in eachrow(pointcloud)
        push!(x, p[1][1])
        push!(y, p[1][2])
        push!(z, p[1][3])
    end

    return [x y z]

end

pointcloud=generate_perpendicular_cylinders()
scatter(pointcloud[:, 1], pointcloud[:, 2], pointcloud[:, 3], markersize=2, legend=false)