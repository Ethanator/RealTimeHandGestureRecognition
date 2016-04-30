% HuMoments.m
% Calculate the Hu moments of a given image.
%   Author: Yuxuan Chen

function hu_mmts = HuMoments(img)
    img = double(img);

    for i = 1:1:4
        for j = 1:1:4
            nu(i, j) = CentralMoment(img, i-1, j-1);
        end
    end

    eta = zeros(3,3);
    for i = 1:1:4
        for j = 1:1:4
            if i + j >= 4
                eta(i,j) = double(nu(i, j)) / ...
                    (double(nu(1, 1)).^(double((i + j)/2)));
            end
        end
    end
    
    hu_mmts(1) = eta(3,1)+eta(1,3);
    hu_mmts(2) = (eta(3,1)-eta(1,3))^2+4*eta(2,2)^2;
    hu_mmts(3) = (eta(4,1)-3*eta(2,3))^2+(3*eta(3,2)-eta(1,4))^2;
    hu_mmts(4) = (eta(4,1)+eta(2,3))^2+(eta(3,2)+eta(1,4))^2;
    hu_mmts(5) = (eta(4,1)-3*eta(2,3))*(eta(4,1)+eta(2,3))*...
        ((eta(4,1)+eta(2,3))^2-3*(eta(3,2)+eta(1,4))^2)+...
        (3*eta(3,2)-eta(1,4))*(eta(3,2)+eta(1,4))*...
        (3*(eta(4,1)+eta(2,3))^2-(eta(3,2)+eta(1,4))^2);
    hu_mmts(6) = (eta(3,1)-eta(1,3))*...
        ((eta(4,1)+eta(2,3))^2-(eta(3,2)+ eta(1,4))^2)+...
        4*eta(2,2)*(eta(4,1)+eta(2,3))*(eta(3,2)+eta(1,4));
    hu_mmts(7) = (3*eta(3,2)-eta(1,4))*(eta(4,1)+eta(2,3))*...
        ((eta(4,1)+eta(2,3))^2-3*(eta(3,2)-eta(1,4))^2)-...
        (eta(4,1)-3*eta(2,3))*(eta(3,2)+eta(1,4))*...
        (3*(eta(4,1)+eta(2,3))^2-(eta(3,2)+eta(1,4))^2);
end