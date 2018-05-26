% clear

% dataRalph = readtable('AllRalphsStores.csv');
% dataTrader = readtable('AllTraderJoesStores.csv');
% dataWhole = readtable('AllWholeFoods.csv');
%
% RalphLong = cell2mat(table2cell(dataRalph(:,2)));
% RalphLat = cell2mat(table2cell(dataRalph(:,3)));
% TraderLong = cell2mat(table2cell(dataTrader(:,2)));
% TraderLat = cell2mat(table2cell(dataTrader(:,3)));
% WholeLong = cell2mat(table2cell(dataWhole(:,2)));
% WholeLat = cell2mat(table2cell(dataWhole(:,3)));

%finding the shortest distanc
[RalphX,RalphY] = sp_proj('California 5','forward',RalphLong,RalphLat,'sf');
[TraderX,TraderY] = sp_proj('California 5','forward',TraderLong,TraderLat,'sf');
[WholeX,WholeY] = sp_proj('California 5','forward',WholeLong,WholeLat,'sf');

