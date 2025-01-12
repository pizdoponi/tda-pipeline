# TDA pipeline

This is a project for the Topological Data Analysis course.

The project is broken down into the following files:

- [pipeline](main.jl): main entrypoint file containing the whole pipeline.
- [load data](read_and_edit_data.jl): prepare the data.
- [fitration](filtration.jl): BFS fitration based on geodesic distance.
- [vectorization](persistent_landscapes.jl): construct vectors from persistent homology.
