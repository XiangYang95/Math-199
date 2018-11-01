%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster_withPUMA_2yrRatio_succint.xlsx');
 
%Select columns and format
origMat = cell2mat(table2cell(data(:,[5:8,39:40,43,44,84:end])));
origMatName = data(:,[1,5:8,39:40,43,44,84:end]).Properties.VariableNames;
[n,m] = size(origMat);

%%
%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat = (tiedrank(origMat)-1) / (n-1);
 
filename = 'TopCensusTracksWithCorrTopicsandHomeless.xlsx';
%Select k
format short
for k = 3:5
 
    %NNMF algorithm in Matlab
    [w,h] = nnmf(normMat,k);

    %W matrix will be weight matrix
    %Pair tract number with topic
    W = data(:,1);
    W(:,2:(k+1)) = array2table(w);
    W = cell2mat(table2cell(W));
    
    %H matrix will be topic matrix
    H = array2table(h,'VariableNames',origMatName(2:end));
    
    %Inspect top 10 rows sorted by each topic
    W = sortrows(W,-2);
    disp(W(1:3,2))
    cstractTab = W(1:10,1);
    for j = 3:k+1
        W = sortrows(W,-j);
        disp(W(1:3,j));
        cstractTab = horzcat(cstractTab, W(1:10,1));
    end
    
    homelesspop = cell2mat(table2cell(data(:,[1,26])));
    homelesspop = sortrows(homelesspop, -2);
    cstractTab = horzcat(cstractTab, homelesspop(1:10,1));
    
    cstractTab = array2table(cstractTab);
     for j = 1:k+1
        cstractTab.Properties.VariableNames{j} = strcat('Topic',num2str(j));
     end
    
     cstractTab.Properties.VariableNames{k+1} = 'Homeless';
     disp(cstractTab)

     %writing to excel
     A = num2str(k);
     
     formatSpec = 'No. of topics: ';
     disp(strcat(formatSpec, A));

     xlswrite(filename, {strcat(formatSpec, A)},k-1,'A1');
          
    disp('The top 10 census tracts for each topics and the homeless population density');
     xlswrite(filename, {'The top 10 census tracts for each topics and the homeless population density'},k-1,'A2');
     
     disp(cstractTab);
     writetable(cstractTab,filename,'Sheet',k-1,'Range','A3')

    
    disp('The topic matrix')
    index3 = strcat('A',num2str(15));
    xlswrite(filename, {'The topic matrix'},k-1,index3);
    
    disp(H)
    index4 = strcat('A',num2str(16));
    writetable(H,filename,'Sheet',k-1,'Range',index4)
  
end




  