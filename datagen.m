% =======================================================================
% 
% Particle Bayesian Optimisation for Parameter Inference
% Hull-White Stochastic Volaility model
%
% Reproduces example in 
% J. Dahlin and F. Lindsten, 
% Particle filter-based Gaussian Process Optimisation for Parameter Inference. 
% Proceedings of the 18th World Congress of the International Federation of 
% Automatic Control (IFAC), Cape Town, South Africa, August 2014. 
% (submitted, pending review) 
%
% Copyright (c) 2013 Johan Dahlin [ johan.dahlin (at) liu.se ]
% Date: 2013 - 11 -29
%
% Description: Generates data from a state space model
%
% =======================================================================

function data = datagen(sys,u)

if nargin == 1;
    u = zeros(sys.T,1);
end

% generate data
x    = zeros(sys.T+1,1); 
y    = zeros(sys.T,1);

for t=1:sys.T
    x(t+1) = sys.f(sys,x(t),t) + sys.fu(sys,u(t),t) + sys.fn(sys,x(t),t) * randn;
    y(t)   = sys.g(sys,x(t),t) + sys.gu(sys,u(t),t) + sys.gn(sys,x(t),t) * randn;
end

data.x   = x(1:sys.T); 
data.u   = u;
data.y   = y;
data.f0  = sys.f; 
data.g0  = sys.g;
data.fn0 = sys.fn; 
data.gn0 = sys.gn;

% =======================================================================
% End of file
% =======================================================================
