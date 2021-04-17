function img_opt = pencil_draw_gen(i)

% input: i - test patch index

res_para = 0.7;
img_ori_path = strcat('./img/', num2str(i), '-0.png');
img_sem_path = strcat('./img/', num2str(i), '-1.png');
img_ori = imread(img_ori_path);
img_sem = imread(img_sem_path);
img_mask = mask_gen(img_sem); % 人物为1，背景为0

% sketch
img_sk0 = sketch_gen_para(img_ori, img_sem, 40, 2, res_para);
img_sk = img_sk0;

% tone
img_tone0 = tone_gen_gray_para(img_ori, 4); % 参数越大，越光滑，风景
img_tone1 = tone_gen_gray_para(img_ori, 0.3);
img_tone = (1 - img_mask) .* img_tone0 + (img_mask) .* img_tone1;
% img_tone = tone_gen_gray_para(img_ori, lambda);

% fus
img_opt = img_sk .* img_tone;