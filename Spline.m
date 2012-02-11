%% Function Spline(xold,yold,xnew)
% Spline is a special function defined piecewise by polynomials. 
% In interpolating problems, spline interpolation is often preferred to 
% polynomial interpolation because it yields similar results, even when 
% using low degree polynomials, while avoiding Runge's phenomenon for higher degrees

function [ynew] = Spline(xold,yold,xnew)
 Cs = cspline(xold,yold);
 ynew = interp(Cs,xold,yold,xnew);
end