function [] = test_ranking(data, y,path,txtname,algorithm,m,gamma)
%%
folder_now = pwd;
addpath([folder_now,'\feature selection']);
addpath([folder_now,'\feature selection\FScore']);
addpath([folder_now,'\feature selection\FSLib_v4.0_2016\lib']);
addpath([folder_now,'\feature selection\FSLib_v4.0_2016\methods']);
addpath([folder_now,'\feature selection\HSICLasso']);
addpath([folder_now,'\feature selection\RFS']);
addpath([folder_now,'\function']);

%将标签label中的cell字符串数据转化成double数值型数据

[ nc_y ] = n2nc( y );


%numF = size(data, 2);
numF = 50;
if size(data,2)<numF
    numF=size(data,2);
end

%调用FeatureSelection函数
% norm:1 2
if ~exist(path)
    mkdir(path);
end

for alg=algorithm
    switch alg
        case 1
            %调用relief(reliefF)函数
            [rankedrf, relieff_weight] = reliefF( data,y, 10);
            save ([path '\' txtname '_reliefF.mat'],'rankedrf','relieff_weight');
        case 2
            %RFS聂老师
            [rankedrs, rfs] = RFS_sort(data', nc_y, 1);
            save ([path '\' txtname '_RFS_sort.mat'],'rankedrs','rfs');
        case 3
            % HSICLasso
            [rankedh,hsic] = HSICLasso(data',y,2,1);
            save ([path  '\' txtname '_HSICLasso.mat'],'rankedh','hsic');
        case 4
            %fsvFS
            [rankedfsv , fsvw] = fsvFS( data, y, size(data,2),1);
            save ([path  '\' txtname '_fsvFS.mat'],'rankedfsv','fsvw');
        case 5
            % mRMR
            dx=discretize(data',20);
            [rankedm, mrmr] = mRMR( dx', y, numF);
            save ([path  '\' txtname '_mRMR.mat'],'rankedm','mrmr');
        case 6
            % fisher
            [ranked_fisher, fisher_feature_value ] = fisher(data,y);
            save ([path '\' txtname '_fisher.mat'],'ranked_fisher','fisher_feature_value');
        case 7
            %LDA
            rankedLDA=zeros(length(m),size(data,2));
            for i=1:length(m)
                try
                    W=LDA(data',y,m(i));
                    SW=sum(W.*W,2);  
                    [~,rank] = sort(SW,'descend');
                    rankedLDA(i,:)=rank;
                catch err
                    disp(err);
                    rankedLDA(i,:)=NaN;
                end
                
            end
            save ([path '\' txtname '_lda.mat'],'rankedLDA');
            
        case 8
            %LDFA
            rankedLDFS=zeros(length(m),size(data,2));
            for i=1:length(m)
                try
                    W=LDFS(data',y,m(i));
                    SW=sum(W.*W,2);  
                    [~,rank] = sort(SW,'descend');
                    rankedLDFS(i,:)=rank;
                catch err
                    disp(err);
                    rankedLDA(i,:)=NaN;
                end
                
            end
            save ([path '\' txtname '_ldfs.mat'],'rankedLDFS');
        case 9
            rankedsfcg=zeros(length(m),length(gamma),size(data,2));
            SW=zeros(length(m),length(gamma), size(data, 2));
            OBJ=zeros(length(m),length(gamma),50);
            for i=1:length(m)
                disp(m(i))
                for j=1:length(gamma)
                    try
                        [rank,sw,~,obj]=RLDA(data',y,m(i),gamma(j));
                        rankedsfcg(i,j,:)=rank;
                        SW(i,j,:)=sw;
                        OBJ(i,j,:)=obj;
                    catch err
                        disp(err);
                        SW(i,j,:)=NaN;
                        OBJ(i,j,:)=NaN;
                        rankedsfcg(i,j)=NaN;
                    end
                end
            end
            
            %save
            save ([path '\' txtname '_sfcg.mat'],'SW','rankedsfcg','OBJ','m','gamma');
    end
end