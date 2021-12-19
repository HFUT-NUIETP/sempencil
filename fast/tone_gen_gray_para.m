function T = tone_gen_gray_para(I, smooth)

% input: I - image
% function: pencil image tone generation

% parameters
lambda = smooth;
% lambda = 2; % larger for smoother tonal mappings
texture_resize_ratio = 0.2;
texture_file_name = 'textures/texture.jpg';

if length(size(I)) == 3
    J = rgb2gray(I);
    type = 'black';
else
    J = I;
    type = 'colour';
end

Jadjusted = natural_histogram_matching(J,type);

% stich pencil texture image
texture = imread(texture_file_name);
texture = texture(100:size(texture,1)-100,100:size(texture,2)-100);
texture = im2double(imresize(texture, texture_resize_ratio*min([size(J,1),size(J,2)])/1024));
Jtexture = vertical_stitch(horizontal_stitch(texture,size(J,2)), size(J,1));

% solve for beta
sizz = size(J,1)*size(J,2); % width of big matrix

nzmax = 2*(sizz-1);
i = zeros( nzmax, 1 );
j = zeros( nzmax, 1 );
s = zeros( nzmax, 1 );
for m=1:nzmax
    i(m) = ceil((m+0.1) / 2);
    j(m) = ceil((m-0.1) / 2);
    s(m) = -2*mod(m,2) + 1;
end
dx = sparse(i,j,s,sizz,sizz,nzmax);

nzmax = 2*(sizz - size(J,2));
i = zeros( nzmax, 1 );
j = zeros( nzmax, 1 );
s = zeros( nzmax, 1 );
for m=1:nzmax
    if mod(m,2)
        i(m) = ceil((m+0.1) / 2);
    else
        i(m) = ceil((m-1+0.1) / 2) + size(J,2);
    end
    j(m) = ceil((m-0.1) / 2);
    s(m) = -2*mod(m,2) + 1;
end
dy = sparse(i,j,s,sizz,sizz,nzmax);

Jtexture1d = log(reshape(Jtexture',1,[]));
Jtsparse = spdiags(Jtexture1d',0,sizz,sizz);
Jadjusted1d = log(reshape(Jadjusted',1,[])');
beta1d = (Jtsparse'*Jtsparse + lambda*(dx'*dx + dy'*dy))\(Jtsparse'*Jadjusted1d);
beta = reshape(beta1d, size(J,2), size(J,1))';

% compute the texture tone image 'T' and combine it with the outline sketch
% to come out with the final result 'Ipencil'
T = Jtexture .^ beta;
T = (T - min(T(:))) / (max(T(:)) - min(T(:)));