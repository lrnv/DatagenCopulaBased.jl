# nested archimedean copulas

# Algorithms from:
# M. Hofert, `Efficiently sampling nested Archimedean copulas` Computational Statistics and Data Analysis 55 (2011) 57–70
# M. Hofert, 'Sampling  Archimedean copulas', Computational Statistics & Data Analysis, Volume 52, 2008
# McNeil, A.J., 2008. 'Sampling nested Archimedean copulas'. Journal of Statistical Computation and Simulation 78, 567–581.

#Basically we use Alg. 5 of McNeil, A.J., 2008. 'Sampling nested Archimedean copulas'.

"""
    Nested_Clayton_cop

Fields:
- children::Vector{Clayton_cop}  vector of children copulas
- m::Int ≧ 0 - number of additional marginals modeled by the parent copula only
- θ::Real - parameter of parent copula, domain θ > 0.

Nested Clayton copula: C_θ(C_ϕ₁(u₁₁, ..., u₁,ₙ₁), ..., C_ϕₖ(uₖ₁, ..., uₖ,ₙₖ), u₁ , ... uₘ).
If m > 0, the last m variables will be modeled by the parent copula only.

Constructor

    Nested_Clayton_cop(children::Vector{Clayton_cop}, m::Int, θ::Real)

Let ϕ be the vector of parameter of children copula, sufficient nesting condition requires
θ <= minimum(ϕ)

Constructor

    Nested_Clayton_cop(children::Vector{Clayton_cop}, m::Int, θ::Real, cor::Type{<:CorrelationType})

For computing copula parameter from expected correlation use empty type cor::Type{<:CorrelationType} where
SpearmanCorrelation <:CorrelationType and KendallCorrelation<:CorrelationType. If used cor put expected correlation in the place of θ  in the constructor.
The copula parameter will be computed then. The correlation must be greater than zero.

```jldoctest
julia> a = Clayton_cop(2, 2.)
Clayton_cop(2, 2.0)

julia> Nested_Clayton_cop([a], 2, 0.5)
Nested_Clayton_cop(Clayton_cop[Clayton_cop(2, 2.0)], 2, 0.5)

julia> Nested_Clayton_cop([a, a], 2, 0.5)
Nested_Clayton_cop(Clayton_cop[Clayton_cop(2, 2.0), Clayton_cop(2, 2.0)], 2, 0.5)

```
"""
struct Nested_Clayton_cop{T} <: Copula{T}
  children::Vector{Clayton_cop{T}}
  m::Int
  θ::T
  n::Int
  function(::Type{Nested_Clayton_cop})(children::Vector{Clayton_cop{T}}, m::Int, θ::T) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      testθ(θ, "clayton")
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      maximum(ϕ) < θ+2*θ^2+750*θ^5 || @warn("θ << ϕ, marginals may not be uniform")
      new{T}(children, m, θ, n)
  end
  function(::Type{Nested_Clayton_cop})(children::Vector{Clayton_cop{T}}, m::Int, ρ::T, cor::Type{<:CorrelationType}) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      θ = getθ4arch(ρ, "clayton", cor)
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      maximum(ϕ) < θ+2*θ^2+750*θ^5 || @warn("θ << ϕ, marginals may not be uniform")
      new{T}(children, m, θ, n)
  end
end

"""
    Nested_AMH_cop

Nested Ali-Mikhail-Haq copula, fields:
- children::Vector{AMH _cop}  vector of children copulas
- m::Int ≧ 0 - number of additional marginals modeled by the parent copula only
- θ::Real - parameter of parent copula, domain θ ∈ (0,1).

Nested Ali-Mikhail-Haq copula: C _θ(C _ϕ₁(u₁₁, ..., u₁,ₙ₁), ..., C _ϕₖ(uₖ₁, ..., uₖ,ₙₖ), u₁ , ... uₘ).
If m > 0, the last m variables will be modeled by the parent copula only.

Constructor

    Nested_AMH_cop(children::Vector{AMH_cop}, m::Int, θ::Real)

Let ϕ be the vector of parameter of children copula, sufficient nesting condition requires
θ <= minimum(ϕ)

Constructor

    Nested_AMH_cop(children::Vector{AMH_cop}, m::Int, θ::Real, cor::Type{<:CorrelationType})

For computing copula parameter from expected correlation use empty type cor::Type{<:CorrelationType} where
SpearmanCorrelation <:CorrelationType and KendallCorrelation<:CorrelationType. If used cor put expected correlation in the place of θ  in the constructor.
The copula parameter will be computed then. The correlation must be greater than zero.

```jldoctest

julia> a = AMH_cop(2, .2)
AMH_cop(2, 0.2)

julia> Nested_AMH_cop([a, a], 2, 0.1)
Nested_AMH_cop(AMH_cop[AMH_cop(2, 0.2), AMH_cop(2, 0.2)], 2, 0.1)

```
"""
struct Nested_AMH_cop{T} <: Copula{T}
  children::Vector{AMH_cop{T}}
  m::Int
  θ::T
  n::Int
  function(::Type{Nested_AMH_cop})(children::Vector{AMH_cop{T}}, m::Int, θ::T) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      testθ(θ, "amh")
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, m, θ, n)
  end
  function(::Type{Nested_AMH_cop})(children::Vector{AMH_cop{T}}, m::Int, ρ::T, cor::Type{<:CorrelationType}) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      θ = getθ4arch(ρ, "amh", cor)
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, m, θ, n)
  end
end

"""
    Nested_Frank_cop

Fields:
- children::Vector{Frank_cop}  vector of children copulas
- m::Int ≧ 0 - number of additional marginals modeled by the parent copula only
- θ::Real - parameter of parent copula, domain θ ∈ (0,∞).

Nested Frank copula: C _θ(C _ϕ₁(u₁₁, ..., u₁,ₙ₁), ..., C _ϕₖ(uₖ₁, ..., uₖ,ₙₖ), u₁ , ... uₘ).
If m > 0, the last m variables will be modeled by the parent copula only.

Constructor

    Nested_Frank_cop(children::Vector{Frank_cop}, m::Int, θ::Real)

Let ϕ be the vector of parameter of children copula, sufficient nesting condition requires
θ <= minimum(ϕ)

Constructor

    Nested_Frank_cop(children::Vector{Frank_ cop}, m::Int, θ::Real, cor::Type{<:CorrelationType})

For computing copula parameter from expected correlation use empty type cor::Type{<:CorrelationType} where
SpearmanCorrelation <:CorrelationType and KendallCorrelation<:CorrelationType. If used cor put expected correlation in the place of θ  in the constructor.
The copula parameter will be computed then. The correlation must be greater than zero.

```jldoctests

julia> a = Frank_cop(2, 5.)
Frank_cop(2, 5.0)

julia> Nested_Frank_cop([a, a], 2, 0.1)
Nested_Frank_cop(Frank_cop[Frank_cop(2, 5.0), Frank_cop(2, 5.0)], 2, 0.1)
```
"""
struct Nested_Frank_cop{T} <: Copula{T}
  children::Vector{Frank_cop{T}}
  m::Int
  θ::T
  n::Int
  function(::Type{Nested_Frank_cop})(children::Vector{Frank_cop{T}}, m::Int, θ::T) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      testθ(θ, "frank")
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, m, θ, n)
  end
  function(::Type{Nested_Frank_cop})(children::Vector{Frank_cop{T}}, m::Int, ρ::T, cor::Type{<:CorrelationType}) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      θ = getθ4arch(ρ, "frank", cor)
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, m, θ, n)
  end
end

"""
    Nested_Gumbel_cop

Fields:
- children::Vector{Gumbel_cop}  vector of children copulas
- m::Int ≧ 0 - number of additional marginals modeled by the parent copula only
- θ::Real - parameter of parent copula, domain θ ∈ [1,∞).

Nested Gumbel copula: C _θ(C _ϕ₁(u₁₁, ..., u₁,ₙ₁), ..., C _ϕₖ(uₖ₁, ..., uₖ,ₙₖ), u₁ , ... uₘ).
If m > 0, the last m variables will be modeled by the parent copula only.

Constructor

    Nested_Gumbel_cop(children::Vector{Gumbel_cop}, m::Int, θ::Real)

Let ϕ be the vector of parameter of children copula, sufficient nesting condition requires
θ <= minimum(ϕ)

Constructor

    Nested_Gumbel_cop(children::Vector{Gumbel_cop}, m::Int, θ::Real, cor::Type{<:CorrelationType})

For computing copula parameter from expected correlation use empty type cor::Type{<:CorrelationType} where
SpearmanCorrelation <:CorrelationType and KendallCorrelation<:CorrelationType. If used cor put expected correlation in the place of θ  in the constructor.
The copula parameter will be computed then. The correlation must be greater than zero.

```jldoctest

julia> a = Gumbel_cop(2, 5.)
Gumbel_cop(2, 5.0)

julia> Nested_Gumbel_cop([a, a], 2, 2.1)
Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.0), Gumbel_cop(2, 5.0)], 2, 2.1)
```
"""
struct Nested_Gumbel_cop{T} <: Copula{T}
  children::Vector{Gumbel_cop{T}}
  m::Int
  θ::T
  n::Int
  function(::Type{Nested_Gumbel_cop})(children::Vector{Gumbel_cop{T}}, m::Int, θ::T) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      testθ(θ, "gumbel")
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, m, θ, n)
  end
  function(::Type{Nested_Gumbel_cop})(children::Vector{Gumbel_cop{T}}, m::Int, ρ::T, cor::Type{<:CorrelationType}) where T <: Real
      m >= 0 || throw(DomainError("not supported for m  < 0 "))
      θ = getθ4arch(ρ, "gumbel", cor)
      ϕ = [ch.θ for ch in children]
      n = sum(ch.n for ch in children)+m
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, m, θ, n)
  end
end



"""
    simulate_copula!(U::Matrix{Real}, copula::Nested_Clayton_cop; rng::AbstractRNG = Random.GLOBAL_RNG)

Given the preallocated output U, Returns size(U,1) realizations from the nested Clayton copula - Nested_Clayton_cop
N.o. marginals is size(U,2), these must be euqal to n.o. marginals of the copula

```jldoctest

julia> c1 = Clayton_cop(2, 2.)
Clayton_cop(2, 2.0)

julia> c2 = Clayton_cop(2, 3.)
Clayton_cop(2, 3.0)

julia> cp = Nested_Clayton_cop([c1, c2], 1, 1.1)
Nested_Clayton_cop(Clayton_cop[Clayton_cop(2, 2.0), Clayton_cop(2, 3.0)], 1, 1.1)

julia> U = zeros(5,5)
5×5 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

julia> Random.seed!(43);

julia> simulate_copula!(U, cp)

julia> U
5×5 Array{Float64,2}:
 0.514118  0.84089    0.870106   0.906233  0.739349
 0.588245  0.85816    0.935308   0.944444  0.709009
 0.59625   0.665947   0.483649   0.603074  0.153501
 0.200051  0.304099   0.242572   0.177836  0.0851603
 0.120914  0.0683055  0.0586907  0.126257  0.519241
```
"""
function simulate_copula!(U, copula::Nested_Clayton_cop{T}; rng = Random.GLOBAL_RNG) where T
      m = copula.m
      θ = copula.θ
      children = copula.children
      ϕ = [ch.θ for ch in children]
      n = [ch.n for ch in children]
      n1 = vcat([collect(1:n[1])], [collect(cumsum(n)[i]+1:cumsum(n)[i+1]) for i in 1:length(n)-1])
      n2 = sum(n)+m
      size(U, 2) == n2 || throw(AssertionError("n.o. margins in pre allocated output and copula not equal"))
      for j in 1:size(U,1)
         rand_vec = rand(rng, T, n2+1)
         U[j,:] = nested_clayton_gen(n1, ϕ, θ, rand_vec; rng=rng)
     end
end


"""
    simulate_copula!(U::Matrix{Real}, copula::Nested_AMH_cop; rng::AbstractRNG = Random.GLOBAL_RNG)

Given the preallocated output U, Returns size(U,1) realizations from the nested AMH copula - Nested_AMH_cop
N.o. marginals is size(U,2), these must be euqal to n.o. marginals of the copula

```jldoctest

julia> c1 = AMH_cop(2, .7)
AMH_cop(2, 0.7)

julia> c2 = AMH_cop(2, .8)
AMH_cop(2, 0.8)

julia> cp = Nested_AMH_cop([c1, c2], 1, 0.2)
Nested_AMH_cop(AMH_cop[AMH_cop(2, 0.7), AMH_cop(2, 0.8)], 1, 0.2)

julia> Random.seed!(43);

julia> U = zeros(4,5)
4×5 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

julia> simulate_copula!(U, cp)

julia> U
4×5 Array{Float64,2}:
 0.557393  0.902767  0.909853  0.938522  0.586068
 0.184204  0.866664  0.699134  0.226744  0.102932
 0.268634  0.383355  0.179023  0.533749  0.995958
 0.578143  0.840169  0.743728  0.963226  0.576695
```
"""
function simulate_copula!(U, copula::Nested_AMH_cop{T}; rng = Random.GLOBAL_RNG) where T
    m = copula.m
    θ = copula.θ
    children = copula.children
    ϕ = [ch.θ for ch in children]
    n = [ch.n for ch in children]
    n1 = vcat([collect(1:n[1])], [collect(cumsum(n)[i]+1:cumsum(n)[i+1]) for i in 1:length(n)-1])
    n2 = sum(n)+m
    size(U, 2) == n2 || throw(AssertionError("n.o. margins in pre allocated output and copula not equal"))
    for j in 1:size(U,1)
       rand_vec = rand(rng, T, n2+1)
       U[j,:] = nested_amh_gen(n1, ϕ, θ, rand_vec; rng=rng)
   end
end


"""
    simulate_copula!(U::Matrix{Real}, copula::Nested_Frank_cop; rng::AbstractRNG = Random.GLOBAL_RNG)

Given the preallocated output U, Returns size(U,1) realizations from the nested Frank copula a - Nested_Frank_cop
N.o. marginals is size(U,2), these must be euqal to n.o. marginals of the copula

```jldoctest

julia> c1 = Frank_cop(2, 4.)
Frank_cop(2, 4.0)

julia> c2 = Frank_cop(2, 5.)
Frank_cop(2, 5.0)

julia> c = Nested_Frank_cop([c1, c2],1, 2.0)
Nested_Frank_cop(Frank_cop[Frank_cop(2, 4.0), Frank_cop(2, 5.0)], 1, 2.0)

julia> U = zeros(1,5)
1×5 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0

julia> Random.seed!(43);

julia> simulate_copula!(U, c)

julia> U
1×5 Array{Float64,2}:
 0.642765  0.901183  0.969422  0.9792  0.74155

```
"""
function simulate_copula!(U, copula::Nested_Frank_cop{T}; rng = Random.GLOBAL_RNG) where T
    m = copula.m
    θ = copula.θ
    children = copula.children
    ϕ = [ch.θ for ch in children]
    n = [ch.n for ch in children]
    n2 = sum(n)+m
    size(U, 2) == n2 || throw(AssertionError("n.o. margins in pre allocated output and copula not equal"))

    ws = [logseriescdf(1-exp(theta)) for theta in ϕ]
    n1 = vcat([collect(1:n[1])], [collect(cumsum(n)[i]+1:cumsum(n)[i+1]) for i in 1:length(n)-1])
    w = logseriescdf(1-exp(-θ))
    for j in 1:size(U,1)
       rand_vec = rand(rng, T, n2+1)
       U[j,:] = nested_frank_gen(n1, ϕ, θ, rand_vec, w, ws; rng=rng)
   end
end



"""
    simulate_copula!(U::Matrix{Real}, copula::Nested_Gumbel_cop; rng::AbstractRNG = Random.GLOBAL_RNG)

Given the preallocated output U, Returns size(U,1) realizations from the nested Gumbel copula - Nested_Gumbel_cop
N.o. marginals is size(U,2), these must be euqal to n.o. marginals of the copula

```jldoctest
julia> c1 = Gumbel_cop(2, 2.)
Gumbel_cop(2, 2.0)

julia> c2 = Gumbel_cop(2, 3.)
Gumbel_cop(2, 3.0)

julia> cp = Nested_Gumbel_cop([c1, c2], 1, 1.1)
Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 2.0), Gumbel_cop(2, 3.0)], 1, 1.1)

julia> u = zeros(4,5)
4×5 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

julia> Random.seed!(43);

julia> simulate_copula!(u, cp)

julia> u
4×5 Array{Float64,2}:
 0.387085   0.693399   0.94718   0.953776  0.583379
 0.0646972  0.0865914  0.990691  0.991127  0.718803
 0.966896   0.709233   0.788019  0.855622  0.755476
 0.272487   0.106996   0.756052  0.834068  0.661432
```
"""
function simulate_copula!(U, copula::Nested_Gumbel_cop{T}; rng = Random.GLOBAL_RNG) where T
    m = copula.m
    θ = copula.θ
    children = copula.children
    ϕ = [ch.θ for ch in children]
    n = [ch.n for ch in children]
    n1 = vcat([collect(1:n[1])], [collect(cumsum(n)[i]+1:cumsum(n)[i+1]) for i in 1:length(n)-1])
    n2 = sum(n)+m
    size(U, 2) == n2 || throw(AssertionError("n.o. margins in pre allocated output and copula not equal"))

    for j in 1:size(U,1)
       rand_vec = rand(rng, T, n2)
       U[j,:] = nested_gumbel_gen(n1, ϕ, θ, rand_vec; rng=rng)
   end
end

"""
    Double_Nested_Gumbel_cop

Fields:
- children::Vector{Nested _Gumbel _cop}  vector of children copulas
- θ::Real - parameter of parent copula, domain θ ∈ [1,∞).

Constructor

    Double_Nested_Gumbel _cop(children::Vector{Nested_Gumbel_cop}, θ::Real)
requires sufficient nesting condition for θ and child copulas.

Constructor

    Doulbe_Nested_Gumbel_cop(children::Vector{Nested_Gumbel_cop}, θ::Real, cor::Type{<:CorrelationType})

For computing copula parameter from expected correlation use empty type cor::Type{<:CorrelationType} where
SpearmanCorrelation <:CorrelationType and KendallCorrelation<:CorrelationType. If used cor put expected correlation in the place of θ  in the constructor.
The copula parameter will be computed then. The correlation must be greater than zero.


```jldoctest

julia> a = Gumbel_cop(2, 5.)
Gumbel_cop(2, 5.0)

julia> b = Gumbel_cop(2, 6.)
Gumbel_cop(2, 6.0)

julia> c = Gumbel_cop(2, 5.5)
Gumbel_cop(2, 5.5)

julia> p1 = Nested_Gumbel_cop([a,b], 1, 2.)
Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.0), Gumbel_cop(2, 6.0)], 1, 2.0)

julia> p2 = Nested_Gumbel_cop([c], 2, 2.1)
Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.5)], 2, 2.1)

julia> Double_Nested_Gumbel_cop([p1, p2], 1.5)
Double_Nested_Gumbel_cop(Nested_Gumbel_cop[Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.0), Gumbel_cop(2, 6.0)], 1, 2.0), Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.5)], 2, 2.1)], 1.5)
```
"""
struct Double_Nested_Gumbel_cop{T} <: Copula{T}
  children::Vector{Nested_Gumbel_cop{T}}
  θ::T
  n::Int
  function(::Type{Double_Nested_Gumbel_cop})(children::Vector{Nested_Gumbel_cop{T}}, θ::T) where T <: Real
      testθ(θ, "gumbel")
      ϕ = [ch.θ for ch in children]
      ns = [[ch.n for ch in vs.children] for vs in children]
      n = sum([sum(ns[i])+children[i].m for i in 1:length(children)])
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, θ,n)
  end
  function(::Type{Double_Nested_Gumbel_cop})(children::Vector{Nested_Gumbel_cop{T}}, ρ::T, cor::Type{<:CorrelationType}) where T <: Real
      θ = getθ4arch(ρ, "gumbel", cor)
      ϕ = [ch.θ for ch in children]
      ns = [[ch.n for ch in vs.children] for vs in children]
      n = sum([sum(ns[i])+children[i].m for i in 1:length(children)])
      θ <= minimum(ϕ) || throw(DomainError("violated sufficient nesting condition"))
      new{T}(children, θ,n)
  end
end



"""
    simulate_copula!(U::Matrix{Real}, copula::Double_Nested_Gumbel_cop; rng::AbstractRNG = Random.GLOBAL_RNG)

Given the preallocated output U, Returns size(U,1) realizations from the double nested Gumbel copula - Double_Nested_Gumbel_cop
N.o. marginals is size(U,2), these must be euqal to n.o. marginals of the copula

```jldoctest
julia> a = Gumbel_cop(2, 5.)
Gumbel_cop(2, 5.0)

julia> b = Gumbel_cop(2, 6.)
Gumbel_cop(2, 6.0)

julia> c = Gumbel_cop(2, 5.5)
Gumbel_cop(2, 5.5)

julia> p1 = Nested_Gumbel_cop([a,b], 1, 2.)
Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.0), Gumbel_cop(2, 6.0)], 1, 2.0)

julia> p2 = Nested_Gumbel_cop([c], 2, 2.1)
Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.5)], 2, 2.1)

julia> copula = Double_Nested_Gumbel_cop([p1, p2], 1.5)
Double_Nested_Gumbel_cop(Nested_Gumbel_cop[Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.0), Gumbel_cop(2, 6.0)], 1, 2.0), Nested_Gumbel_cop(Gumbel_cop[Gumbel_cop(2, 5.5)], 2, 2.1)], 1.5)

julia> u = zeros(3,9)
3×9 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

julia> Random.seed!(43);

julia> simulate_copula!(u, copula)

julia> u
3×9 Array{Float64,2}:
 0.598555   0.671584  0.8403     0.846844  0.634609  0.686927  0.693906  0.651968    0.670812
 0.0518892  0.191236  0.0803859  0.104325  0.410727  0.529354  0.557387  0.370518    0.592302
 0.367914   0.276196  0.382616   0.470171  0.264135  0.144503  0.13097   0.00687015  0.01417
```
"""



function simulate_copula!(U, copula::Double_Nested_Gumbel_cop{T}; rng = Random.GLOBAL_RNG) where T
    θ = copula.θ
    v = copula.children
    ns = [[ch.n for ch in vs.children] for vs in v]
    Ψs = [[ch.θ for ch in vs.children] for vs in v]
    dims = sum([sum(ns[i])+v[i].m for i in 1:length(v)])
    size(U, 2) == dims || throw(AssertionError("n.o. margins in pre allocated output and copula not equal"))

    for j in 1:size(U,1)
        X = T[]
        for k in 1:length(v)
            n = ns[k]
            n1 = vcat([collect(1:n[1])], [collect(cumsum(n)[i]+1:cumsum(n)[i+1]) for i in 1:length(n)-1])
            n2 = sum(n)+v[k].m
            rand_vec = rand(rng, T, n2)
            X = vcat(X, nested_gumbel_gen(n1, Ψs[k], v[k].θ./θ, rand_vec; rng = rng))
        end
        X = -log.(X)./levyel(θ, rand(rng), rand(rng))
        U[j,:] = exp.(-X.^(1/θ))
    end
end

"""
    Hierarchical_Gumbel_cop

Fields:
- n::Int - number of marginals
- θ::Vector{Real} - vector of parameters, must be decreasing  and θ[end] ≧ 1, for the
sufficient nesting condition to be fulfilled.

The hierarchically nested Gumbel copula C_θₙ₋₁(C_θₙ₋₂( ... C_θ₂(C_θ₁(u₁, u₂), u₃)...uₙ₋₁) uₙ)

Constructor

    Hierarchical_Gumbel_cop(θ::Vector{Real})

Constructor

    Hierarchical_Gumbel_cop(ρ::Vector{Real}, cor::Type{<:CorrelationType})

For computing copula parameters from expected correlations use empty type cor::Type{<:CorrelationType} where
SpearmanCorrelation <:CorrelationType and KendallCorrelation<:CorrelationType. If used cor put expected correlations in the place of θ  in the constructor.
The copula parameters will be computed then. The correlation must be greater than zero.


```jldoctest

julia> c = Hierarchical_Gumbel_cop([5., 4., 3.])
Hierarchical_Gumbel_cop(4, [5.0, 4.0, 3.0])

julia> c = Hierarchical_Gumbel_cop([0.95, 0.5, 0.05], KendallCorrelation)
Hierarchical_Gumbel_cop(4, [19.999999999999982, 2.0, 1.0526315789473684])
```
"""
struct Hierarchical_Gumbel_cop{T} <: Copula{T}
  n::Int
  θ::Vector{T}
  function(::Type{Hierarchical_Gumbel_cop})(θ::Vector{T}) where T <: Real
      testθ(θ[end], "gumbel")
      issorted(θ; rev=true) || throw(DomainError("violated sufficient nesting condition, parameters must be descending"))
      new{T}(length(θ)+1, θ)
  end
  function(::Type{Hierarchical_Gumbel_cop})(ρ::Vector{T}, cor::Type{<:CorrelationType}) where T <: Real
      θ = map(i -> getθ4arch(ρ[i], "gumbel", cor), 1:length(ρ))
      issorted(θ; rev=true) || throw(DomainError("violated sufficient nesting condition, parameters must be descending"))
      new{T}(length(θ)+1, θ)
  end
end



"""
    simulate_copula!(U::Matrix{Real}, copula::Hierarchical_Gumbel_cop; rng::AbstractRNG = Random.GLOBAL_RNG)

Given the preallocated output U, Returns size(U,1) realizations from the hierachically nested Gumbel copula - Hierarchical_Gumbel_cop
N.o. marginals is size(U,2), these must be euqal to n.o. marginals of the copula i.e. copula.n

```jldoctest

julia> c = Hierarchical_Gumbel_cop([5., 4., 3.])
Hierarchical_Gumbel_cop(4, [5.0, 4.0, 3.0])

julia> Random.seed!(43);

julia> u = zeros(3,4)
3×4 Array{Float64,2}:
 0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0

julia> simulate_copula!(u, c)

julia> u
3×4 Array{Float64,2}:
 0.100353  0.207903  0.0988337  0.0431565
 0.347417  0.217052  0.223734   0.042903
 0.73617   0.347349  0.168348   0.410963
```
"""
function simulate_copula!(U, copula::Hierarchical_Gumbel_cop{T}; rng= Random.GLOBAL_RNG) where T
  θ = copula.θ
  θ = vcat(θ, [1.])
  size(U, 2) == copula.n || throw(AssertionError("n.o. margins in pre allocated output and copula not equal"))

  for j in 1:size(U,1)
      X = rand(rng, T)
      for i in 1:(copula.n-1)
          X = gumbel_step(vcat(X, rand(rng)), θ[i], θ[i+1]; rng = rng)
      end
     U[j,:] = X
    end
end

"""
    nested_gumbel_gen(n::Vector{Vector{Int}}, ϕ::Vector{Real},
                         θ::Real, rand_vec::Vector{Real}; rng::AbstractRNG)

Convert a vector of random independnet elements to such sampled from the
Nested Gumbel copula
"""
function nested_gumbel_gen(n, ϕ, θ::T, rand_vec; rng) where T
    V0 = levyel(θ, rand(rng, T), rand(rng, T))
    u = copy(rand_vec)
    for i in 1:length(n)
      u[n[i]] = gumbel_step(rand_vec[n[i]], ϕ[i], θ; rng = rng)
    end
    u = -log.(u)./V0
    return exp.(-u.^(1/θ))
end

"""
    nested_amh_gen(n::Vector{Vector{Int}}, ϕ::Vector{Real},
                         θ::Real, rand_vec::Vector{Real}; rng::AbstractRNG)
"""
function nested_amh_gen(n, ϕ, θ::T, rand_vec; rng) where T
    V0 = 1 .+ quantile.(Geometric(1-θ), rand_vec[end])
    u = copy(rand_vec[1:end-1])
    for i in 1:length(n)
      u[n[i]] = amh_step(rand_vec[n[i]], V0, ϕ[i], θ; rng = rng)
    end
    u = -log.(u)./V0
    return (1-θ) ./(exp.(u) .-θ)
end

"""
    nested_frank_gen(n::Vector{Vector{Int}}, ϕ::Vector{Real}, θ::Real, rand_vec::Vector{Real}, logseries::Vector{Real},
                         logseries_children::Vector{Vector{Real}};
                         rng::AbstractRNG)
"""
function nested_frank_gen(n, ϕ, θ::T, rand_vec, logseries, logseries_children; rng) where T
    V0 = findlast(logseries .< rand_vec[end])
    u = copy(rand_vec[1:end-1])
    for i in 1:length(n)
      u[n[i]] = frank_step(rand_vec[n[i]], V0, ϕ[i], θ, logseries_children[i]; rng = rng)
    end
    u = -log.(u)./V0
    return -log.(1 .+exp.(-u) .*(exp(-θ)-1)) ./θ
end

"""
    nested_clayton_gen(n::Vector{Vector{Int}}, ϕ::Vector{Real}, θ::Real, rand_vec::Vector{Real}; rng::AbstractRNG = Random.GLOBAL_RNG)
"""
function nested_clayton_gen(n, ϕ, θ::T, rand_vec; rng) where T

    V0 = gamma_inc_inv(1/θ, rand_vec[end], T(1.)-rand_vec[end])
    u = copy(rand_vec[1:end-1])
    for i in 1:length(n)
      u[n[i]] = clayton_step(rand_vec[n[i]], V0, ϕ[i], θ; rng = rng)
    end
    u = -log.(u)./V0
    return (1 .+ u).^(-1/θ)
end

"""
    gumbel_step(u::Vector{Real}, ϕ::Real, θ::Real; rng::AbstractRNG)
"""
function gumbel_step(u, ϕ, θ::T; rng) where T
    u = -log.(u)./levyel(ϕ/θ, rand(rng, T), rand(rng, T))
    return exp.(-u.^(θ/ϕ))
end

"""
    clayton_step(u::Vector{Real}, V0::Real, ϕ::Real, θ::Real; rng::AbstractRNG)
"""
function clayton_step(u, V0, ϕ, θ::T; rng) where T
    u = -log.(u)./tiltedlevygen(V0, ϕ/θ; rng = rng)
    return exp.(V0.-V0.*(1 .+u).^(θ/ϕ))
end

"""
    frank_step(u::Vector{Real}, V0::Int, ϕ::Real, θ::Real, logseries_child::Vector{Real}; rng::AbstractRNG)
"""
function frank_step(u, V0, ϕ, θ::T, logseries_child; rng) where T
    u = -log.(u)./nestedfrankgen(ϕ, θ, V0, logseries_child; rng = rng)
    X = (1 .-(1 .-exp.(-u)*(1-exp(-ϕ))).^(θ/ϕ))./(1-exp(-θ))
    return X.^V0
end
"""
    amh_step(u::Vector{Real}, V0::Real, ϕ::Real, θ::Real; rng::AbstractRNG)
"""
function amh_step(u, V0, ϕ, θ::T; rng) where T
    # TODO this need to be changed for BigFloat
    w = quantile(NegativeBinomial(V0, (1-ϕ)/(1-θ)), rand(rng, T))
    u = -log.(u)./(V0 + w)
    X = ((exp.(u) .-ϕ) .*(1-θ) .+θ*(1-ϕ)) ./(1-ϕ)
    return X.^(-V0)
end

"""
nestedcopulag(copula::String, ns::Vector{Vector{Int}}, ϕ::Vector{Real}, θ::Real, r::Matrix{Real})

Given [0,1]ᵗˣˡ ∋ r, returns t realizations of l-1 variate data from nested archimedean copula


```jldoctest
julia> Random.seed!(43)

julia> nestedcopulag("clayton", [[1,2],[3,4]], [2., 3.], 1.1, [0.1 0.2 0.3 0.4 0.5; 0.2 0.3 0.4 0.5 0.6])
julia> nestedcopulag("clayton", [[1,2],[3,4]], [2., 3.], 1.1, [0.1 0.2 0.3 0.4 0.5; 0.2 0.3 0.4 0.5 0.6])
2×4 Array{Float64,2}:
 0.153282  0.182421  0.374228  0.407663
 0.69035   0.740927  0.254842  0.279192
```
"""
function nestedcopulag(copula, ns, ϕ, θ::T,r; rng) where T <: Real
    t = size(r,1)
    n = size(r,2)-1
    u = zeros(T, t, n)
    if copula == "clayton"
        for j in 1:t
            u[j,:] = nested_clayton_gen(ns, ϕ, θ, r[j,:]; rng = rng)
        end
    elseif copula == "amh"
        for j in 1:t
            u[j,:] = nested_amh_gen(ns, ϕ, θ, r[j,:]; rng = rng)
        end
    elseif copula == "frank"
        ws = [logseriescdf(1-exp(theta)) for theta in ϕ]
        w = logseriescdf(1-exp(-θ))
        for j in 1:t
            u[j,:] = nested_frank_gen(ns, ϕ, θ, r[j,:], w, ws; rng = rng)
        end
    elseif copula == "gumbel"
        v = r[:,end]
        p = invperm(sortperm(v))
        V0 = [levyel(θ, rand(rng), rand(rng)) for i in 1:t]
        V0 = sort(V0)[p]
        for j in 1:t
            rand_vec = r[j,1:end-1]
            x = copy(rand_vec)
            for i in 1:length(ϕ)
              x[ns[i]] = gumbel_step(rand_vec[ns[i]], ϕ[i], θ; rng = rng)
            end
            x = -log.(x)./V0[j]
            u[j,:] = exp.(-x.^(1/θ))
        end
    end
    return u
end
