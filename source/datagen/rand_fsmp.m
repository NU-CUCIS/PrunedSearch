% Copyright (C) 2016, Northwestern University
% See COPYRIGHT notice in top-level directory.
imposed_strain = 0.0005;
maxiter = 10000;
% load data
dataTr = load('ForRegr1percTrain.dat');
dataTe = load('ForRegr1percTest.dat');

Ytr = dataTr(:,end);
Yte = dataTe(:,end);

E_smp = []; F_smp = [];
for k = 1:maxiter
    fsamp = randsample(100,20);
    Xtr = dataTr(:,fsamp);
    Xte = dataTe(:,fsamp);
    
    mdl = LinearModel.fit(Xtr,Ytr);
    ypred = predict(mdl,Xte);

    E_mase = sum(abs((ypred-Yte)./imposed_strain))/n;
    if E_mase < 0.1
        E_smp = [E_smp,E_mase];
        F_smp = [F_smp,fsamp];
    end
end

save('RandomFeatureTest.mat','E_smp','F_smp');    
    