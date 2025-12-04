# throw(ErrorException("Oppps! No methods defined in src/Compute.jl. What should you do here?") 
function _energy(s::Array{<:Number,1}, W::Array{<:Number,2}, b::Array{<:Number,1})::Float32 #return type hardcoded

    # initialization
    tmp_energy_state = 0.0;
    number_of_states = length(s);

    tmp = transpose(b)*s; # compute bias term, zero here so currently a placeholder
    for i in 1:number_of_states
        for j in 1:number_of_states
            tmp_energy_state += W[i,j]*s[i]*s[j]; # compute the energy
        end
    end 

    energy_state = -(1/2)*tmp_energy_state + tmp # compute the final energy 

    return energy_state;
end

function ⊗(a::Array{T,1}, b::Array{T,1})::Array{T,2} where T <: Number # can be anything, so long as it's some type of number
    
    # initialization
    m = length(a)
    n = length(b)
    Y = zeros(m,n)

    for i in 1:m 
        for j in 1:n
            Y[i,j] = a[i]*b[j] # calculate outer product
        end
    end

    return Y
end

function recover(model::MyClassicalHopfieldNetworkModel, sₒ::Array{Int32,1}, trueenergyvalue::Float32;
    maxiterations::Int = 1000, patience::Union{Int,Nothing} = nothing,
    miniterations_before_convergence::Union{Int,Nothing} = nothing)::Tuple{Dict{Int64, Array{Int32,1}}, Dict{Int64, Float32}}

    # initialization
    W = model.W; # collect the weights
    b = model.b; # collect the biases
    number_of_pixels = length(sₒ); # define the number of pixels
    patience_val = isnothing(patience) ? max(5, Int(round(0.1 * number_of_pixels))) : patience; # scale the patience with the problem size
    min_iterations = max(isnothing(miniterations_before_convergence) ? patience_val : miniterations_before_convergence, patience_val) # floor before declaring miniterations_before_convergence
    S = CircularBuffer{Array{Int32,1}}(patience_val) # buffer to check for convergence 
    # circular buffer: fixed amout of space and recycles when space is overfilled
    
    frames = Dict{Int64, Array{Int32,1}}(); # initialize the dictionary to hold frames
    energydictionary = Dict{Int64, Float32}(); # initialize the dictionary to hold energies
    has_converged = false; # flag for convergence








    frames, energydictionary
end

function decode(simulationstate::Array{T,1};
    number_of_rows::Int64 = 28, number_of_cols::Int64 = 28)::Array{T,2} where T <: Number
    # could do with one line in julia using reshape, julia does it by column so would have to do transpose
    # reshape and searching for -1 and turning to 0
    reconstructed_image = Array{Int32,2}(undef, number_of_rows, number_of_cols);
    linearindex = 1;

    for row in 1:number_of_rows
        for col in 1:number_of_cols

        end
    end
    

    return reconstructed_image
end