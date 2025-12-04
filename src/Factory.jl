# throw(ErrorException("Oppps! No methods defined in src/Factory.jl. What should you do here?"))
function build(modeltype::Type{MyClassicalHopfieldNetworkModel}, data::NamedTuple)::MyClassicalHopfieldNetworkModel

    # initialization:
    model = modeltype();
    linearimagecollection = data.memories;
    number_of_rows, number_of_cols = size(linearimagecollection);
    W = zeros(Float32, number_of_rows, number_of_rows);
    b = zeros(Float32, number_of_rows); # the clssical Hopfield network has zero bias

    # compute weights with Hebbian learning rule
    for j in 1:number_of_cols 
        Y = ⊗(linearimagecollection[:,j], linearimagecollection[:,j]); # calculate outer product 
        W += Y; # add to weight matrix
    end

    for i in 1:number_of_rows
        W[i,i] = 0.0f0; # make diagonal weights equal to zero, ensure no self-coupling
    end
    WN = (1/number_of_cols)*W; # implement Hebbian scaling

    energy = Dict{Int64, Float32}(); #initialize energy
    for i in 1:number_of_cols
        energy[i] = _energy(linearimagecollection[:,i], WN, b); # compute energy dictionary
    end

    model.W = WN; # populate model with weight
    model.b = b; # populate model with bias
    model.energy = energy; # populate model with energy

    return model;
end