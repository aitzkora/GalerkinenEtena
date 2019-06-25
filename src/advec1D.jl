struct Advec1D
    Np::Int64
    K::Int64
    m::Mesh1D
    ξ::Array{Float64,1}
    x::Array{Float64,2}
    vmapM::Array{Int64,1}
    vmapP::Array{Int64,1}
    nx::Array{Float64,2}
    rx::Array{Float64,2}
    fScale::Array{Float64,2}
    lift::Array{Float64,2}

    function Advec1D(a::Float64, b::Float64, K::Int64, Np::Int64)
        K = K
        Np = Np
        m = Mesh1D(a, b,  K + 1)
        ξ = JacobiGL(0., 0., Np - 1)
        nx = [-ones(1, K); ones(1, K)];
        x, vmapM, vmapP = DGDiscretization(m, ξ)
        fmask = computeMask(ξ)
        # compute the metrics and Jacobian
        𝓥, 𝓓ᵣ = computeElementaryMatrices(ξ, Np - 1)
        J = 𝓓ᵣ * x
        rx = 1. ./ J
        fScale = 1. ./ J[fmask, :]

        # compute the lift
        Emat = zeros(Np, 2)
        Emat[1, 1] = 1.
        Emat[Np, 2] = 1.
        lift = 𝓥 * 𝓥' * Emat
        # create the object
        new(Np, K, m, ξ, x, vmapM, vmapP, nx, rx, fScale, lift)
    end
end


function rhs1D(ad::Advec1D, u::Array{Float64,2}, t::Float64, a::Float64, α::Float64)
    mapI = 1
    mapO = ad.K * 2
    vmapI = 1
    vmapO = ad.K * ad.Np

    # compute differential of u
    du = zeros(2, ad.K)
    du[:] = (u[ad.vmapM] - u[ad.vmapP]) .* (a * ad.nx[:] - (1 - α) * abs.(a .* ad.nx[:])) ./ 2.

    #impose boundary condition at x = 0
    uᵢₙ = -sin.(a .* t)
    du[mapI] = (u[vmapI] - uᵢₙ ) .* (a .* ad.nx[mapI] - ( 1 - α ) * abs.( a .* ad.nx[mapI])) ./ 2
    du[mapO] = 0

    rhs = -a * ad.rx .* (ad.𝓓ᵣ * u ) + ad.lift * (ad.fScale .* du)
    return rhs
end

