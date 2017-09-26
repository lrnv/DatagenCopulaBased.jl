module DatagenCopulaBased

  using Distributions

  include("copulagendat.jl")
  include("subcopgendat.jl")
  include("helpers.jl")

  export subcopdatagen, clcopulagen, covmatgen, tcopulagen, gcopulagen,
   gcopulatmarg, tcopulagmarg, tdistdat, normdist

end
