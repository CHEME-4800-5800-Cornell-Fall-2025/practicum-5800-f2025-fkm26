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

    frames[0] = copy(sₒ); # copy the initial state 
    energydictionary[0] = _energy(sₒ, W, b); # imput initial energy
    s = copy(sₒ); # define first state (initial)
    iteration_counter = 1; # set iteration counter

    while has_converged == false # while not converged
        i = rand(1:number_of_pixels); # select a random pixel
        s[i] = dot(W[i, :], s) - b[i] ≥ 0 ? Int32(1) : Int32(-1) # compute the state 
        
        state_snapshot = copy(s); # copy current state
        frames[iteration_counter] = state_snapshot; # input current state into frames 
        push!(S, state_snapshot); # push current state into buffer 

        energydictionary[iteration_counter] = _energy(s, W, b); # calculate current energy 

        if (length(S) == patience_val) && (iteration_counter ≥ min_iterations) # if the amount of past states in the buffer equals patience and minimum iterations have been reached
            all_equal = true; # initialize variable
            first_state = S[1]; # collect the first state in the buffer
            for state in S # for all states in s
                if (hamming(first_state, state) != 0) # if any state has a difference from the first state that is not zero 
                    all_equal = false; # then they are not all equal
                    break; # exit the for loop early
                end
            end
            if all_equal == true # if they are all equal
                has_converged = true; # then it has converged, end loop
            end
        end

        if energydictionary[iteration_counter] ≤ trueenergyvalue # if the current energy is less than or equal to the true energy value
            has_converged = true; # then it has converged, end loop
            @info "true energy minimum has been reached" # notify that the true energy minimum was reached
        end

        iteration_counter += 1 # increment iteration counter
        if iteration_counter > maxiterations # if the iteration counter is greater than the maximum number of iterations 
            has_converged = true; # then end loop
            @warn "maxmimum number of iterations has been reached with no convergence" # notify that the maximum number of iterations was reached 
        end
    end

    frames, energydictionary
end

function decode(simulationstate::Array{T,1};
    number_of_rows::Int64 = 28, number_of_cols::Int64 = 28)::Array{T,2} where T <: Number    

    binary = Int32.(simulationstate .!= -1) # convert -1 to 0 and 1 to 1
    reconstructed_image = reshape(binary, number_of_cols, number_of_rows)' # reshape the transposed matrix back into the image
    
    return reconstructed_image
end

# chatGPT was used for troubleshooting and major bug fixes throughout this code