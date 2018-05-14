clear 

%Read data in to a table to make it easy to sort rows
data = readtable('Data2017byCensus_allEstimated.xlsx');

format long
%Select columns and format
origMat = cell2mat(table2cell(data(:,[32,33,34,28,29,30,31,2,3,22])));
[n,m] = size(origMat);
 
% %Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
% normMat = (tiedrank(origMat) -1)/ (n-1);

%Select numTopics, where numTopics is the number of topics
numTopics = 4; 


for numTopics = 4:4 
    %NNMF algorithm in Matlab
    [w,h] = nnmf(origMat,numTopics);

    %W matrix will be weight matrix
    %Pair tract number with topic
    W = data(:,1);
    W(:,2:(numTopics+1)) = array2table(w);
    for j = 2:numTopics+1
    W.Properties.VariableNames{j} = strcat('Topic',num2str(j-1));
    end

    %H matrix will be topic matrix
    H = array2table(h,'VariableNames',{'CoffeeDensity', 'RestaurantDensity', ...
    'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity',...
    'GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'});
    
    %Let A be the adjacency matrix, with dimensions [n, numTopics]
    A =[];
    
    %Variance for each column
    varTop = var(w,1,1);
     
    for rownum1 = 1:n
        Arow = [];
        for rownum2 = 1:n
            %Result for each Topic
            resforTopic = ((w(rownum1,:) - w(rownum2,:)).^2)./(2*varTop);
            sum_rowdiffsqr = sum(resforTopic);
            Arow = horzcat(Arow, exp(-sum_rowdiffsqr));
        end
        A = vertcat(A, Arow);
    end
    
    A = A - eye(n);
    

    % The diagonal component of D
    Ddiag = sum(A);

    % Let D be the Weight Matrix
    D = diag(Ddiag);    
    
    %Let L be the Laplacian matrix
    L = eye(n)-D\A;
    
    %Obtaining the eigenvalues and eigenvectors of L
    [V,E] = eig(L,D,'vector');
    E100 = E(1:100);
    E100 = sortrows(E100, 1);
    %Forming the eigenpair matrix
    eigenpairMat = [];
    
    
    %Create a plot of eigenvalues on its index
    figure()
    indE100 = 1:length(E100);
    scatter(indE100, E100);
    title('Plot of eigenvalue vs its index');
    xlabel('index');ylabel('eigenvalue');
    
    
end


