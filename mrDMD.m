function tree = mrDMD(Xraw, dt, r, max_cyc, L)

% Inputs:
% Xraw :        n by m matrix of raw data (n measurements, m snapshots)
% dt :          time step of sampling
% r :           rank of truncation
% max_cyc :     to determine rho, the frequency cutoff, compute the oscillations
%               of max_cyc in the time window
% L :           number of levels remaining in the recursion

T = size(Xraw, 2) * dt;
rho = max_cyc / T; % high freq cutoff at this level
sub = ceil(1 / rho / 8 / pi / dt); % 4x Nyquist for rho

%% DMD at this level
Xaug = Xraw(:, 1:sub:end); % subsample
Xaug = [Xaug(:, 1:end - 1); Xaug(:, 2:end)]; % not sure what this does
X = Xaug(:, 1:end - 1);
Xp = Xaug(:, 2:end);

[U, S, V] = svd(X, 'econ');
r = min(size(U, 2), r);
U_r = U(:, 1:r); % rank truncation
S_r = S(1:r, 1:r);
V_r = V(:, 1:r);

Atilde = U_r' * Xp * V_r / S_r;
[W, D] = eig(Atilde); % eigendecomposition
lambda = diag(D);
Phi = Xp * V(:, 1:r) / S(1:r, 1:r) * W;

%% Compute power of modes

Vand = zeros(r, size(X,r)); % Vandermonde matrix
for k = 1:size(X, 2)
    Vand(:, k) = lambda.^(k - 1);
end

% the next 5 lines follow Jovanovic et al, 2014 code:
% I have no idea what this is doing
G = S_r * V_r';
P = (W'*W).*conj(Vand*Vand');
q = conj(diag(Vand * G' * W));
Pl = chol(P, 'lower');
b = (Pl')\(Pl\q); 

%% consolidate slow modes, where abs(omega) < rho
omega = log(lambda) / sub / dt / 2 / pi;
mymodes = find(abs(omega) <= rho);

thislevel.T = T;
thisleve.rho = rho;
thislevel.hit = numel(mymodes) > 0;
thislevel.omega = omega(mymodes);
thislevel.P = abs(b(mymodes));
thislevel.Phi = Phi(:, mymodes);

%% recurse on halves
if L > 1
    sep = floor(size(Xraw, 2) / 2);
    nextlevel1 = mrDMD(Xraw(:, 1:sep), dt, r, max_cyc, L - 1);
    nextlevel2 = mrDMD(Xraw(:, sep+1:end), dt, r, max_xyx, L-1);
else
    nextlevel1 = cell(0);
    nextlevel2 = cello(0);
end

%% reconcile indexing on output
% (because MATLAB does not support recursive data structures)
tree = cell(L, 2^(L - 1));
tree{1,1} = thislevel;

for l = 2:L
    col = 1;
    for j = 1:2^(l - 2)
        tree{1, col} = nextlevel1{l - 1, j};
        col = col + 1;
    end
    for j = 1:2^(l - 1)
        tree{l, col} = nextlevel2{l - 1, j};
        col = col + 1;
    end
end
