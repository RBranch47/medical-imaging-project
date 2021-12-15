function [acq_img, mask] = MRI_Cartesian(img, klines, kpoints, mType, mPercent) %mtyoe and mPercent are mask type and mask percent
    generate = waitbar(0,'Generating...'); %opens use of the functions the generating shows up as like a timer for the user
    
    N = length(img); % N contains the size of the image
    k = [N/klines, N/kpoints]; %determines the number of points on the grid
    M = floor(N*k); % length by points so we can do cartesians 
    I = zeros(M(1), M(2)); % this is the image in a way
    I(1:N, 1:N) = img; % starts the image at the same point everytime
    F = fftshift(fft2(I)); % changing image into k-space with ffshift(ff2(image) or Fourier shift since
    % since we had a matrix 1:N, 1:N if what i understand is correct the
    % first quadrant is swapped with the third and the 2nd and fourth are
    % swapped.
    F2 = zeros(M(1),M(2));

    waitbar(1/4)

    Sample = interp2(F, (M(2)/2-N/2:k(2):M(2)/2+N/2-1)',(M(1)/2-N/2:k(1):M(1)/2+N/2-1));
    S = size(Sample);
    maskedSample = zeros(S(1), S(2));
    
    mask = getMask(S, mType, mPercent);
    
    for i=1:1:S(1)
        for j=1:1:S(2)
            if mask(i,j) == 1
                maskedSample(i, j) = Sample(i,j);
            end
        end
    end
    
    waitbar(2/4)
    
    F2(M(1)/2-S(1)/2+1:(M(1)/2+S(1)/2),  M(2)/2-S(2)/2+1:(M(2)/2+S(2)/2)) = maskedSample;
    F2(isnan(F2)) = 0;
    
    IF2 = (ifft2(fftshift(F2)));
    IF2 = abs((IF2));
    
    waitbar(3/4)
    
    res_IF2 = imresize(IF2, size(IF2)./k);
    acq_img = res_IF2;
    
    acq_img = acq_img/(max(acq_img(:))) * 255;

    waitbar(4/4)    
    close(generate) % closes use of the functions
end