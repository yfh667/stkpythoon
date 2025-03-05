A1 = [0,1,0;0,0,-1;-1,0,0]
A2=[0,1,0;1,0,0;0,0,1]
syms P
A3 = [cos(P),-sin(P),0;sin(P),cos(P),0;0,0,1]
syms B
A4 = [cos(B),0,sin(B);0,1,0;-sin(B),0,cos(B)]
A5 = [0,1,0;1,0,0;0,0,1]
syms R
A6 = [cos(R),-sin(R),0;sin(R),cos(R),0;0,0,1]
A = A1*A2*A3*A4*A5*A6