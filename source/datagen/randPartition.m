% Copyright (C) 2016, Northwestern University
% See COPYRIGHT notice in top-level directory.
function [data,t] = randPartition(fsize,dsize,func)

% fsize: how many factors are used (how many partitions to be made)
constraint = [0.0159822999947858,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00613766636477021,0.00613766636477021,0.00376140480720866,0.00376140480720866,0.00376140480720866,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00454084416782057,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00541192129558303,0.00495535011431222,0.00495535011431222,0.00541192129558303,0.00495535011431222,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00495535011431222,0.00541192129558303,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777];

%tic;
data = [];
for j = 1:dsize
%     if mod(j,10000)==0
%         disp(j/10000)
%         t(j/10000) = toc;
%     end
    cutsize = fsize - 1;
    randSep = sort(rand(1,cutsize));
    randIntvl = diff([0,randSep,1]);
    
    randInd = randperm(76,fsize);
    
    odf = zeros(1,76);
    odf(1,randInd) = randIntvl./constraint(randInd);

    %data = [data;odf,-func(odf)];
    data = [data;odf,func(odf)];
end
