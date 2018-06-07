%%
clc, clear;

%%
% input data
h = 0.8;
ms_thresh = 0.00003;


cat = 3;
pnts_per_cat = 1000;
N = cat*pnts_per_cat;
d = 2;
X(1:1000,:) = 0.55*randn(pnts_per_cat, d) + repmat([1,1], [1000,1]);
X(1001:2000,:) = 0.55*randn(pnts_per_cat, d) + repmat([-1.5,-1.5], [1000,1]);
X(2001:3000,:) = 0.55*randn(pnts_per_cat, d) + repmat([1,-1.5], [1000,1]);
figure;
plot(X(:, 1), X(:, 2), 'k.');

%%
% prepare Yale B data
% folder = './select2/';
% file_output = dir([folder, '*.pgm']);
% for i = 1:size(file_output)
%     
%     img = im2double(imread([folder, file_output(i).name]));
%     %fprintf([file_output(i).name, '\n']);
%     img = reshape(img, [1, size(img,1)*size(img,2)]);
%     X(i,:) = img + 0.5;
% end


X_status = zeros(size(X,1), 1);
X_v_t = zeros(size(X,1), 1);


%% 
% randomly select an un-visited point

find_categray = true;
cat_num = 1;
figure; % show the progress
while(find_categray)
    unvisited_idx = find(X_status==0);
    rand_s = unvisited_idx(ceil(size(unvisited_idx, 1)*rand()));
    cur_x = X(rand_s, :);

    mv_flag = true;
    cur_coverd_pnts_tms = zeros(size(X,1), 1);
    
    % figure
    clr = [rand(), rand(), rand()];
    plot(X(:, 1), X(:,2), 'k.');
    hold on;
    while(mv_flag)
        % pnts in sphere at present
        delt = sum((X - repmat(cur_x, [size(X,1), 1])).^2, 2);
        X_in_sphere = (delt - h^2) <= 0;
        X_status(X_in_sphere) = 1;  % update visit status
        cur_coverd_pnts_tms(X_in_sphere) =  cur_coverd_pnts_tms(X_in_sphere)+1; % update visit times
        gauss = exp(-(delt(X_in_sphere)/h).^2);
        sum_x_gaus = sum(X(X_in_sphere, :).*repmat(gauss, [1, size(X, 2)]), 1);
        sum_gaus = sum(gauss);
        mean_shft = sum_x_gaus/sum_gaus - cur_x;
        cur_x = cur_x + mean_shft;
        
        % figure
        plot(X(X_in_sphere, 1), X(X_in_sphere,2), 'k.', 'Color', clr);
        hold on;

        % change flag 
        if(sum(mean_shft.^2) < ms_thresh)
            mv_flag = false;            
        end
    end
    
    % save pnt_visit info at last catagory
    pnts_vist_tms(:,cat_num) = cur_coverd_pnts_tms;
    % save the meanshift center
    category_cnt(cat_num,:) = cur_x;
    cat_num = cat_num+1;
    
    % change flag
    if(size(find(X_status==0), 1)<1)
        find_categray = false;
    end
    
end

figure;
plot(category_cnt(:,1), category_cnt(:,2), 'b.')


%% 
% combine sub-set
thr = 0.5;
% thr = 5.0e+3;
category_final(1,:) = category_cnt(1,:);
pnts_vist_tms_final(:,1) =  pnts_vist_tms(:, 1);
final_cat_cnt = 1;
for i = 2:size(category_cnt, 1)
    cur_cntr = category_cnt(i,:);
    independent_flag = true;
    for j = 1:size(category_final, 1)        
        dis = sum((cur_cntr-category_final(j,:)).^2);
        
        if(dis < thr)
            % combine these two sub-sets
            independent_flag = false;
            pnts_vist_tms_final(:,j) = pnts_vist_tms_final(:,j) + pnts_vist_tms(:, i);           
            break;
        end                              
    end
    % set as a new category
    if(independent_flag)
        final_cat_cnt = final_cat_cnt + 1;
        pnts_vist_tms_final(:,final_cat_cnt) =  pnts_vist_tms(:, i);
        category_final(final_cat_cnt,:) = category_cnt(i,:);        
    end
end





%%
% show the result
[~,categroy] = max(pnts_vist_tms_final, [], 2);
figure ;
for i=1:size(category_final, 1)
    
    cur_cat = categroy==i;
    sum(cur_cat)
    
    plot(X(cur_cat,1), X(cur_cat,2), '.', 'Color', [rand(), rand(), rand()]);
    hold on;
end

%% show result
% [~,categroy] = max(pnts_vist_tms_final, [], 2)

