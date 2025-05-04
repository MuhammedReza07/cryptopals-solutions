#=
Functions for repeating-key XOR encryption.
=#

function repeating_key_xor(bytes::Vector{UInt8}, key::Vector{UInt8})::Vector{UInt8}
    # A possibly hacky way to get an array of length equal to that of bytes.
    ciphertext = bytes

    key_length = length(key)

    for (i, b) in enumerate(bytes)
        ciphertext[i] = xor(b, key[1 + (i - 1) % key_length])
    end

    ciphertext
end