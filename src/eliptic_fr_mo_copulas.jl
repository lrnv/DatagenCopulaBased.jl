# Elliptical Frechet and Marshal Olkim copulas generators

## Elliptical copulas

"""
  Gaussian_cop

  field Σ - the correlation matrix must be symmetric, positivelly defined and with ones on diagonal

"""
struct Gaussian_cop
  Σ::Matrix{Float64}
  function(::Type{Gaussian_cop})(Σ::Matrix{Float64})
    Σ ≈ transpose(Σ) || throw(DomainError("Σ matrix not symmetric"))
    isposdef(Σ) || throw(DomainError("Σ matrix not positivelly defined"))
    prod(diag(Σ)) ≈ 1.0 || throw(DomainError("Σ matrix do not have ones on diagonal"))
    new(Σ)
  end
end

"""

  simulate_copula1(t::Int, copula::Gaussian_cop)

Returns: t x n matrix of t realisations of multivariate data generated
using Gaussian_cop(Σ), the gaussian copula with Σ ∈ R^{n x n} - correlation matrix.

```jldoctest

julia> Random.seed!(43);

julia> simulate_copula1(10, Gaussian_cop([1. 0.5; 0.5 1.]))
10×2 Array{Float64,2}:
 0.589188  0.815308
 0.708285  0.924962
 0.747341  0.156994
 0.227634  0.183116
 0.227575  0.957376
 0.271558  0.364803
 0.445691  0.52792
 0.585362  0.23135
 0.498593  0.48266
 0.190283  0.594451
```
"""
function simulate_copula1(t::Int, copula::Gaussian_cop)
  Σ = copula.Σ
  z = transpose(rand(MvNormal(Σ),t))
  for i in 1:size(Σ, 1)
    d = Normal(0, sqrt.(Σ[i,i]))
    z[:,i] = cdf.(d, z[:,i])
  end
  Array(z)
end

#=
function gaussian_cop(t::Int, Σ::Matrix{Float64} = [1. 0.5; 0.5 1.])
  z = transpose(rand(MvNormal(Σ),t))
  for i in 1:size(Σ, 1)
    d = Normal(0, sqrt.(Σ[i,i]))
    z[:,i] = cdf.(d, z[:,i])
  end
  Array(z)
end
=#

"""
Student_cop

field Σ::Matrix{Float64} - the correlation matrix must be symmetric, positivelly defined and with ones on diagonal
ν::Int - the parameter n.o. degrees of freedom we require ν > 0
"""

struct Student_cop
  Σ::Matrix{Float64}
  ν::Int
  function(::Type{Student_cop})(Σ::Matrix{Float64}, ν::Int)
    Σ ≈ transpose(Σ) || throw(DomainError("Σ matrix not symmetric"))
    isposdef(Σ) || throw(DomainError("Σ matrix not positivelly defined"))
    prod(diag(Σ)) ≈ 1.0 || throw(DomainError("Σ matrix do not have ones on diagonal"))
    ν > 0 || throw(DomainError("ν lower or equal zero"))
    new(Σ, ν)
  end
end


"""

  simulate_copula1(t::Int, copula::Student_cop)

Generates t realisatioins of data using
t-Student Copula: Student_cop(Σ, ν) where: Σ - correlation matrix, ν - degrees of freedom.

```jldoctest
julia> Random.seed!(43);

julia> simulate_copula1(10, Student_cop([1. 0.5; 0.5 1.], 10))
10×2 Array{Float64,2}:
 0.658199  0.937148
 0.718244  0.92602
 0.809521  0.0980325
 0.263068  0.222589
 0.187187  0.971109
 0.245373  0.346428
 0.452336  0.524498
 0.57113   0.272525
 0.498443  0.48082
 0.113788  0.633349
 ```
"""


function simulate_copula1(t::Int, copula::Student_cop)
  Σ = copula.Σ
  ν = copula.ν
  z = transpose(rand(MvNormal(Σ),t))
  U = rand(Chisq(ν), size(z, 1))
  for i in 1:size(Σ, 1)
    x = z[:,i].*sqrt.(ν./U)./sqrt(Σ[i,i])
    z[:,i] = cdf.(TDist(ν), x)
  end
  Array(z)
end


#=
function tstudent_cop(t::Int, Σ::Matrix{Float64} = [1. 0.5; 0.5 1.], ν::Int=10)
  z = transpose(rand(MvNormal(Σ),t))
  U = rand(Chisq(ν), size(z, 1))
  for i in 1:size(Σ, 1)
    x = z[:,i].*sqrt.(ν./U)./sqrt(Σ[i,i])
    z[:,i] = cdf.(TDist(ν), x)
  end
  Array(z)
end
=#
### Frechet familly

"""
Frechet_cop

one dimentional Frechet copula is a combination of maximal copula with  weight α
and independent copula with  weight 1-α

Two parameters Frechet copula C = α C_{max} + β C_{min} + (1- α - β) C_{⟂}, supported
only for n == 2

"""

struct Frechet_cop
  n::Int
  α::Union{Int, Float64}
  β::Union{Int, Float64}
  function(::Type{Frechet_cop})(n::Int, α::Union{Int, Float64})
    0 <= α <= 1 || throw(DomainError("generaton not supported for α ∉ [0,1]"))
    n > 1 || throw(DomainError("n must be greater than 1"))
    new(n, α, 0.)
  end
  function(::Type{Frechet_cop})(n::Int, α::Union{Int, Float64}, β::Union{Int, Float64})
    0 <= α <= 1 || throw(DomainError("generaton not supported for α ∉ [0,1]"))
    0 <= β <= 1 || throw(DomainError("generaton not supported for β ∉ [0,1]"))
    n == 2 || throw(AssertionError("two parameters Frechet copula supported only for n = 2"))
    0 <= α+β <= 1 || throw(DomainError("α+β must be in range [0,1]"))
    new(n, α, β)
  end
end

"""

simulate_copula1(t::Int, copula::Frechet_cop)

Generates t realisatioins of data using one parameter Frechet_cop(n, α ,0)
or two parameter for n = 2 Frechet_cop(n, α, β)

```jldoctest

  julia> Random.seed!(43);

  julia> f = Frechet_cop(3, 0.5)
  Frechet_cop(3, 0.5, 0.0)

  julia> simulate_copula1(1, f)
  1×3 Array{Float64,2}:
   0.180975  0.775377  0.888934
```

```jldoctest
  julia> Random.seed!(43);

  julia> f = Frechet_cop(2, 0.5, 0.2)
  Frechet_cop(2, 0.5, 0.2)

  julia> simulate_copula1(1, f)
  1×2 Array{Float64,2}:
   0.180975  0.775377
```

"""

function simulate_copula1(t::Int, copula::Frechet_cop)
  n = copula.n
  α = copula.α
  β = copula.β
  if (β > 0) & (n == 2)
    u = rand(t,2)
    return frechet(α, β, u)
  else
    u = rand(t, n)
    return frechet(α, u)
  end
end

"""
  frechet(t::Int, n::Int, α::Union{Int, Float64})

Given n-variate random data u ∈ R^{t, n}
Returns t realisation of n variate data generated from one parameter Frechet_cop(n, α).

```jldoctest
julia> Random.seed!(43);

julia> u = rand(10, 2)

julia> frechet(0.5, u)
10×2 Array{Float64,2}:
 0.180975  0.661781
 0.775377  0.775377
 0.888934  0.125437
 0.924876  0.924876
 0.408278  0.408278
 0.912603  0.740184
 0.828727  0.00463791
 0.400537  0.0288987
 0.429437  0.429437
 0.955881  0.851275
```
"""


function frechet(α::Union{Int, Float64}, u::Matrix{Float64})
  for j in 1:size(u, 1)
    if (α >= rand())
      for i in 1:size(u, 2)
        u[j,i] = u[j, end]
      end
    end
  end
  u
end

"""
  frechet(α::Union{Int, Float64}, β::Union{Int, Float64}, u::Matrix{Float64})

Given bivariate random data u ∈ R^{t, 2}
Returns t realisation of bivariate data generated from two parameters Frechet_cop(n, α, β).


```jldoctest
julia> Random.seed!(43);

julia> u = rand(10,2)

julia> frechet(0.4, 0.2, u)
10×2 Array{Float64,2}:
 0.180975  0.661781
 0.775377  0.775377
 0.888934  0.125437
 0.924876  0.924876
 0.408278  0.591722
 0.912603  0.740184
 0.828727  0.171273
 0.400537  0.0288987
 0.429437  0.429437
 0.955881  0.851275
```
"""
function frechet(α::Union{Int, Float64}, β::Union{Int, Float64}, u::Matrix{Float64})
  for j in 1:size(u, 1)
    v = rand()
    if (α >= v)
      u[j,1] = u[j, 2]
    elseif (α < v <= α+β)
      u[j,1] = 1-u[j, 2]
    end
  end
  u
end


### Marshall - Olkin familly

"""
Marshall-Olkin copula with parameter vector λ of non-negative elements λₛ.

Number of marginals is n = ceil(Int, log(2, length(λ)-1)).
Parameters are ordered as follow:
λ = [λ₁, λ₂, ..., λₙ, λ₁₂, λ₁₃, ..., λ₁ₙ, λ₂₃, ..., λₙ₋₁ₙ, λ₁₂₃, ..., λ₁₂...ₙ]

length(λ) ≧ 3 is required
"""

struct Marshall_Olkin_cop
  n::Int
  λ::Vector{Float64}
  function(::Type{Marshall_Olkin_cop})(λ::Vector{Float64})
    minimum(λ) >= 0 || throw(AssertionError("all parameters must by >= 0 "))
    length(λ) >= 3 || throw(AssertionError("not supported for length(λ) < 3"))
    n = floor(Int, log(2, length(λ)+1))
    new(n, λ)
  end
end

"""
  simulate_copula1(t::Int, copula::Marshall_Olkin_cop(λ))

Returns: t x n Matrix{Float}, t realisations of n-variate data generated from
Marshall-Olkin copula with parameter vector λ

```julia> Random.seed!(43);

  julia> f = Marshall_Olkin_cop([1.,2.,3.])
  Marshall_Olkin_cop(2, [1.0, 2.0, 3.0])

  julia> simulate_copula1(1, f)
  1×2 Array{Float64,2}:
   0.854724  0.821831

```
"""
function simulate_copula1(t::Int, copula::Marshall_Olkin_cop)
  λ = copula.λ
  n = copula.n
  mocopula(rand(t,2^n-1), n, λ)
end

#=
function marshallolkin(t::Int, λ::Vector{Float64} = rand(7))
  minimum(λ) >= 0 || throw(AssertionError("all parameters must by >= 0 "))
  n = floor(Int, log(2, length(λ)+1))
  mocopula(rand(t,2^n-1), n, λ)
end
=#
"""
  mocopula(u::Matrix{Float64}, n::Int, λ::Vector{Float64})

  Returns: t x n Matrix{Float}, t realisations of n-variate data generated from Marshall-Olkin
  copula with parameter vector λ of non-negative elements λₛ, given [0,1]ᵗˣˡ ∋ u, where
  l = 2ⁿ-1

```jldoctest

  julia> mocopula([0.2 0.3 0.4; 0.3 0.4 0.6; 0.4 0.5 0.7], 2, [1., 1.5, 2.])
  3×2 Array{Float64,2}:
   0.252982  0.201189
   0.464758  0.409039
   0.585662  0.5357

```
"""
function mocopula(u::Matrix{Float64}, n::Int, λ::Vector{Float64})
  s = collect(combinations(1:n))
  t,l = size(u)
  U = zeros(t, n)
    for j in 1:t
      for i in 1:n
        inds = findall([i in s[k] for k in 1:l])
        x = minimum([-log(u[j,k])./(λ[k]) for k in inds])
        Λ = sum(λ[inds])
        U[j,i] = exp.(-Λ*x)
      end
    end
    U
end
