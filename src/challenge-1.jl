#=
Functions for converting bit (or rather byte) streams to Base64, and converting Base64 to the original stream.
A function for converting a stream given as a string of hexadecimal digits to bytes is also provided.
=#

const BASE64_ALPHABET::String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
const BASE64_PADDING::Char = '='

# The padding character '=' throws an error.
function base64_char_value(c::AbstractChar)::UInt8
    # ASCII to Base64 conversion: c - 0x41.
    if 'A' <= c <= 'Z'
        c - 0x41
    # ASCII to Base64 conversion: c - 0x47.
    elseif 'a' <= c <= 'z'
        c - 0x47
    # ASCII to Base64 conversion: c + 0x4.
    elseif '0' <= c <= '9'
        c + 0x4
    elseif c == '+'
        0x3e
    elseif c == '/'
        0x3f
    else
        DomainError(c, "argument must be in the Base64 alphabet") |> throw
    end
end

# Base64 encoding with padding.
function base64_encode(bytes::Vector{UInt8})::String
    base64 = ""
    bottom = 1
    top = bottom + 2

    # Perform Base64 encoding.
    while top <= length(bytes)
        # Triple binary structure: 0b00000000 00000000 00000000
        # Base64 binary structure: 0b000000 000000 000000 000000
        triple = view(bytes, bottom:top)
        base64 *= 
            BASE64_ALPHABET[1 + (triple[1] & 0xfc) >>> 2] *
            BASE64_ALPHABET[1 + (triple[1] & 0x3) >>> -4 + (triple[2] & 0xf0) >>> 4] *
            BASE64_ALPHABET[1 + (triple[2] & 0xf) >>> -2 + (triple[3] & 0xc0) >>> 6] *
            BASE64_ALPHABET[1 + (triple[3] & 0x3f)]
        bottom = top + 1
        top = bottom + 2
    end

    # Add padding if necessary.
    remainder = view(bytes, bottom:length(bytes))

    if length(remainder) == 0
        return base64
    elseif length(remainder) == 1
        base64 *= 
            BASE64_ALPHABET[1 + (remainder[1] & 0xfc) >>> 2] *
            BASE64_ALPHABET[1 + (remainder[1] & 0x3) >>> -4] *
            BASE64_PADDING *
            BASE64_PADDING
    else
        base64 *= 
            BASE64_ALPHABET[1 + (remainder[1] & 0xfc) >>> 2] *
            BASE64_ALPHABET[1 + (remainder[1] & 0x3) >>> -4 + (remainder[2] & 0xf0) >>> 4] *
            BASE64_ALPHABET[1 + (remainder[2] & 0xf) >>> -2] *
            BASE64_PADDING
    end

    base64
end

base64_encode(s::AbstractString)::String = base64_encode(Vector{UInt8}(s))

# Where hex is a string of hexadecimal digits.
base64_encode_hex(hex::AbstractString)::String = base64_encode(hex2bytes(hex))

# Decoding of Base64 with padding.
function base64_decode(base64::AbstractString)::Vector{UInt8}
    bytes::Vector{UInt8} = []
    bottom = 1
    top = bottom + 3

    # Decode Base64.
    while top < length(base64)
        quad = base64_char_value.(base64[k] for k = bottom:top)
        append!(bytes, [
            (quad[1] >>> -2) + (quad[2] >>> 4)
            (quad[2] & 0xf) >>> -4 + (quad[3] & 0x3c) >>> 2
            (quad[3] & 0x3) >>> -6 + quad[4]
        ])
        bottom = top + 1
        top = bottom + 3
    end

    # Handle trailing padding.
    if base64[top] == '=' && base64[top - 1] == '='
        pair = base64_char_value.(base64[k] for k = bottom:(top - 2))
        push!(bytes, (pair[1] >>> -2) + (pair[2] >>> 4))
    elseif base64[top] == '='
        triple = base64_char_value.(base64[k] for k = bottom:(top - 1))
        append!(bytes, [
            (triple[1] >>> -2) + (triple[2] >>> 4)
            (triple[2] & 0xf) >>> -4 + (triple[3] & 0x3c) >>> 2
        ])
    else
        quad = base64_char_value.(base64[k] for k = bottom:top)
        append!(bytes, [
            (quad[1] >>> -2) + (quad[2] >>> 4)
            (quad[2] & 0xf) >>> -4 + (quad[3] & 0x3c) >>> 2
            (quad[3] & 0x3) >>> -6 + quad[4]
        ])
    end

    bytes
end