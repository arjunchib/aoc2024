using Test

function part1(file::String="input.txt")
    input = open(io -> read(io, String), joinpath(@__DIR__, file))
    "N/A"
end

function part2(file::String="input.txt")
    input = open(io -> read(io, String), joinpath(@__DIR__, file))
    "N/A"
end

@test part1("test.txt") == "N/A"
@test part2("test.txt") == "N/A"

println("Part 1: $(part1())")
println("Part 2: $(part2())")
