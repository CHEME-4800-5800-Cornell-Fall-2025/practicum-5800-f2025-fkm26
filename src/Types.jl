# throw(ErrorException("Oppps! No methods defined in src/Types.jl. What should you do here?"))
mutable struct MyClassicalHopfieldNetworkModel 

    W::Array{<:Number, 2} # initialize weight matrix
    b::Array{<:Number, 1} # initialize bias vector
    energy::Dict{Int64, Float32} # initialize energy dictionary of the states

    MyClassicalHopfieldNetworkModel() = new(); # constructor
end