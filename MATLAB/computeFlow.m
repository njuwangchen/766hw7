function result = computeFlow(img1, img2, win_radius, template_radius, grid_MN)

row_num = grid_MN(1);
col_num = grid_MN(2);

row_space = size(img1, 1)/(row_num);
col_space = size(img1, 2)/(col_num);

x = [];
y = [];
u = [];
v = [];

for i = row_space:row_space:size(img1, 1)
    for j = col_space:col_space:size(img1, 2)
        row_ind = i-row_space/2
        col_ind = j-col_space/2
        
        template = img1(row_ind-template_radius:row_ind+template_radius, ...
            col_ind-template_radius:col_ind+template_radius);
        window = img2(row_ind-win_radius:row_ind+win_radius, ...
            col_ind-win_radius:col_ind+win_radius);
        
%         imshowpair(window,template,'montage')
        
        c = normxcorr2(template, window);
%         tmp_size = size(template)
%         win_size = size(window)
%         c_size = size(c)
        
%         figure, surf(c), shading flat
        
        [row_peak, col_peak] = find(c==max(c(:)));
        row_peak = row_peak(1) - size(template, 1)
        col_peak = col_peak(1) - size(template, 2)
        
        row_crp = template_radius+row_peak+(row_ind-win_radius)
        col_crp = template_radius+col_peak+(col_ind-win_radius)
        
%         hFig = figure;
%         hAx  = axes;
%         imshow(window,'Parent', hAx);
%         imrect(hAx, [col_peak+1, row_peak+1, size(template,2), size(template,1)]);
        
        x = [x; col_ind];
        y = [y; row_ind];
        u = [u; col_crp-col_ind];
        v = [v; row_crp-row_ind];
        
    end
    
end

fh = figure();
imshow(img1)
hold;
quiver(x, y, u, v)

result = saveAnnotatedImg(fh);

function annotated_img = saveAnnotatedImg(fh)
figure(fh); % Shift the focus back to the figure fh

% The figure needs to be undocked
set(fh, 'WindowStyle', 'normal');

% The following two lines just to make the figure true size to the
% displayed image. The reason will become clear later.
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);

% getframe does a screen capture of the figure window, as a result, the
% displayed figure has to be in true size. 
frame = getframe(fh);
frame = getframe(fh);
pause(0.5); 
% Because getframe tries to perform a screen capture. it somehow 
% has some platform depend issues. we should calling
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;