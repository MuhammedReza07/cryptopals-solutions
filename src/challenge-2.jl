#=
Functions that produce the XOR combination of two buffers of equal length.
=#

function xor_buffers(a::Vector{UInt8}, b::Vector{UInt8})::Vector{UInt8}
    if length(a) != length(b)
        ArgumentError("buffers must be of equal length") |> throw
    end

    xor.(a, b)
end

xor_buffers(a::AbstractString, b::AbstractString)::String = xor_buffers(hex2bytes(a), hex2bytes(b)) |> bytes2hex