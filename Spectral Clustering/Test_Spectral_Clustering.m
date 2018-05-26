clear

cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Spectral Clustering'

x1 = randn(1000,1);
y1 = randn(1000,1);
z1 = randn(1000,1);
w1 = ones(1000,1);
x2 = 2+randn(1000,1);
y2 = 1.5+ 2.*randn(1000,1);
z2 = 1.75 + 3.*randn(1000,1);
w2 = 2.*ones(1000,1);
x3 = 4+3*randn(1000,1);
y3 = 5*randn(1000,1);
z3 = 4+2*randn(1000,1);
w3 = 3*ones(1000,1);
x4 = 10*randn(1000,1);
y4 = 5*randn(1000,1);
z4 = 2+2*randn(1000,1);
w4 = 4*ones(1000,1);

%  xlin = linspace(min(x1), max(x1), 500);
%  ylin = linspace(min(y1), max(y1), 500);
%  [X,Y]=meshgrid(xlin,ylin);
%  Z = griddata(x1,y1,z1,X,Y,'cubic');
% 
%  figure()
%  %figure('name', strcat('Type: ', num2str(o), 'No.Topic ', num2str(k), ': Topic', ...
%  %num2str(topic)) ,'NumberTitle','off');
%  %mesh(X,Y,Z) %interpolated
%  %axis tight; 
%  hold on;
%  plot3(x1,y1,z1,'+r','MarkerSize',1)
%  plot3(x2,y2,z2,'xb','MarkerSize',1)
%  plot3(x3,y3,z3,'xc','MarkerSize',1)
%   plot3(x4,y4,z4,'+g','MarkerSize',1)
%  xlabel('x');ylabel('y');zlabel('z');
 
%Aggregating the data together
x = [x1;x2;x3;x4];
y = [y1;y2;y3;y4];
z = [z1;z2;z3;z4];
w = [w1;w2;w3;w4];
data = [x,y,z,w];
[n,~] = size(data);

%Let A be the adjacency matrix, with dimensions [n, numTopics]
A =[];

%Variance for each column
varTop = var(data,1,1);

for rownum1 = 1:n
    Arow = [];
    for rownum2 = 1:n
        %Result for each Topic
        resforTopic = ((data(rownum1,:) - data(rownum2,:)).^2)./(2*varTop);
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
L = D-A;

%%
%Obtaining the eigenvalues and eigenvectors of L
[V,E] = eig(L,D,'vector');
E20 = E(1:20);
E20 = sortrows(E20, 1);

%Create a plot of eigenvalues on its index
figure()
indE20 = 1:length(E20);
scatter(indE20, E20);
title('Plot of eigenvalue vs its index');
xlabel('index');ylabel('eigenvalue');

%normalized V
normV = (V - mean(V))./sqrt(var(V));

%normalized V by row
U = [];
for rownum = 1:n
    Urow = V(rownum,:)./norm(V(rownum,:));
    U = vertcat(U,Urow);
end

%%
%number of cluster
numClus = 4;

%Forming the eigenpair matrix
eigenpairMat = horzcat(E,normV');
eigenpairMat = sortrows(eigenpairMat, 1);
eigenpairMatChosen = eigenpairMat(1:numClus,:);

%obtain only the eigenvector matrix
eigenvecMat = eigenpairMatChosen(:,2:end)';
idx = kmeans(eigenvecMat, numClus);

for n = 1:numClus
    display(size(data(idx==n,1)));
end