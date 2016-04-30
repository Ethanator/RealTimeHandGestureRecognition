% CentralMoment.m
% Calculate the central moment of a given image.
%   Author: Yuxuan Chen

function central_mmt = CentralMoment(img, ord_x, ord_y)
    img = double(img);
    mmt_0_0 = Moment(img, 0, 0);
    mmt_1_0 = Moment(img, 1, 0); 
    mmt_0_1 = Moment(img, 0, 1);

    center_x = floor(mmt_1_0/mmt_0_0);
    center_y = floor(mmt_0_1/mmt_0_0);
    central_mmt =0;

    for i = 1:1:size(img,1)
        for j = 1:1:size(img,2)
            central_mmt = central_mmt + double(img(i,j) * ...
                (i - center_x)^ord_x * (j - center_y)^ord_y);
        end
    end
end