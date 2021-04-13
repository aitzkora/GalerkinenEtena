using GalerkinEtena
using Test
using LinearAlgebra

@testset "Jacobi functions" begin
    x = [ -8.385864502265894e-01, -5.857254804559920e-01, -2.613290131006463e-01, 9.639069017068973e-02, 4.452559470863178e-01,  7.449277954410395e-01];
    w = [ 3.640915066793222e-02, 2.148950338971699e-01, 3.935534533149237e-01, 3.151164618818836e-01, 1.085195495207685e-01, 1.100558293610547e-02];
    @test JacobiGQ(3.14, 2., 5).points ≈ x atol=1e-12
    @test JacobiGQ(3.14, 2., 5).weights ≈ w atol=1e-12
    peval_check = [ 1.492369633161560e+01; 1.522362625780301e+03; 1.385512703514001e+04]
    @test JacobiP([1.,2,3],2.,3.14,5) ≈ peval_check atol=1e-11
    @test Legendre(8, [0.65])[1][:,9] ≈ JacobiP([0.65], 0., 0., 8) atol=1e-12
end

@testset "integrate" begin
   q = JacobiGQ(0.,0.,10)
   @test integrate(x->x*x, q) ≈ 2/3. atol=1.e-12


end
@testset "integrate_2D" begin
   r = [0.651824324731524,   0.678892143848201,   0.767509779873077]
   s = [1.000000000000000,   0.857038037030953,   0.262430410050662]
   a = [ -1.0            ,   22.48725645592459,   3.792794616151358]
   b = [ 1.0             ,   0.857038037030953,   0.262430410050662]

   @test norm(rsToAb(r,s) .- (a,b)) < 1e-13

   # warpfactor

   rout = [-1.0, -1/3., 1/3., 1.0, -2/3., 0.0, 2/3., -1/3., 1/3.,  0]
   N = 3 
   warp_f1 = [0, -0.128115294937453, 0.128115294937453, 0, -0.256230589874905
               , -0.000000000000000, 0.256230589874905, -0.128115294937453
               ,  0.128115294937453, 0]

   @test norm(WarpFactor(N, rout) - warp_f1) < 1e-12

   # Nodes2D
   x = [ -1.0,  -0.447213595499958,  0.447213595499958, 1.0,  -0.723606797749979,
         -0.0,   0.723606797749979, -0.276393202250021, 0.276393202250021, 0]

   y = [ -0.577350269189626, -0.577350269189626, -0.577350269189626, -0.577350269189626, -0.098623200025929,
         -0.0,  -0.098623200025929, 0.675973469215554, 0.675973469215554, 1.154700538379252]
   
   @test norm(nodes2D(N) .- (x,y)) < 1e-12

   r = [-1.0, -0.447213595499958, 0.447213595499958, 1.0,  -1.0,
        -1/3., 0.447213595499958, -1.0, -0.447213595499958,  -1.0 ]

   s = [-1.0, -1.0, -1.0, -1.0, -0.447213595499958,
        -1/3., -0.447213595499958, 0.447213595499958, 0.447213595499958, 1.0]

   @test norm(xyToRs(x,y) .- (r,s) ) < 1e-12

   @testset "computeElementaryMatrices2D" begin

     𝓥, 𝓓ᵣ, 𝓓ₛ =  computeElementaryMatrices2D(r, s, N)

     V = [
0.707106781186547  -1.000000000000000   1.224744871391589  -1.414213562373096  -1.732050807568877   2.121320343559642  -2.449489742783177 2.738612787525831  -3.162277660168380  -3.741657386773944
0.707106781186547  -1.000000000000000   1.224744871391589  -1.414213562373096  -0.774596669241484   0.948683298050514  -1.095445115010332 -0.547722557505165   0.632455532033675   1.673320053068151
0.707106781186547  -1.000000000000000   1.224744871391589  -1.414213562373096   0.774596669241483  -0.948683298050513   1.095445115010331 -0.547722557505167   0.632455532033677  -1.673320053068151
0.707106781186547  -1.000000000000000   1.224744871391589  -1.414213562373096   1.732050807568877  -2.121320343559642   2.449489742783177 2.738612787525831  -3.162277660168380   3.741657386773944
0.707106781186547  -0.170820393249937  -0.547722557505166   0.632455532033676  -1.253323738405180  -0.586318522754564   1.262814235459896 1.433956271953544   1.547753776541970  -1.417659498582050
0.707106781186547  -0.000000000000000  -0.680413817439772   0.419026240703139  -0.000000000000000  -0.000000000000000   0.000000000000000 -0.608580619450185  -0.936971158568409   0.000000000000001
0.707106781186547  -0.170820393249937  -0.547722557505166   0.632455532033676   1.253323738405180   0.586318522754565  -1.262814235459896 1.433956271953544   1.547753776541972   1.417659498582049
0.707106781186547   1.170820393249937   0.547722557505165  -0.632455532033677  -0.478727069163697  -1.535001820805078  -2.242610132573165 0.209211400561955   0.982068351592733  -0.079003456127528
0.707106781186547   1.170820393249937   0.547722557505166  -0.632455532033676   0.478727069163697   1.535001820805078   2.242610132573165 0.209211400561954   0.982068351592731   0.079003456127528
0.707106781186547   2.000000000000000   3.674234614174767   5.656854249492381                   0                   0                   0 0                   0                   0
    ]

    Dr = [
          -3.000000000000000   4.045084971874736  -1.545084971874735   0.499999999999999  -0.000000000000000  -0.000000000000001   0.000000000000000  0.000000000000000  -0.000000000000000   0.000000000000000  
-0.809016994374948   0.000000000000000   1.118033988749895  -0.309016994374947  -0.000000000000000   0.000000000000000   0.000000000000000  -0.000000000000000  -0.000000000000000  -0.000000000000000 
0.309016994374948  -1.118033988749896   0.000000000000002   0.809016994374946   0.000000000000000   0.000000000000000  -0.000000000000000   0.000000000000000   0.000000000000000  -0.000000000000000
-0.500000000000000   1.545084971874737  -4.045084971874735   2.999999999999999  -0.000000000000000  -0.000000000000000  -0.000000000000000  0.000000000000000  -0.000000000000000   0.000000000000000  
-0.709016994374947   1.618033988749895  -1.309016994374946   0.599999999999999  -2.000000000000000   2.699999999999999  -0.618033988749894  -0.190983005625052  -0.190983005625052   0.100000000000000 
0.333333333333333  -0.621129993749942   0.621129993749941  -0.333333333333333  -0.727231663541638   0.000000000000001   0.727231663541637   -0.106101669791696   0.106101669791696   0.000000000000000
-0.600000000000001   1.309016994374949  -1.618033988749894   0.709016994374947   0.618033988749896  -2.700000000000000   1.999999999999999  0.190983005625053   0.190983005625052  -0.100000000000000  
0.409016994374948  -0.190983005625053  -0.618033988749895   0.599999999999999  -1.309016994374947   2.699999999999998  -1.309016994374946   -2.000000000000000   1.618033988749896   0.100000000000000
-0.600000000000000   0.618033988749895   0.190983005625052  -0.409016994374947   1.309016994374947  -2.699999999999998   1.309016994374946  -1.618033988749895   2.000000000000000  -0.100000000000000 
-0.500000000000001   0.000000000000001  -0.000000000000000   0.500000000000000   1.545084971874739   0.000000000000000  -1.545084971874739  -4.045084971874738   4.045084971874741  -0.000000000000001 

]

   Ds = [
  -3.000000000000001  -0.000000000000000   0.000000000000000   0.000000000000000   4.045084971874737   0.000000000000000  -0.000000000000000   -1.545084971874737   0.000000000000000   0.499999999999999 
  -0.709016994374947  -1.999999999999999  -0.190983005625053   0.100000000000000   1.618033988749895   2.699999999999999  -0.190983005625053   -1.309016994374948  -0.618033988749894   0.600000000000000 
   0.409016994374948  -1.309016994374948  -1.999999999999999   0.099999999999999  -0.190983005625053   2.700000000000000   1.618033988749894   -0.618033988749895  -1.309016994374948   0.600000000000000 
  -0.500000000000000   1.545084971874739  -4.045084971874735  -0.000000000000002  -0.000000000000000   0.000000000000000   4.045084971874737    0.000000000000000  -1.545084971874739   0.500000000000000 
  -0.809016994374948   0.000000000000000   0.000000000000000   0.000000000000000   0.000000000000000  -0.000000000000000   0.000000000000000    1.118033988749895  -0.000000000000000  -0.309016994374947 
   0.333333333333333  -0.727231663541638  -0.106101669791696                   0  -0.621129993749942   0.000000000000000   0.106101669791696    0.621129993749942   0.727231663541637  -0.333333333333333 
  -0.600000000000001   1.309016994374948  -1.618033988749894  -0.100000000000001   0.618033988749895  -2.700000000000001   1.999999999999999    0.190983005625053   1.309016994374948  -0.409016994374947 
   0.309016994374948  -0.000000000000000   0.000000000000000  -0.000000000000000  -1.118033988749896  -0.000000000000001  -0.000000000000000    0.000000000000001   0.000000000000000   0.809016994374947 
  -0.600000000000000   0.618033988749894   0.190983005625052  -0.099999999999999   1.309016994374947  -2.699999999999998   0.190983005625051   -1.618033988749894   2.000000000000001   0.709016994374946 
  -0.500000000000000   0.000000000000001  -0.000000000000000   0.000000000000000   1.545084971874737  -0.000000000000000  -0.000000000000001   -4.045084971874738   0.000000000000001   3.000000000000000 
 ]


     @test norm(V-𝓥) < 1e-12
     @test norm(𝓓ᵣ-Dr) < 1e-12
     @test norm(𝓓ₛ-Ds) < 1e-12

   end
   @testset "Lift2D" begin

    mask = [
            1                   4                   1
            2                   7                   5
            3                   9                   8
            4                  10                  10
           ]

    𝓔₃ =𝓔(mask, r, s)

    e₁₁ = [
           0.142857142857143   0.053239713749995  -0.053239713749995   0.023809523809524
           0.053239713749995   0.714285714285715   0.119047619047619  -0.053239713749995
           -0.053239713749995   0.119047619047619   0.714285714285715   0.053239713749995
           0.023809523809524  -0.053239713749995   0.053239713749995   0.142857142857143
          ]
    
    e₂₁ = zeros(6,4)

    e₁₂ = [ zeros(1,4)  [0.142857142857143   0.053239713749995  -0.053239713749995   0.023809523809524];
            zeros(2,8) ;
            [0.142857142857143   0.053239713749995  -0.053239713749995  0.023809523809524] zeros(1,4) ]


    e₂₂ = [ 0  0 0 0   0.053239713749995   0.714285714285715   0.119047619047619 -0.053239713749995 
            0  0 0 0                   0                   0                   0                  0 
            0.053239713749995   0.714285714285714   0.119047619047619  -0.053239713749995  0 0 0 0 
            0 0 0  0  -0.053239713749995   0.119047619047619   0.714285714285715 0.053239713749995 
           -0.053239713749995   0.119047619047619   0.714285714285715   0.053239713749995  0 0 0 0 
            0.023809523809524  -0.053239713749995   0.053239713749995   0.142857142857143   0.023809523809524  -0.053239713749995   0.053239713749995 0.142857142857143 
          ] 

   @test norm(𝓔₃ - [e₁₁ e₁₂; e₂₁ e₂₂]) < 1e-12
   end

end

@testset "assemble" begin
  m = SimplexMesh{1}([0., 0.5, 1.5, 3.0, 2.5], [1 2;2 3;3 5 ;5 4])
  e2e = [1 2; 1 3; 2 4; 3 4]
  e2f = [1 1; 2 1; 2 1; 2 2]
  @test connect(m) == (e2e,e2f)

  m2 = SimplexMesh{2}([0 0; 1. 0; 0 1; 1 1; 2 0.5], [1 2 3; 2 4 3; 2 5 4])
  e2e2 = [1 2 1; 3 2 1; 3 3 2]
  e2f2 = [1 3 3; 3 2 2; 1 2 1]

  @test connect(m2) == (e2e2, e2f2)

end




@testset "RK4" begin
   f=(x,y)->[x[1,1]  0. ; 0. 2*x[2,2]]
   sol=rk4(f,[1 2; 3 1.],0., 1.,1e-3)
   @test sol ≈ [exp(1.) 2 ; 3 exp(2.)] atol=1e-4
end

@testset "Discretization" begin
    P_check = [1, 10, 9, 19, 18, 28, 27, 37, 36, 46, 45, 55, 54, 64, 63, 73, 72, 82, 81, 90]
    M_check = [1, 9, 10, 18, 19, 27, 28, 36, 37, 45, 46, 54, 55, 63, 64, 72, 73, 81, 82, 90]
    m = Mesh1D(0., 1.,  10)
    ξ = RefGrid{1}(0., 0., 8)
    x, vmapM, vmapP = Discretize(m, ξ)
    @test vmapM == M_check
    @test vmapP == P_check
end
#@testset "Advec1D" begin
#   u_final =[
#-7.18408237e-11 1.98669331e-01 3.89418342e-01 5.64642473e-01 7.17356091e-01 8.41470985e-01 9.32039086e-01 9.85449730e-01 9.99573603e-01 9.73847631e-01 ;
# 1.00240326e-02 2.08483569e-01 3.98631523e-01 5.72887296e-01 7.24303860e-01 8.46844716e-01 9.35624545e-01 9.87103975e-01 9.99230686e-01 9.71521222e-01 ;
# 3.22757657e-02 2.30198224e-01 4.18943405e-01 5.90986635e-01 7.39469092e-01 8.58471251e-01 9.43248869e-01 9.90422132e-01 9.98110390e-01 9.66007136e-01 ;
# 6.36452071e-02 2.60643087e-01 4.47249949e-01 6.16026367e-01 7.60243758e-01 8.74152629e-01 9.53211794e-01 9.94269412e-01 9.95688646e-01 9.57412917e-01 ;
# 9.98334167e-02 2.95520207e-01 4.79425539e-01 6.44217687e-01 7.83326910e-01 8.91207360e-01 9.63558185e-01 9.97494987e-01 9.91664810e-01 9.46300088e-01 ;
# 1.35890006e-01 3.30007713e-01 5.10969055e-01 6.71559672e-01 8.05377325e-01 9.07087125e-01 9.72634224e-01 9.99405466e-01 9.86333565e-01 9.33939658e-01 ;
# 1.66933425e-01 3.59487507e-01 5.37709957e-01 6.94495607e-01 8.23593909e-01 9.19858121e-01 9.79450493e-01 9.99995264e-01 9.80673380e-01 9.22255142e-01 ;
# 1.88835130e-01 3.80166032e-01 5.56340914e-01 7.10336239e-01 8.36012700e-01 9.28359973e-01 9.83696463e-01 9.99816080e-01 9.76076184e-01 9.13423211e-01 ;
# 1.98669331e-01 3.89418342e-01 5.64642473e-01 7.17356091e-01 8.41470985e-01 9.32039086e-01 9.85449730e-01 9.99573603e-01 9.73847631e-01 9.09297427e-01 ;
#  ]
#  a = 2π
#  α = 1.
#  Np = 9
#  K = 10
#  ad = Advec1D(0., 2., K, Np)
#  f = (x,t) -> rhs1D(ad, x, t, a, α)
#  u = sin.(ad.x)
#  tFinal = 10.
#  xₘᵢₙ = minimum(abs.(ad.x[1, :]- ad.x[2,:]))
#  CFL = 0.75
#  dt = CFL ./ (2π) * xₘᵢₙ
#  dt *= 0.5
#  u = rk4(f, u, 0., tFinal, dt)
#  using LinearAlgebra
#  @test norm(u_final-u) < 1e-8
#end

#@testset "Maxwell1D" begin
#E1=[ 
#3.385869202032191e-05 4.526692168096674e-01  2.805527250091301e-01 -2.773789722196313e-01 -4.516163177950441e-01;
#5.048915438902341e-02 4.660152878835446e-01  2.384202237558333e-01 -3.174143540595392e-01 -4.440420603967090e-01;
#1.558310829364448e-01 4.767961262322121e-01  1.390023982779091e-01 -3.926887363404605e-01 -4.311861955849840e-01;
#2.803310549782955e-01 4.532117708925854e-01 -1.500025472381084e-03 -4.565703654323375e-01 -4.125063513298208e-01;
#3.799059249144263e-01 3.900235377047584e-01 -1.387689429760913e-01 -4.715240742407457e-01 -3.717755350612110e-01;
#4.343660641963593e-01 3.193745821869441e-01 -2.350938134811906e-01 -4.593846076050846e-01 -3.173651740098322e-01;
#4.527277511665667e-01 2.805202580137144e-01 -2.775039240661136e-01 -4.516945226029138e-01 -2.851350374345268e-01;
#]
#E2=[
#-2.864352863680749e-01 -1.422059726180498e-02 -1.174430769418755e-01 -4.052750420841433e-03  1.264600143644388e-01;
#-2.459592268901120e-01 -3.907942922338522e-02 -1.089944535364194e-01  9.414565077130191e-03  1.286277707624082e-01;
#-1.417104103771918e-01 -6.968432878990674e-02 -9.104065224261977e-02  3.456205178427398e-02  1.237137786875264e-01;
# 2.306455034341034e-03 -1.025914813939781e-01 -6.589925705058178e-02  6.403892268715325e-02  9.991861693725035e-02;
# 5.132686808058452e-02 -1.274218633678368e-01 -4.092087963897927e-02  9.895379444297982e-02  5.844819670039177e-02;
# 1.090834810744881e-02 -1.242356787886844e-01 -1.700048087478925e-02  1.208655509811961e-01  1.912069266436495e-02;
#-1.567324312512593e-02 -1.170605142916132e-01 -4.210045083810123e-03  1.264286847805281e-01  2.925944370238357e-05;
#]
#E_check = [E1 E2]
#Np = 7
#K = 10
#pb = Maxwell1D(-2.0, 2.0, K, Np)
#f = (x,t) -> rhs1D(pb, x, t)
#E = sin.(π .* pb.x) .* (pb.x .< 0) 
#H = zeros(Np, K)
#u = [ E ; H ]
#tFinal = 10.
#xₘᵢₙ = minimum(abs.(pb.x[1, :]- pb.x[2,:]))
#CFL = 1.
#dt = CFL * xₘᵢₙ
#u = rk4(f, u, 0., tFinal, dt)
#  using LinearAlgebra
#  @test norm(u[1:7,:]-E_check) < 1e-8
#end
