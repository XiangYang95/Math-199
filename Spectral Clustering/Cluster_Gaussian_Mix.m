clear

data = readtable('2017DataByCensusMaster_estimated_updated_yang.xlsx');

origMat = cell2mat(table2cell(data(1:818,[1:33, 43:50, 60:98])));

%Do a non-negative matrix factorization with 4 topics
k = 4;
[w,h] = nnmf(origMat(:,2:end),k);

%normalize the original matrix so that the mean is 0 and the standard
%deviation is 1
%w = (w - mean(w))/sqrt(var(w,1,1));

%run this iteration 5 times
for jk = 1:5
    %we want to see 4 clusters
    GMModel = fitgmdist(w,k);
    idx = cluster(GMModel, w);
    
    w = horzcat(origMat(:,1),w);
    
    figure
    hold on
    plot(w(idx==1,1),'xr')
    plot(w(idx==2,1), 'xb')
    plot(w(idx==3,1), '+g')
    plot(w(idx==4,1), '+c')
    hold off
    
    display('Cluster size for each clusters');
    for clus = 1:k
        display(length(w(idx==clus,1)));
    end
end

% %to see the values easier, we normalize w by percentile rank
% w = (tiedrank(w)-1)/(818-1);
% 
% clus1 = w(idx==1,:);
% clus2 = w(idx==2,:);
% clus3 = w(idx==3,:);
% clus4 = w(idx==4,:);
% clusters = {clus1,clus2,clus3,clus4};
% 
% for clus = 1:4
%     display(strcat('The top 20 values for each topic for the',...
%         ' cluster',num2str(clus)));
%     clusW = clusters{clus};
%     display('topic 1');
%     top1 = sortrows(clusW(:,1),-1);
%     display(top1(1:20));
%     display('topic 2');
%     top2 = sortrows(clusW(:,2),-1);
%     display(top2(1:20));
%     display('topic 3');
%     top3 = sortrows(clusW(:,3),-1);
%     display(top3(1:20));
%     display('topic 4');
%     top4 = sortrows(clusW(:,4),-1);
%     display(top4(1:20));
% end
%     
    
    
    