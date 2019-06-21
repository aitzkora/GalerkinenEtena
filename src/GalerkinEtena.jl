module GalerkinEtena

using LinearAlgebra
using SpecialFunctions
using Revise
using Test

struct QuadratureFormula
    points::Array{Float64}
    weights::Array{Float64}
end

export vander, GLT, JacobiGQ, JacobiGL, integrate, JacobiP, lagrange, Legendre, computeElementaryMatrices, Mesh1D

include("mesh.jl")
include("integrate.jl")
include("assemble.jl")

end # module
