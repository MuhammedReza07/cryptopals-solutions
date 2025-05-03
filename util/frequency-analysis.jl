module FrequencyAnalysis

#=
Functions for performing frequency analysis on textual data.
=#

function find_char_frequencies(f::Any, ValueType::Type{<:Integer}, s::AbstractString)::Dict{Char, ValueType}
    frequencies = Dict{Char, ValueType}()

    for c in s
        # Invalid Unicode is probably irrelevant for most analyses.
        if !(isvalid(c) && f(c))
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

function find_char_frequencies_txt(f::Any, ValueType::Type{<:Integer}, file_path::AbstractString)::Dict{Char, ValueType}
    s = open(io -> read(io, String), file_path)
    find_char_frequencies(f, ValueType, s)
end

function find_char_frequencies_dir(f::Any, ValueType::Type{<:Integer}, dir_path::AbstractString)::Dict{Char, ValueType}
    frequencies = Dict{Char, ValueType}()

    txt_files = readdir(dir_path)
    
    for txt in txt_files
        find_char_frequencies_txt(f, ValueType, dir_path * txt) |> f -> mergewith!(+, frequencies, f)
    end

    frequencies
end

function find_char_distribution(frequencies::Dict{Char, <:Integer})::Dict{Char, Float64}
    distribution = Dict{Char, Float64}()

    char_count = values(frequencies) |> sum

    for (c, f) in frequencies
        distribution[c] = f / char_count
    end

    distribution
end

function write_char_distribution(distribution::Dict{Char, Float64}, file_path::AbstractString)
    file = open(file_path, create = true, write = true)

    for (c, p) in distribution
        write(file, "$(c) $(p)\n")
    end

    close(file)
end

function read_char_distribution(file_path::AbstractString)::Dict{Char, Float64}
    distribution = Dict{Char, Float64}()

    # Should have even length.
    data = open(io -> read(io, String), file_path) |> s -> split(s)
    pair_count::Integer = (length(data) / 2)

    for k = 1:pair_count
        # Every key should only consist of a single character.
        distribution[only(data[2 * k - 1])] = tryparse(Float64, data[2 * k])
    end

    distribution
end

end