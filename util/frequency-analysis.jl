module FrequencyAnalysis

#=
Functions for performing frequency analysis on textual data.
=#

function find_char_frequencies(ValueType::Type{<:Integer}, s::AbstractString)::Dict{Char, ValueType}
    frequencies = Dict{Char, ValueType}()

    for c in s
        # Invalid Unicode is probably irrelevant for most analyses.
        if !isvalid(c)
            continue
        end

        k = lowercase(c)
        if haskey(frequencies, k)
            frequencies[k] += 1
        else
            frequencies[k] = 1
        end
    end

    frequencies
end

function find_char_frequencies_txt(ValueType::Type{<:Integer}, file_path::AbstractString)::Dict{Char, ValueType}
    s = open(io -> read(io, String), file_path)
    find_char_frequencies(ValueType, s)
end

function find_char_frequencies_dir(ValueType::Type{<:Integer}, dir_path::AbstractString)::Dict{Char, ValueType}
    frequencies = Dict{Char, ValueType}()

    txt_files = readdir(dir_path)
    
    for txt in txt_files
        find_char_frequencies_txt(ValueType, dir_path * txt) |> f -> mergewith!(+, frequencies, f)
    end

    frequencies
end

function find_char_percentages(frequencies::Dict{Char, <:Integer})::Dict{Char, Float64}
    percentages = Dict{Char, Float64}()

    char_count = values(frequencies) |> sum

    for (c, f) in frequencies
        percentages[c] = f / char_count
    end

    percentages
end

#=
Convenience for analysis of English text. Letters with diacritics, 
numerals, special characters, and whitespace should be excluded.
=#
function find_ascii_letter_percentages_dir(ValueType::Type{<:Integer}, dir_path::AbstractString)::Dict{Char, Float64}
    f = find_char_frequencies_dir(ValueType, dir_path) |> d -> filter(((c, f),) -> isascii(c) && isletter(c), d)
    find_char_percentages(f)
end

end