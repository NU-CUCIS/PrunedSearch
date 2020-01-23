% Copyright (C) 2016, Northwestern University
% See COPYRIGHT notice in top-level directory.

%This function calls global optimization tool patternsearch to perform optimization
%   Since the pattern search algorithm requires a starting point (odf0), in
%   this program we enumerate different starting points incrementally,
%   firstly with a relatively wide interval (10). After the initial best
%   starting point is found, additional searches are done by refining the
%   interval to a smaller value (1).
%   Note that the starting point does NOT have to meet the constraint.
%
%The function patternsearch initially deals with minimization, in order to
%   transform it into maximization, firstly the fhandle gives the negative
%   of what we really want, and secondly, we change it back after obtaining
%   it.

%INPUT: 
% fhandle: function handle of the function to be minimized
%   for example, patternSearch_min(@materialOpt)

%OUTPUTS:
% bestOpt: the maximum property obtained 
% bestOdf: the ODF ( or ODFs if size(bestOdf,1)>1 ) that leads to maximal
%   property


clc
%warning off
warning('off')
warning off verbose
%global fid


constraint = [0.0159822999947858,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00818178632407973,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00613766636477021,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00572645585112265,0.00613766636477021,0.00613766636477021,0.00613766636477021,0.00376140480720866,0.00376140480720866,0.00376140480720866,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00454084416782057,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416700527,0.00454084416700527,0.00454084416782057,0.00454084416782057,0.00541192129558303,0.00495535011431222,0.00495535011431222,0.00541192129558303,0.00495535011431222,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00541192129558303,0.00495535011431222,0.00541192129558303,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777,0.00398197813454777];


% load feature rank & reduced feature range  
% feature_ranges
% sorted_feature_ids
load('../model_output/demo_modelout.mat')
%fhandle = @SeparateOptE;
fhandle = @SeparateOptY;

% upper bound
for i = 1:76
    lb(1,i) = feature_ranges(i,1);
    ub(1,i) = min(1/constraint(i),feature_ranges(i,2));
    bigStep = (ub-lb)/1;
    %smallStep = 100;
end

% starting from each variable (others set to 0)
bestOpt = 9999; % For minimization, we set initial result to be a very low value.
bestOdf = [];

%for jj = 1: 76 % for each variable
for jj = 1: 5 % for each variable
    j = sorted_feature_ids(jj)+1;
    %fprintf(fid, sprintf( ' #### Current Varialbe --------------- %d\n', j ) );
    fprintf(sprintf( ' #### Current Varialbe --------------- %d\n', j ) );
    clear temp*
    %searchRangeWide = 0:bigStep:1/constraint(j); 
    %searchRangeWide = lb(j):bigStep(j):ub(j); 
    searchRangeWide = [lb(j),ub(j)]; 
    %searchRangeWide = [lb(j),ub(j)]; 

    %fprintf('Out of search');
    %fprintf(sprintf('\n%d\n', length(searchRangeWide)));
    for i = 1:length(searchRangeWide)
    	fprintf(sprintf( ' #### wide search ---- %d\n', i ) );
        % starting point: everyone 0 except the variable to be searched
        odf0 = [zeros(1,j-1),searchRangeWide(i),zeros(1,76-j)];
        % search with pattern_search
        %[odf,opt] = patternsearch(fhandle,odf0,[],[],constraint,1,zeros(1,76),ub);
	%options = optimoptions('patternsearch','Display',false);
	
        %[odf,opt] = patternsearch(fhandle,odf0,[],[],constraint,1,lb,ub);
	opts1=  optimset('display','off');
        [odf,opt] = patternsearch(fhandle,odf0,[],[],constraint,1,lb,ub,opts1);
        %[odf,opt] = patternsearch(fhandle,odf0,-constraint,1,[],[],lb,ub);
        
        %odf = fmincon('Proper2Opt',odf0,[],[],constraint,1,zeros(1,76),ub);
        % save the best objective found
        fprintf('In big search\n');
	fstr = ['tempOpt(i) = ',func2str(fhandle),'(odf);'];
        eval(fstr);
        % save the best solution found
        tempOdf(i,:) = odf;
    end
    
    tempInd = find(tempOpt == min(tempOpt)); % the best among all starting points
    
    % handle multiple bests
        
    %if length(tempInd) > 1
    %    tempInd = tempInd(1);
    %end
    
    if ismember(1,tempInd) % one of the best is at the beginning
        expOpt = min(tempOpt);
        expOdf = tempOdf(tempInd,:);
        
    elseif ismember(length(searchRangeWide),tempInd) % one of the best is at the end
        % test the real end
        testOdf = [zeros(1,j-1),1/constraint(j),zeros(1,76-j)];
        fstr = ['testOpt = ',func2str(fhandle),'(testOdf);'];
        eval(fstr);
        if testOpt < min(tempOpt)
            expOpt = testOpt;
            expOdf = testOdf;
        else
            expOpt = min(tempOpt);
            expOdf = tempOdf(tempInd,:);
        end
    else
        test2Opt = [];
        test2Odf = [];
        for rs_iter = 1: length(tempInd)
            clear temp_indEach searchRangeNarrow
            temp_IndEach = tempInd(rs_iter);
            % re-search
	    smallStep = (searchRangeWide(temp_IndEach+1) - searchRangeWide(temp_IndEach-1)) / 1;
            %searchRangeNarrow = searchRangeWide(temp_IndEach-1):smallStep:searchRangeWide(temp_IndEach+1);
            searchRangeNarrow = [searchRangeWide(temp_IndEach-1),searchRangeWide(temp_IndEach+1)];
            for k = 1:length(searchRangeNarrow)   
        	fprintf('In small search\n');
    		fprintf(sprintf( ' #### narrow search ---- %d\n', k ) );
		odf0 = [zeros(1,j-1),searchRangeNarrow(k),zeros(1,76-j)]; 
                %odf = fmincon('Proper2Opt',odf0,[],[],constraint,1,zeros(1,76),ub);
                %[odf,opt] = patternsearch(fhandle,odf0,[],[],constraint,1,zeros(1,76),ub);
                [odf,opt] = patternsearch(fhandle,odf0,[],[],constraint,1,lb,ub);
                % [odf,opt] = patternsearch(@Proper2Opt,odf0,[],[],constraint,1,zeros(1,76),ub);
                fstr = ['temp2Opt(k) = ',func2str(fhandle),'(odf);'];
                eval(fstr);
                temp2Odf(k,:) = odf;
            end
            test2Opt = [test2Opt,min(temp2Opt)];
            test2Odf = [test2Odf;temp2Odf(find(temp2Opt == min(temp2Opt)),:)];
        end
        
        testOpt = min(test2Opt);
        testOdf = test2Odf(find(test2Opt == min(test2Opt)),:);
        
        if testOpt < min(tempOpt)
            expOpt = testOpt;
            expOdf = testOdf;
        else
            expOpt = min(tempOpt);
            expOdf = tempOdf(tempInd,:);
        end
    end
        
        
    if expOpt < bestOpt
        bestOpt = expOpt;
        bestOdf = expOdf;
    elseif expOpt == bestOpt
        bestOdf = [bestOdf;expOdf];
    end
%         tmin = find(tempOpt == min(tempOpt));
%         if length(tmin) > 1
%             for k = 1:length(tmin)
%                 bestOdf = [bestOdf;tempOdf(tmin(k),:);];
%             end
%         else
%             bestOdf = [bestOdf;tempOdf(tmin,:);];
%         end
end  

fprintf(sprintf( ' #### Program ends. Best value found: %f\n', bestOpt ) );
exit;

