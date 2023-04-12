%% Script for calculating notch filter component values
% Oskari Ponkala
% 5.2.2023
%
% The component names are as described in linkwitzlab.com/crossovers.htm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms x L Ca Ra
%% parameters
A= -6;
f0= 770;
Q = 2.3;

%% filter calculations
R3=solve((1-10^(A/20))*x==10^(A/20)*1000);
eq1=1/(2*pi)*1/(sqrt(L*Ca))==f0;
eq2= 2*pi*f0/R3*L==Q;
eq3 = 22*10^-9*Ra*(100000-Ra)==L;
eqs = [eq1 eq2 eq3];
sol = solve(eqs,[L,Ca,Ra]);

%% printing
fprintf("the parameters are: \nR3=%d, \nCa=%d, \nRa=%d\n",double(R3(1))-double(sol.Ra(1)),double(sol.Ca(1)),double(sol.Ra(1)));
