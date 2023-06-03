using ProductArrays
using OffsetArrays: OffsetArray
using InfiniteArrays: ∞
using Test

random_tuple(n) = map(x -> abs(x) % floor(Int, 10^(6 / n)) + 1, map(rand, ntuple(x -> Int, n)))

@testset "ProductArrays.jl" begin
    @testset "Ensure identical behavior to collected Base.product" for v in [
        (1:3, 4:10),
        (rand(3, 2), (:a, :b)),
        (1:2, "abc"),
        map(x -> rand(x), random_tuple(1)),
        map(x -> rand(x), random_tuple(2)),
        map(x -> rand(x), random_tuple(3)),
        map(x -> rand(x), random_tuple(4)),
    ]
        p = productArray(v...)
        pIt = Iterators.product(v...)

        @testset "Test Type Functions" begin
            @test Base.IteratorSize(typeof(p)) == Base.IteratorSize(typeof(pIt))
            @test Base.IteratorEltype(typeof(p)) == Base.IteratorEltype(pIt)
            @test Base.eltype(typeof(p)) == Base.eltype(pIt)
        end

        c = collect(pIt)
        @testset "Test Entries and Access" begin
            @test p == c # same shape and entries
            cart_idx = map(first, axes(p))
            @test p[cart_idx...] == c[cart_idx...] # cartesian access
            @test p[1] == c[1] # linear access
            @test p[:] == c[:] # colon access
            @test p[1:lastindex(p)] == vec(c) # range access
            @test reverse(p) == reverse(c)
            @test last(p) == p[map(last, axes(p))...]
        end

        @testset "Sanity Checks" begin
            @test axes(p) == axes(c)
            @test size(p) == map(length, axes(p))
            @test length(p) == reduce(*, size(p))
            @test axes(p, 1) == axes(p)[1]
            @test ndims(p) == ndims(c)
        end
    end
    @testset "OffsetArrays" begin
        v = (OffsetArray(rand(3), -1:1), OffsetArray(rand(3, 2), 0:2, 0:1))
        p = productArray(v...)
        itProd = Iterators.product(v...)
        c = collect(itProd)
        @test axes(p[-1, 0, :], 1) == 0:1
        @test p == c
        @test collect(p) isa Array
        @test collect(p) == collect(c)
    end
    @testset "InfiniteArrays" begin
        p = productArray(1:∞, 0:∞)
        @test ndims(p) == 2
        @test p[1, 1] == (1, 0)
    end
end
