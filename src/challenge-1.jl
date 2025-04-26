#=
Functions for converting bit (or rather byte) streams to Base64, and converting Base64 to the original stream.
=#

# Base64 encoding with padding.
function base64_encode(bytes::Vector{UInt8})::String
end

# Decoding of Base64 with padding.
function base64_decode(base64::AbstractString)::Vector{UInt8}
end