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
    F2 = zeros(M(1),M(2)); % returns an M(1) by M(2) matrix of zeros

    waitbar(1/4) % this marks the progress of the loading bar 
    % (so far we have only done 1/4 of it)

    % Sample intervals
    Samp = interp2(F, (M(2)/2-N/2:k(2):M(2)/2+N/2-1)',(M(1)/2-N/2:k(1):M(1)/2+N/2-1));
    % assuming we have a default grid that is covering a rectangle with
    % this syntax we can conserve memory and we are not concerned with
    % absolutes in accordance to distance
    S = size(Samp); % gets the size of the above number
    mSample = zeros(S(1), S(2));
    
    mask = getMask(S, mType, mPercent); %hides block content
    
    for i=1:1:S(1)
        for j=1:1:S(2)
            if mask(i,j) == 1
                mSample(i, j) = Samp(i,j);
            end
        end
    end
    
    waitbar(2/4) % we are now halfway done before the user can see what is going on
    
    F2(M(1)/2-S(1)/2+1:(M(1)/2+S(1)/2),  M(2)/2-S(2)/2+1:(M(2)/2+S(2)/2)) = mSample;
    F2(isnan(F2)) = 0; % will only allow the processes that can actually work run
    
    IF2 = (ifft2(fftshift(F2))); %Fourier shift
    % in a way we are getting the inverse of the fourier shift that is
    % initally being done. 
    IF2 = abs((IF2)); % we take the absolute value of the above number
    
    waitbar(3/4) % we are now 3/4 of the way through before the user can see any progress
    
    res_IF2 = imresize(IF2, size(IF2)./k); 
    % we are taking the image IF2, and rescaling it to the outcome of
    % size(IF2)./k 
    acq_img = res_IF2; % just for transparency for others to look at
    
    acq_img = acq_img/(max(acq_img(:))) * 255;

    waitbar(4/4)    %completion of the wait bar to mark progress as done.
    close(generate) % closes use of the functions
end