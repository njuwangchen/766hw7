function trackingTester(data_params, tracking_params)

first_img = imread(fullfile(data_params.data_dir,...
    data_params.genFname(data_params.frame_ids(1))));
xmin = tracking_params.rect(1);
ymin = tracking_params.rect(2);
width = tracking_params.rect(3);
height = tracking_params.rect(4);

sub_img = first_img(ymin:ymin+height-1, xmin:xmin+width-1, :);

[index_sub_img, map] = rgb2ind(sub_img, tracking_params.bin_n);
[color_hist, edges] = histcounts(index_sub_img, tracking_params.bin_n);

for i = 2: size(data_params.frame_ids, 2)
    cur_img = imread(fullfile(data_params.data_dir,...
    data_params.genFname(data_params.frame_ids(i))));
    
    half_w = tracking_params.search_half_window_size;
    search_area_xmin = xmin-half_w;
    search_area_ymin = ymin-half_w;
    search_width = width + 2*half_w;
    search_height = height + 2*half_w;
    
    search_area = cur_img(search_area_ymin:search_area_ymin+search_height-1,...
        search_area_xmin:search_area_xmin+search_width-1, :);
    search_col = im2col_rgb(search_area, [height width]);
    
%     size_search = size(search_area)
%     size_temp = size(sub_img)
%     size_scol = size(search_col)
    
%     imshowpair(search_area, sub_img, 'montage')
        
    hist_mat = zeros(size(search_col, 2), tracking_params.bin_n);
    corr_vec = [];
    for j = 1: size(search_col, 2)
        index_cur_window = rgb2ind(search_col(:, j, :), map);
        [N, E] = histcounts(index_cur_window, tracking_params.bin_n);
        hist_mat(j, :) = N;
        corr_vec = [corr_vec; correlation(color_hist, N)];
    end
    
%     size_hist = size(hist_mat)
%     
%     c = normxcorr2(color_hist, hist_mat);
%     b_max_corr = max(c(:))
%     [ypeak, xpeak] = find(c==b_max_corr)
%     yoffSet = ypeak-size(color_hist,1)
%     xoffSet = xpeak-size(color_hist,2)
    
    max_corr = max(corr_vec);
    max_ind = find(corr_vec == max_corr);
    
    move = search_height - height + 1;
    xmin = search_area_xmin + int32(max_ind/move);
    ymin = search_area_ymin + mod(max_ind, move);
    
%     [xmin ymin width height]
%     [search_area_xmin search_area_ymin search_width search_height]
    
    box_img = drawBox(cur_img, [xmin ymin width height], [255 0 0], 3);
%     box_img2 = drawBox(box_img, [search_area_xmin search_area_ymin search_width search_height], [0 255 0], 3);
    figure, imshow(box_img);
    
%     sub_image = cur_img(ymin:ymin+height-1, xmin:xmin+width-1, :);
%     [index_sub_img, map] = rgb2ind(sub_img, tracking_params.bin_n);
%     [color_hist, edges] = histcounts(index_sub_img, tracking_params.bin_n);
        
end

function B = im2col_rgb(img, sz, varargin)
B = cell(1,size(img,3));
for i=1:size(img,3)
    B{i} = im2col(img(:,:,i), sz, varargin{:});
end
B = cat(3, B{:});

function C = correlation(A, B)
A_bar = mean(A);
B_bar = mean(B);
C = sum((A-A_bar).*(B-B_bar)) / (sqrt(sum((A-A_bar).^2))*sqrt(sum((B-B_bar).^2)));
