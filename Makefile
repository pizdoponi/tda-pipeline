nb:
	jupytext --from jl --to ipynb --output main.ipynb -- main.jl

jl:
	jupytext --from ipynb --to jl --output main.jl -- main.ipynb
