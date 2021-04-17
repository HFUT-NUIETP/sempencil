function mask = mask_gen(img_sem)

img_mask = img_sem(:, :, 1);
img_mask(img_mask~=0) = 1;
mask = double(img_mask);