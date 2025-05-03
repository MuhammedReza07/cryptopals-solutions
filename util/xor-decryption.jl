module XorDecryption

include("frequency-analysis.jl")
using .FrequencyAnalysis

export decode_single_byte_xor_ascii_bytes, PlaintextCandidate

#=
Functions for decrypting single-byte XOR encrypted textual data.
The textual data is assumed to be valid ASCII, since I do not want
to deal with UTF-8 (and since that encoding probably is irrelevant
to this challenge).
=#

struct PlaintextCandidate
    score::Float64
    key::UInt8
    plaintext::String
end

#=
This predicate suffices to exclude non-alphabetic English characters,
numerals, special characters, and whitespace.
=#
isascii_letter(c::Char) = isascii(c) && isletter(c)

#=
Converts a sequence of bytes to an ASCII string.
=#
string_from_ascii_bytes(bytes::Vector{UInt8})::String = Char.(bytes) |> String

function decode_single_byte_xor_ascii_bytes(ValueType::Type{<:Integer}, bytes::Vector{UInt8}, characteristic_distribution::Dict{Char, Float64})::Vector{PlaintextCandidate}
    candidates = Vector{PlaintextCandidate}()

    for key::UInt8 = 0:255
        candidate = xor.(bytes, key) |> string_from_ascii_bytes
        candidate_distribution = candidate |> s -> find_char_frequencies(isascii_letter, ValueType, s) |> find_char_distribution
        # Handle cases when the entire string is invalid ASCII.
        score = 0
        if isempty(candidate_distribution)
            score = Inf
        else
            score = sum(abs(characteristic_distribution[k] - candidate_distribution[k]) for k in keys(candidate_distribution))
        end
        push!(candidates, PlaintextCandidate(score, key, candidate))
    end

    # Sort in ascending order by score.
    sort(candidates, by = c::PlaintextCandidate -> c.score)
end

function decode_single_byte_xor_ascii_bytes(ValueType::Type{<:Integer}, bytes::Vector{UInt8}, distribution_path::AbstractString)::Vector{PlaintextCandidate}
    characteristic_distribution = read_char_distribution(distribution_path)
    decode_single_byte_xor_ascii_bytes(ValueType, bytes, characteristic_distribution)
end

function decode_single_byte_xor_ascii_bytes(ValueType::Type{<:Integer}, hex::AbstractString, characteristic_distribution::Dict{Char, Float64})::Vector{PlaintextCandidate}
    decode_single_byte_xor_ascii_bytes(ValueType, hex2bytes(hex), characteristic_distribution)
end

function decode_single_byte_xor_ascii_bytes(ValueType::Type{<:Integer}, hex::AbstractString, distribution_path::AbstractString)::Vector{PlaintextCandidate}
    decode_single_byte_xor_ascii_bytes(ValueType, hex2bytes(hex), distribution_path)
end

end