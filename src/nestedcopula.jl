# nested copulas
# Algorithms from M. Hofert, `Efficiently sampling nested Archimedean copulas`
# Computational Statistics and Data Analysis 55 (2011) 57–70

"""
  nestedcopula(t::Int, n::Vector{Int}, ϕ::Vector{Float64}, θ::Float64, m::Int = 0)

Returns Matrix{Float} of t realisations of sum(n)+m random variables generated using
nested archimedean copula, outer copula parameter is θ, inner i'th copulas parameter is
ϕ[i] and size is n[i]. If m ≠ 0, last m variables are from outer copula only, see Alg. 5
McNeil, A.J., 2008. 'Sampling nested Archimedean copulas'. Journal of Statistical
 Computation and Simulation 78, 567–581.
"""


nestedarchcopulagen(copula::String, t::Int, n::Vector{Int}, ϕ::Vector{Float64}, θ::Float64, m::Int = 0) =
  nestedcopulag(copula, t, n, ϕ, θ, rand(t, sum(n)+m+1))

  """
    nestedcopulag(copula::String, t::Int, n::Vector{Int}, ϕ::Vector{Float64}, θ::Float64, r::Matrix{Float64})

  Returns t realisations of ∑ᵢ nᵢ variate data of nested archimedean copula
  C_θ(C_Φ₁(u₁₁, ..., u₁,ₙ₁), C_θ(C_Φₖ(uₖ₁, ..., uₖ,ₙₖ)) where k = length(n).

  M. Hofert, 'Sampling  Archimedean copulas', Computational Statistics & Data Analysis, Volume 52, 2008
  """

function nestedcopulag(copula::String, t::Int, n::Vector{Int}, ϕ::Vector{Float64}, θ::Float64, r::Matrix{Float64})
  testnestedpars(θ, ϕ, n)
  V0 = getV0(θ, r[:,end], copula)
  X = nestedstep(copula, r[:,1:n[1]], rand(t), V0, ϕ[1], θ)
  cn = cumsum(n)
  for i in 2:length(n)
    u = r[:,cn[i-1]+1:cn[i]]
    X = hcat(X, nestedstep(copula, u, rand(t), V0, ϕ[i], θ))
  end
  X = hcat(X, r[:,sum(n)+1:end-1])
  phi(-log.(X)./V0, θ, copula)
end


"""
  testnestedpars(θ::Float64, ϕ::Vector{Float64}, n::Vector{Int})

Tests the hierarchy of parameters for the nested archimedean copula where both parent and
childs are from the same family
"""

function testnestedpars(θ::Float64, ϕ::Vector{Float64}, n::Vector{Int})
  θ <= minimum(ϕ) || throw(AssertionError("wrong heirarchy of parameters"))
  length(n) == length(ϕ) || throw(AssertionError("number of subcopulas ≠ number of parameters"))
end

function nestedstep(copula::String, u::Matrix{Float64}, v::Vector{Float64},
                                                        V0::Union{Vector{Float64}, Vector{Int}},
                                                        ϕ::Float64, θ::Float64)
  if copula == "amh"
    t = length(V0)
    w = [quantile(NegativeBinomial(V0[i], (1-ϕ)/(1-θ)), v[i]) for i in 1:t]
    u = -log.(u)./(V0 + w)
    X = ((exp.(u)-ϕ)*(1-θ)+θ*(1-ϕ))/(1-ϕ)
    return X.^(-V0)
  elseif copula == "frank"
    u = -log.(u)./nestedfrankgen(ϕ, θ, V0)
    X = (1-(1-exp.(-u)*(1-exp(-ϕ))).^(θ/ϕ))./(1-exp(-θ))
    return X.^V0
  elseif copula == "clayton"
    u = -log.(u)./tiltedlevygen(V0, ϕ/θ)
    return exp.(V0.-V0.*(1.+u).^(θ/ϕ))
  elseif copula == "gumbel"
    u = -log.(u)./levygen(ϕ/θ, v)
    return exp.(-u.^(θ/ϕ))
  end
  u
end

"""
  nestedgumbelcopulat::Int, n::Vector{Vector{Int}}, Ψ::Vector{Vector{Float64}}, Φ::Vector{Float64}, θ₀::Float64)

Returns t realisations of ∑ᵢ ∑ⱼ nᵢⱼ variate data of double nested Gumbel copula.
C_θ(C_Φ₁(C_Ψ₁₁(u,...), ..., C_C_Ψ₁,ₗ₁(u...)), ..., C_Φₖ(C_Ψₖ₁(u,...), ..., C_Ψₖ,ₗₖ(u,...)))
 where lᵢ = length(n[i])

"""


function nestedgumbelcopula(t::Int, n::Vector{Vector{Int}}, Ψ::Vector{Vector{Float64}}, Φ::Vector{Float64}, θ::Float64)
  θ <= minimum(Φ) || throw(AssertionError("wrong heirarchy of parameters"))
  X = nestedarchcopulagen("gumbel", t, n[1], Ψ[1], Φ[1]./θ)
  for i in 2:length(n)
    X = hcat(X, nestedarchcopulagen("gumbel", t, n[i], Ψ[i], Φ[i]./θ))
  end
  phi(-log.(X)./levygen(θ, rand(t)), θ, "gumbel")
end


"""
  nestedgumbelcopula(t::Int, θ::Vector{Float64})

Returns t realisations of length(θ)+1 variate data of (hierarchically) nested Gumbel copula.
C_θₙ(... C_θ₂(C_θ₁(u₁, u₂), u₃)...,  uₙ)
"""

function nestedgumbelcopula(t::Int, θ::Vector{Float64})
  issorted(θ; rev=true) || throw(AssertionError("wrong heirarchy of parameters"))
  hiergcopulagen(rand(t, 2*length(θ)+1), θ)
end

"""
  hiergcopulagen(r::Matrix{Float}, θ::Vector{Float64})

Auxiliary function used to generate data from nested (hiererchical) gumbel copula
parametrised by a single parameter θ given a matrix of independent [0,1] distributerd
random vectors.

"""

function hiergcopulagen(r::Matrix{T}, θ::Vector{Float64}) where T <:AbstractFloat
  n = length(θ)+1
  u = r[:,1:n]
  v = r[:,n+1:end]
  θ = vcat(θ, [1.])
  X = copulagen("gumbel", hcat(u[:,1:2], v[:,1]), θ[1]/θ[2])
  for i in 2:(n-1)
    X = hcat(X, u[:,i+1])
    X = -log.(X)./levygen(θ[i]/θ[i+1], v[:,i])
    X = exp.(-X.^(θ[i+1]/θ[i]))
  end
  X
end

"""
  nestedfrechetcopulagen(t::Int, α::Vector{Float64}, β::Vector{Float64})

Retenares data from nested hierarchical frechet copula
"""
function nestedfrechetcopulagen(t::Int, α::Vector{Float64}, β::Vector{Float64} = zeros(α))
  α = vcat([0.], α)
  β = vcat([0.], β)
  n = length(α)
  u = rand(t, n)
  p = invperm(sortperm(u[:,1]))
  l = floor.(Int, t.*α)
  lb = floor.(Int, t.*β)
  for i in 2:n
    u[1:l[i],i] = u[1:l[i], i-1]
    r = l[i]+1:lb[i]+l[i]
    u[r,i] = 1-u[r,i-1]
  end
  u[p,:]
end

# copula mix

function copulamix(t::Int, Σ::Matrix{Float64}, inds::Vector{Pair{String,Vector{Int64}}},
                                                λ::Vector{Float64} = [0.8, 0.1],
                                                ν::Int = 10)
  x = transpose(rand(MvNormal(Σ),t))
  xgauss = copy(x)
  x = cdf(Normal(0,1), x)
  for p in inds
    ind = p[2]
    v = norm2unifind(xgauss, Σ, makeind(Σ, p))
    if p[1] == "Marshal-Olkin"
      map = collect(combinations(1:length(ind),2))
      ρ = [Σ[ind[k[1]], ind[k[2]]] for k in map]
      x[:,ind] = mocopula(v, length(ind), τ2λ(ρ, λ))
    elseif (p[1] == "gumbel") & (length(ind) > 2)
      θ = [ρ2θ(Σ[ind[i], ind[i+1]], p[1]) for i in 1:(length(ind)-1)]
      x[:,ind] = hiergcopulagen(v, sort(θ; rev = true))
    elseif p[1] == "t-student"
      g2tsubcopula!(x, Σ, ind, ν)
    else
      θ = ρ2θ(Σ[ind[1], ind[2]], p[1])
      x[:,ind] = copulagen(p[1], v, θ)
    end
  end
  x
end

"""
  makeind(Σ::Matrix{Float64}, ind::Pair{String,Vector{Int64}})

Returns multiindex hcat(ind[2], [j₁, ..., jₖ]) where js are such that maximise Σ[ind[2] [i], js]
k is determined by the copula type ind[1] and length(ind[2])
"""

function makeind(Σ::Matrix{Float64}, ind::Pair{String,Vector{Int64}})
  l = length(ind[2])
  i = ind[2]
  lim = l+1
  if ind[1] =="Marshal-Olkin"
    lim = 2^l-1
  elseif ind[1] =="gumbel"
    lim = 2*l-1
  end
  for p in 0:(lim-l-1)
    k = p%l+1
    i = vcat(i, find(Σ[:, k].== maximum(Σ[setdiff(collect(1:size(Σ, 2)),i),k])))
  end
  i
end

"""
  norm2unifind(x::Matrix{Float64}, Σ::Matrix{Float64}, i::Vector{Int})

Given normaly distributed data x with correlation matrix Σ returns
independent uniformly distributed data based on marginals of x indexed by a given
multiindex i.
"""

function norm2unifind(x::Matrix{Float64}, Σ::Matrix{Float64}, i::Vector{Int})
  a, s = eig(Σ[i,i])
  w = x[:, i]*s./transpose(sqrt.(a))
  w[:, end] = sign(cov(x[:, i[1]], w[:, end]))*w[:, end]
  cdf(Normal(0,1), w)
end
