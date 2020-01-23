% Copyright (C) 2016, Northwestern University
% See COPYRIGHT notice in top-level directory.
clear all
warning off

randsize = 1000;
propFunc = @SeparateOptE;

disp('Program Step 1: Random data generation.');

disp('Property function used:');
disp(propFunc);

disp('Specified size of data to be generated:');
disp(randsize);


constraint = [0.0159822999947858,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00613766636477021,0.00613766636477021,0.00376140480720866,0.00376140480720866,0.00376140480720866,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00454084416782057,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00541192129558303,0.00495535011431222,0.00495535011431222,0.00541192129558303,0.00495535011431222,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00495535011431222,0.00541192129558303,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777];

% all random
% keep the entries that <= 1
% 
% datam = [];
% 
% while size(datam,1) < 100
%     a = rand(1,75)./constraint(1:75);
% 
%     if a*constraint(1:75)' <= 1
%        dr = [a,(1 - a*constraint(1:75)')/constraint(76)];
%        opt = materialOpt(dr);
%        datam = [datam;dr,opt];
%     end
% 
% end

% nothing can be found
data_RandEvery5 = [];

tic

for i = 1:randsize
    
remainFac = 1:1:75;
setFac = zeros(1,75);
thsd = 1;

outerLp = 1;
while isempty(remainFac) == 0
    
    if length(remainFac) < 5
        r = 1;
    else
        r = 5;
    end
    
    randDraw = randsample(length(remainFac),r);
    randFac = remainFac(randDraw);
    remainFac(randDraw) = [];
    
    randFacRand = rand(1,r).*thsd;
    
    innerLp(outerLp) = 1;
    while sum(randFacRand) > thsd
        randFacRand = rand(1,r).*thsd;
        innerLp(outerLp) = innerLp(outerLp) + 1;
    end
    
    thVector(outerLp) = thsd;
    
    thsd = thsd - sum(randFacRand); 
    
    setFac(randFac) = randFacRand./constraint(randFac);
    
    outerLp = outerLp + 1;
end

odf = [setFac,thsd/constraint(end)];
if (odf>=0) == true(1,length(odf))
    % display('Yes!')
    %checksum(i) = constraint*odf';
    %if constraint*odf' == 1
        data_RandEvery5 = [data_RandEvery5;odf,propFunc(odf)];
    %else
%         display('outbound wrong');
%         return
    %end
else
%     display('negative wrong');
%     return
end

end

t = toc;

[s,ind] = sort(data_RandEvery5(:,77));
dataSort = data_RandEvery5(ind,:);

for i = 1:randsize
if dataSort(i,77) == s(i)
    continue
else
    disp('sorting not right!')
    break
end
end

dataOri_E_REk = data_RandEvery5;
%dataSort(:,77) = s;
dataPolar_E_REk = [dataSort(1:300,:);...
    dataSort(end-300+1:end,:)];
t_E_REk = t;

dataPolar = dataPolar_E_REk;

[m,n] = size(dataPolar);
saveloc = '../../data/data_demo.mat';
save(saveloc,'dataPolar','dataOri*','t_*')

fprintf('Data of size %d (rows) x %d (column) are generated, and saved at %s\n', m, n, saveloc);

exit;

