function Iadjusted = natural_histogram_matching(I, type)
% Histogram match the image I against a theoretically natural histogram
% which is believed to mimic real pencil drawings
%
% I must be a grayscale image within 0 and 255

% Prepare the histogram of image 'I', which is 'ho'
ho = zeros(1, 256);
po = zeros(1, 256);
for i=1:256
    po(i) = sum(sum(I == (i-1)));
end
po = po / sum(po);
ho(1) = po(1);
for i=2:256
    ho(i) = ho(i-1) + po(i);
end

% Prepare the 'natural' histogram which is 'histo'
p1 = @(x) 1 / 9 * exp(-(256-x)/9) * heaviside(256-x);
p2 = @(x) 1 / (256 - 105) * (heaviside(x-105) - heaviside(x-256));
p3 = @(x) 1 / sqrt(2*pi*11)*exp(-((x-90)^2)/(2*121));

if strcmp(type,'colour')
    %p = @(x) (52*p1(x) + 37*p2(x) + 11*p3(x));
    p = @(x) (62*p1(x) + 30*p2(x) + 5*p3(x));
else
    %p = @(x) (62*p1(x) + 30*p2(x) + 5*p3(x));
    p = @(x) (76*p1(x) + 22*p2(x) + 2*p3(x));
end

prob = zeros(1, 256); histo = zeros(1, 256);
for i=1:256
    prob(i) = p(i);
end
prob = prob / sum(prob);
histo(1) = prob(1);
for i=2:256
    histo(i) = histo(i-1) + prob(i);
end

% Do the histogram matching
Iadjusted = zeros(size(I,1), size(I,2));
for y=1:size(I,1)
    for x=1:size(I,2)
        histogram_value = ho(I(y,x)+1);
        [v,i] = min(abs(histo - histogram_value));
        Iadjusted(y,x) = i;
    end
end
Iadjusted = Iadjusted / 255;
end


function res = heaviside(x)
    if x >= 0
        res = x
    else
        res = 0
    end
end
