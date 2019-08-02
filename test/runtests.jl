using Jenks
using Test

@testset "SimpleRandom" begin
    data = randn(10_000)
    n = 10
    JR = JenksClassification(n,data)
    @test minimum(data) < JR.centres[1]
    @test maximum(data) > JR.centres[end]
    @test minimum(data) == JR.bounds[1]
    @test maximum(data) == JR.bounds[end]
    @test JR.breaks[1] == 1
    @test JR.breaks[end] == length(data)+1
    @test JR.ARE > 0.0
    @test JR.GVF >= 0.0 && JR.GVF <= 1.0
    @test sum(JR.n_in_class) == length(data)
end
