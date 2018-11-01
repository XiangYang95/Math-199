clear 



clear 


%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster_withPUMA_modified.xlsx');

origMat = cell2mat(table2cell(data(1:818,[2,4,5,14,15,40,43,44,45,46])));
origMatName = data(1:818,[2,4,5,14,15,40,43,44,45,46]).Properties.VariableNames;

data1 = readtable('DataByCensusMaster_withPUMA.xlsx');
% origTab = array2table(origMat, 'VariableNames', origMatName);
% Checking correlation between the variables
corr_var = corrcoef(origMat);
corr_var_tab = array2table(corr_var, 'VariableNames', origMatName);
HomePop15 = cell2mat(table2cell(data1(1:818, [1,24])));
HomePop16 = cell2mat(table2cell(data1(1:818, [1,34])));
HomePop17 = cell2mat(table2cell(data1(1:818, [1,44])));


[n,m] = size(origMat);
%%
% normalized by percentile rank
normMatPR = (tiedrank(origMat)-1)./(n-1);

% normalized by percentile rank
normMatZ = (origMat - mean(origMat))./sqrt(var(origMat,1,1));

% Conduct PCA
% for each column, set mean to 0, normalize by unbiased estimator of standard deviation
norm_data = (origMat - mean(origMat))./sqrt(var(origMat,1,1));

% do the SVD: the matrix V is the representation of the data
% that maximizes the variance of the data for each
% dimension 1..num_factors
[U, Sigma, V] = svd(norm_data);

% proj is each tract data projected into a subset of R^num_factors with
% increasingly greater accuracy
proj = norm_data*V;

% get diagonal of matrix and compute total variance
diagonal = diag(Sigma.^2);
totalVariance = sum(diagonal);

% for each subspace, find how much variance it explains
for i=1:length(diagonal)
   variances_explained(i) = sum(diagonal(1:i))/totalVariance; 
end

numOfVectors =7;
%Projected data
proj_optimal = proj(:,1:numOfVectors);

filename = 'CensusTrackCluster.xlsx';
%%

for iter = 1:1
     type = 4;
     switch type
            case 1
                data_used = origMat;

            case 2
                data_used = normMatPR;

            case 3
                data_used = normMatZ;

            case 4
                data_used = proj_optimal;
     end
    
    csMat = [];
    for numClus = 2:3

        %use the Gaussian Mix distribution to cluster
        GMModel = fitgmdist(data_used,numClus,'Options',...
            statset('Display','final','MaxIter',1500,'TolFun',1e-5),...
            'RegularizationValue', 0.01);
        idx = cluster(GMModel, data_used);
        data_used = horzcat(cell2mat(table2cell(data(1:818,1))), data_used);

        for jk = 1:numClus
            display('Cluster size for each clusters');
            display(size(data_used(idx==jk,1)));
            csMat = data_used(idx==jk,1);
            csTab = array2table(csMat, 'VariableNames', {strcat(...
                'Cluster', num2str(jk))});
            colchar = char('A'+jk-1);
            writetable(csTab, filename,'Sheet',numClus-1,'Range',strcat(colchar,...
            num2str(1)))
        end
%         
%         figure
%         hold on
%         plot(data_used(idx==1,1),'xr')
%         plot(data_used(idx==2,1), 'xb')
%         plot(data_used(idx==3,1), '+g')
%         plot(data_used(idx==4,1), '+y')
%         plot(data_used(idx==5,1), '*c')
%         plot(data_used(idx==6,1), 'pm')
%         plot(data_used(idx==7,1), 'dk')
%         plot(data_used(idx==8,1), '<r')
%         plot(data_used(idx==9,1), '>b')
%         plot(data_used(idx==10,1), '.m')
%         hold off
%         legend('First Cluster','Second Cluster')
%         xlabel('Number of tracks in a cluster');ylabel('Track');

%        
% 
%         
%         [pde151,xi151] = ksdensity(HomePop15(idx==1,2));
%         [pde152,xi152] = ksdensity(HomePop15(idx==2,2));
%         if numClus == 3
%             [pde153,xi153] = ksdensity(HomePop15(idx==3,2));
%         end
%         [pde161,xi161] = ksdensity(HomePop16(idx==1,2));
%         [pde162,xi162] = ksdensity(HomePop16(idx==2,2));
%         if numClus == 3
%             [pde163,xi163] = ksdensity(HomePop16(idx==3,2));
%         end
%         [pde171,xi171] = ksdensity(HomePop17(idx==1,2));
%         [pde172,xi172] = ksdensity(HomePop17(idx==2,2));
%         if numClus == 3
%             [pde173,xi173] = ksdensity(HomePop17(idx==3,2));
%         end
%         
%         fig = figure('Name','Homeless Population in 2015 for first cluster')
%         plot(pde151)
%         ylabel('Density');
%         xlabel('HomelessPop');
%         saveas(fig,'1pdf151','png')
%         
%         fig = figure('Name','Homeless Population in 2015 for second cluster')
%         plot(pde152)
%         ylabel('Density');
%         xlabel('HomelessPop');
%         saveas(fig,'1pdf152','png')
%         
%         if numClus == 3
%             fig = figure('Name','Homeless Population in 2015 for third cluster')
%             plot(pde153)
%             ylabel('Density');
%             xlabel('HomelessPop');
%             saveas(fig,'1pdf153','png')
%         end
%         
%         fig = figure('Name','Homeless Population in 2016 for first cluster')
%         plot(pde161)
%         ylabel('Density');
%         xlabel('HomelessPop');
%         saveas(fig,'1pdf161','png')
%         
%         fig = figure('Name','Homeless Population in 2016 for second cluster')
%         plot(pde162)
%         ylabel('Density');
%         xlabel('HomelessPop');
%         saveas(fig,'1pdf162','png')
%         
%         if numClus == 3
%             fig = figure('Name','Homeless Population in 2016 for third cluster')
%             plot(pde163)
%             ylabel('Density');
%             xlabel('HomelessPop');
%             saveas(fig,'1pdf163','png')
%         end
%         fig = figure('Name','Homeless Population in 2017 for first cluster')
%         plot(pde171)
%         ylabel('Density');
%         xlabel('HomelessPop');
%         saveas(fig,'1pdf171','png')
%         
%         fig = figure('Name','Homeless Population in 2017 for second cluster')
%         plot(pde172)
%         ylabel('Density');
%         xlabel('HomelessPop');
%         saveas(fig,'1pdf172','png')
%         
%         if numClus == 3
%             fig = figure('Name','Homeless Population in 2017 for third cluster')
%             plot(pde173)
%             ylabel('Density');
%             xlabel('HomelessPop');
%             saveas(fig,'1pdf172','png')
%         end
%         
        homelesspop151 = sum(HomePop15(idx==1,2));
        homelesspop152 = sum(HomePop15(idx==2,2));
        homelesspop153 = sum(HomePop15(idx==3,2));
        homelesspop161 = sum(HomePop16(idx==1,2));
        homelesspop162 = sum(HomePop16(idx==2,2));
        homelesspop163 = sum(HomePop16(idx==3,2));
        homelesspop171 = sum(HomePop17(idx==1,2));
        homelesspop172 =sum(HomePop17(idx==2,2));
        homelesspop173 =sum(HomePop17(idx==2,2));
        homelesspop161m = (sum(HomePop16(idx==1,2))-sum(HomePop15(idx==1,2)))./sum(HomePop15(idx==1,2));
        homelesspop162m = (sum(HomePop16(idx==2,2))-sum(HomePop15(idx==2,2)))./sum(HomePop15(idx==2,2));
        homelesspop163m = (sum(HomePop16(idx==3,2))-sum(HomePop15(idx==3,2)))./sum(HomePop15(idx==3,2));
        homelesspop171m = (sum(HomePop17(idx==1,2))-sum(HomePop16(idx==1,2)))./sum(HomePop16(idx==1,2));
        homelesspop172m = (sum(HomePop17(idx==2,2))-sum(HomePop16(idx==2,2)))./sum(HomePop16(idx==2,2));
        homelesspop173m = (sum(HomePop17(idx==3,2))-sum(HomePop16(idx==3,2)))./sum(HomePop16(idx==3,2));
        if numClus == 3
        homelessBar1 = [homelesspop161m,homelesspop162m,homelesspop163m...
            ;homelesspop171m, homelesspop172m,homelesspop173m];
        else
        homelessBar1 = [homelesspop161m,homelesspop162m,...
            ;homelesspop171m, homelesspop172m];
        end
        if numClus == 3
        homelessBar = [homelesspop151, homelesspop152,homelesspop153;...
            homelesspop161,homelesspop162,homelesspop163;...
            homelesspop171,homelesspop172,homelesspop173];
        else
        homelessBar = [homelesspop151, homelesspop152;...
            homelesspop161,homelesspop162;...
            homelesspop171,homelesspop172];     
        end
% 
        figure('Name','Changes of homeless population for each cluster from 2015-2017')
        bar([2015,2016],homelessBar1, 'grouped');
        xlabel('Base Year');ylabel('Homeless Count');
        if numClus ==2
          legend('First Cluster', 'Second Cluster', 'Location', 'northwest');
        else
          legend('First Cluster', 'Second Cluster', 'Third Cluster', 'Location', 'northwest');
        end
        
        figure('Name','Total homeless population for each cluster from 2015-2017')
        bar([2015,2016, 2017],homelessBar, 'grouped');
        
        xlabel('Year');ylabel('Homeless Count');
        if numClus ==2
        legend('First Cluster', 'Second Cluster', 'Location', 'northwest');
        else
        legend('First Cluster', 'Second Cluster', 'Third Cluster', 'Location', 'northwest');
        end
        mean(normMatZ(idx==1,:))
        mean(normMatZ(idx==2,:))
        mean(normMatZ(idx==3,:))
    end
end
