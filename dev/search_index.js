var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ProductArrays","category":"page"},{"location":"#ProductArrays","page":"Home","title":"ProductArrays","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ProductArrays.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ProductArrays]","category":"page"},{"location":"#ProductArrays.productArray-Tuple","page":"Home","title":"ProductArrays.productArray","text":"productArray(vectors...)\n\nThe output is a lazy form of\n\ncollect(Iterators.product(vectors...))\n\ni.e. it is an AbstractArray in contrast to Iterators.product(vectors...). So is accessible with getindex and gets default Array implementations for free. In particular it can be passed to Base.PermutedDimsArrayfor lazy permutation andvec()to obtain a lazyBase.ReshapedArray`.\n\nExamples:\n\njulia> A = productArray(1:3, (:a,:b))\n3×2 ProductArrays.ProductArray{Tuple{UnitRange{Int64}, Tuple{Symbol, Symbol}}, Tuple{Int64, Symbol}, 2}:\n (1, :a)  (1, :b)\n (2, :a)  (2, :b)\n (3, :a)  (3, :b)\n\njulia> vec(A)\n6-element reshape(::ProductArrays.ProductArray{Tuple{UnitRange{Int64}, Tuple{Symbol, Symbol}}, Tuple{Int64, Symbol}, 2}, 6) with eltype Tuple{Int64, Symbol}:\n (1, :a)\n (2, :a)\n (3, :a)\n (1, :b)\n (2, :b)\n (3, :b)\n\njulia> sizeof(A) == sizeof(1:3) + sizeof((:a,:b))\ntrue\n\njulia> A == collect(Iterators.product(1:3, (:a,:b)))\ntrue\n\n\n\n\n\n","category":"method"}]
}
