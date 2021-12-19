function S = sketch_gen_para(I, G, len, thick, res_para)

% input: I - input image; G - semantic guidance map
% function: pencil drawing sketch generation

line_len_divisor = len; % larger for a shorter line fragment
line_thickness_divisor = thick; % larger for thiner outline sketches

% lambda = 2; % larger for smoother tonal mappings
% texture_resize_ratio = 0.2;
% texture_file_name = 'textures/texture.jpg';

if length(size(I)) == 3
    J = rgb2gray(I);
    type = 'black';
else
    J = I;
    type = 'colour';
end

% ================================================
% Compute the outline sketch 'S'
% ================================================
% calculate 'line_len', the length of the line segments

% semantic map add by teng begin
dBdry = zeros(size(I, 1), size(I, 2)); 
for i = (1 + 1): size(I, 1)
    for j = (1 + 1): size(I, 2)
        if ((G(i, j, 1) ~= 0 && G(i, j-1, 1) == 0) || (G(i, j, 1) == 0 && G(i, j-1, 1) ~= 0))
            dBdry(i, j) = 1;
        end
    end
end
G = dBdry;
% semantic map add by teng end

line_len_double = min([size(J,1), size(J,2)]) / line_len_divisor;
if mod(floor(line_len_double), 2)
    line_len = floor(line_len_double);
else
    line_len = floor(line_len_double) + 1;
end
half_line_len = (line_len + 1) / 2;

% compute the image gradient 'Imag'
Ix = conv2(im2double(J), [1,-1;1,-1], 'same');
Iy = conv2(im2double(J), [1,1;-1,-1], 'same');
Imag = sqrt(Ix.*Ix + Iy.*Iy);


% semantic guidance by teng begin
kernelSize = 6;
thresholdC = 1;
for i = (1 + 1): size(Imag, 1)
    for j = (1 + 1): size(Imag, 2)
        if (G(i, j) == 1)
            temp = 0;
            for m = i - kernelSize: i+ kernelSize
                for n = j - kernelSize: j + kernelSize
                    temp = temp + Imag(i, j);
                end
            end
            if (temp > thresholdC)% TODO
                Imag(i, j) = res_para;
            end
        end
    end
end
% add by teng end


% create the 8 directional line segments L
L = zeros(line_len, line_len, 8);
for n=0:7
    if n == 0 || n == 1 || n == 2 || n == 7
        for x=1:line_len
            y = half_line_len - round((x-half_line_len)*tan(pi/8*n));
            if y > 0 && y <= line_len
                L(y, x, n+1) = 1;
            end
        end
        if n == 0 || n == 1 || n == 2
            L(:,:,n+5) = rot90(L(:,:,n+1));
        end
    end
end
L(:,:,4) = rot90(L(:,:,8), 3);

% add some thickness to L
valid_width = size(conv2(L(:,:,1),ones(round(line_len/line_thickness_divisor)),'valid'), 1);
Lthick = zeros(valid_width, valid_width, 8);
for n=1:8
    Ln = conv2(L(:,:,n),ones(round(line_len/line_thickness_divisor)), 'valid');
    Lthick(:,:,n) = Ln / max(max(Ln));
end

% create the sketch
G = zeros(size(J,1), size(J,2), 8);
for n=1:8
    G(:,:,n) = conv2(Imag, L(:,:,n), 'same');
end

[Gmax, Gindex] = max(G, [], 3);
C = zeros(size(J,1), size(J,2), 8);
for n=1:8
    C(:,:,n) = Imag .* (Gindex == n);
end

Spn = zeros(size(J,1), size(J,2), 8);
for n=1:8
    Spn(:,:,n) = conv2(C(:,:,n), Lthick(:,:,n), 'same');
end
Sp = sum(Spn, 3);
Sp = (Sp - min(Sp(:))) / (max(Sp(:)) - min(Sp(:)));
S = 1 - Sp;