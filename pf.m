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
% Description: Particle filter for likelihood estimation
%
% =======================================================================


function ll = pf(data,sys,theta,par)

% =======================================================================
% Initalisation
% =======================================================================

N     = par.Npart;            % Set the number of particles
y     = data.y;               % Extract the measurements
u     = data.u;               % Extract the inputs

% Helpers
lognormpdf = @(x,m,s) (-1/2)*log(2*pi*s.^2)-(1/2)*(x-m).^2./s.^2;

% Initialize variables
p     = zeros(sys.T,N);       % Particles
a     = zeros(sys.T,N);       % Ancestors
w     = zeros(sys.T,N);       % Unnormalised weights
W     = zeros(sys.T,N);       % Normalised weights
xhat  = zeros(sys.T,1);       % Filtered state estimate

% Set some initial values
a(1,:) = 1:N;             % Ancestors
W(1,:) = ones(N,1)/N;     % Weights
p(1,:) = par.xo;          % Initial state

% =======================================================================
% Particle filter
% =======================================================================

for t = 1:sys.T
    if t ~= 1
        % resample
        nidx = resampling(W(t-1,:),2);

        % propagate
        p(t,:) = sys.f( theta , p(t-1,nidx), t ) ...
               + sys.fu( theta , u(t-1), t ) ...
               + sys.fn( theta , p(t-1,nidx), t ) .* randn(1,N);

        % set ancestors
        a(t,:) = nidx;
     end

    % calculate log-weights
    w(t,:) = lognormpdf( y(t), sys.g(theta,p(t,:),t) + sys.gu(theta,u(t),t), sys.gn(theta,p(t,:),t) );
    wmax   = max( w(t,:) ); 
    W(t,:) = exp( w(t,:) - wmax );

    % calculate log-likelihood
    llp(t)  = wmax + log( sum( W(t,:) ) ) - log(N);

    % estimate state trajectory x
    W(t,:)  = W(t,:) ./ sum( W(t,:) );
    xhat(t) = sum( p(t,:) .* W(t,:) , 2 );
end

% =======================================================================
% Generate output
% =======================================================================

ll     = sum(llp);

end
% =======================================================================
% End of PF
% =======================================================================

% Helper for resampling
function i = resampling(q, type)
    M = length(q);
    if(type == 1) % -- Multinomial, 'simple' from 'sigsys/resample.m'
        u = rand(M,1);
        qc = cumsum(q);
        qc = qc(:);
        qc=qc/qc(M);
        [~,ind1]=sort([u;qc]);
        ind2=find(ind1<=M);
        i=ind2'-(0:M-1);
    elseif(type == 2) % -- Systematic
        qc = cumsum(q);
        u = ((0:M-1)+rand(1))/M;
        i = zeros(1,M); k = 1;
        for j = 1:M
            while(qc(k)<u(j))
                k = k + 1;
            end
            i(j) = k;
        end
    elseif(type == 3) % -- Stratified
        u=([0:M-1]'+(rand(M,1)))/M;
        qc=cumsum(q);
        qc=qc(:);
        [~,ind1]=sort([u ; qc]);
        ind2=find(ind1<=M);
        i = ind2'-(0:M-1);
    else
        error('No such resampling type');
    end
end
