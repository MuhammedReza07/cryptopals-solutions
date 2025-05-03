include("../util/xor-decryption.jl")
include("../util/frequency-analysis.jl")

using .XorDecryption, .FrequencyAnalysis

#=
Functions for identifying single-byte XOR encrypted textual data.
=#

function identify_single_byte_xor_ascii_bytes(
    ValueType::Type{<:Integer}, 
    bytes::Vector{Vector{UInt8}}, 
    distribution_path::AbstractString,
    candidate_count::Integer,
    min_score::Float64,
    max_score::Float64)::Vector{Tuple{Integer, PlaintextCandidate}}
    candidates = Vector{Tuple{Integer, PlaintextCandidate}}()
    characteristic_distribution = read_char_distribution(distribution_path)

    for (i, b) in enumerate(bytes)
        top_candidates = decode_single_byte_xor_ascii_bytes(ValueType, b, characteristic_distribution)[1:candidate_count] |> v -> map(c -> (i, c), v)
        append!(candidates, top_candidates)
    end

    sort(candidates, by = ((i, c),) -> c.score) |> c -> filter(((i, c),) -> min_score <= c.score <= max_score, c)
end

function identify_single_byte_xor_ascii_bytes(
    ValueType::Type{<:Integer}, 
    hex::Vector{<:AbstractString}, 
    distribution_path::AbstractString,
    candidate_count::Integer,
    min_score::Float64,
    max_score::Float64)::Vector{Tuple{Integer, PlaintextCandidate}}
    identify_single_byte_xor_ascii_bytes(ValueType, hex2bytes.(hex), distribution_path, candidate_count, min_score, max_score)
end

function identify_single_byte_xor_ascii_bytes(
    ValueType::Type{<:Integer}, 
    hex_path::AbstractString, 
    distribution_path::AbstractString,
    candidate_count::Integer,
    min_score::Float64,
    max_score::Float64)::Vector{Tuple{Integer, PlaintextCandidate}}
    hex = open(io -> read(io, String), hex_path) |> s -> split(s, ['\n'])
    identify_single_byte_xor_ascii_bytes(ValueType, hex, distribution_path, candidate_count, min_score, max_score)
end