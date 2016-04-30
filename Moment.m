% Moment.m
% Calculate the moment of a given image.
%   Author: Yuxuan Chen

function mmt = Moment(img, ord_x, ord_y)
    img = double(img);
    mmt = 0;
    for i = 1:1:size(img,1)
        for j = 1:1:size(img,2)
            mmt = mmt + double(img(i,j) * i^ord_x * j^ord_y);
        end
    end
end