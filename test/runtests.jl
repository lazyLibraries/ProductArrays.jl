using ProductArrays
using Test

random_tuple(n) = map(x->abs(x)%floor(Int,10^(7/n)), map(rand, ntuple(x->Int, n)))

@testset "ProductArrays.jl" begin
    @testset "Ensure identical behavior to collected Base.product with v=$v" for v in [
        (1:3, 4:10),
        (rand(3,2),[:a,:b]),
        map(x->rand(x), random_tuple(1)),
        map(x->rand(x), random_tuple(2)),
        map(x->rand(x), random_tuple(3)),
        map(x->rand(x), random_tuple(4)),
    ]
		p = productArray(v...)

		@testset "Test Type Functions" begin
			@test Base.IteratorSize(typeof(p)) == Base.IteratorSize(typeof(p.prodIt))
			@test Base.IteratorEltype(typeof(p)) == Base.IteratorEltype(typeof(p.prodIt))
			@test Base.eltype(typeof(p)) == Base.eltype(typeof(p.prodIt))
		end

		c = collect(Base.product(v...))
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
		end
	end
end
