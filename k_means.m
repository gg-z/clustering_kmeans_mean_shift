%%
clc, clear;

%%
%input test data
d = 2;
cat = 3;
pnts_per_cat = 1000;
X(1:1000,:) = 0.55*randn(pnts_per_cat, d) + repmat([1,1], [1000,1]);
X(1001:2000,:) = 0.55*randn(pnts_per_cat, d) + repmat([-1,-1], [1000,1]);
X(2001:3000,:) = 0.55*randn(pnts_per_cat, d) + repmat([1,-1], [1000,1]);
figure;
plot(X(:, 1), X(:, 2), 'k.');

% thr = 5.0e-3;
thr = 0.5;

%%
% prepare Yale B data
% folder = './select2/';
% file_output = dir([folder, '*.pgm']);
% 
% for i = 1:size(file_output)
%     
%     img = im2double(imread([folder, file_output(i).name]));
%     %fprintf([file_output(i).name, '\n']);
%     [img_x,img_y] = gradient(img);
%     img_x = reshape(img, [1, size(img_x,1)*size(img_x,2)]);
%     img_y = reshape(img, [1, size(img_y,1)*size(img_y,2)]);
%     grad = [img_x, img_y];
%     X(i,:) = grad;
% end


cntr_cnt = 3;
% sel = [1,65,129];
%sel = [1,4,7];
for i=1:cntr_cnt
    cnters(i, :) = X(ceil(size(X,1)*rand()), :);
%     cnters(i, :) = X(sel(i), :);
end

pnts_blgs_cat = zeros(size(X,1), 1);

ctn_flag = true;

figure;
iter = 0;
while(ctn_flag)
    
    % save pnts belong to which center
    pnts_blgs_cat = zeros(size(X,1), 1);
    
    for i=1:size(X,1)
        
        cur_pnt = X(i, :);
        dis = sum((repmat(cur_pnt,[cntr_cnt, 1]) - cnters).^2, 2);
        [~,idx] = min(dis);
        pnts_blgs_cat(i, 1) = idx;
        
    end
    
    % update center pnts
    last_cnters = cnters;% save last centers 
    for i=1:cntr_cnt
        cnters(i, :) = sum(X(pnts_blgs_cat==i, :),1)/sum(pnts_blgs_cat==i);
        sum(pnts_blgs_cat==i)
    end
    
    % show updated category
    hold off; % clear the content on the figure
    for i=1:cntr_cnt
        plot(cnters(i, 1), cnters(i, 2), 'r^');
        hold on ;
        plot(X(pnts_blgs_cat==i, 1), X(pnts_blgs_cat==i, 2), '.', 'Color', [rand(), rand(), rand()]);
    end    
    
    % test if continue
    dist_last_cur = sum(sum((last_cnters-cnters).^2, 2));
    if(dist_last_cur<thr)
        ctn_flag = false;
    end    
    
    iter = iter +1;
    fprintf('iteration %d\n',iter);

end


%% 
% print the result
% pnts_blgs_cat
