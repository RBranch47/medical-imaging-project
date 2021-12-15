function [finalImg, ourMask] = MRI_Radial(img, lines, ppl, maskType, maskPercent)
    %This loadingScreen var will be used to guide loading in the GUI
    loadingScreen = waitbar(0,'Loading....');
    
    %{
    This var will hold the size of the image which will be needed in
    calculation
    %}
    sizeOfImage = size(img);
    
    %{
    Here we have a sample variable that will take the size of the image
    and the passed in ppl or points per line which we will use for various
    calculations within the code
    %}
    sample = (sizeOfImage(1)/ppl);
    
    Nsize = sizeOfImage(1) * 3 * sample;

    ourArr = zeros(Nsize, Nsize);
    ourArr(1:sizeOfImage(1), 1:sizeOfImage(1)) = img;
    kSpaceConvert = fftshift(fft2(ourArr));
    waitbar(1/4)
    % Collect the points we're going to need
    i=1;
    j=1;
    delT = lines;

    for kSpaceConvert=-Nsize/2:sample:Nsize/2

       for theta = 0:pi/delT:(pi-pi/delT)

           radialX(i, j) = kSpaceConvert*cos(-theta)+ Nsize/2;
           radialY(i, j) = kSpaceConvert*sin(-theta)+ Nsize/2;
           
           i = i+1;
       end

       j = j+1;
       i = 1;

    end
    waitbar(2/4)
    
    % Start the sampling for the radial view

    radialView = interp2(F, radialX, radialY, 'bicubic');
    radialView(isnan(radialView)) = 0;
    %interpolate

    S = size(radialView);
    maskedRadialView = zeros(S);
    ourMask = getMask(S, maskType, maskPercent);
    for i=1:1:S(1)
        for j=1:1:S(2)
            if ourMask(i,j) == 1
                maskedRadialView(i, j) = radialView(i,j);
            end
        end
    end

    waitbar(3/4)
    IR = zeros(size(maskedRadialView));
    
    %Inverse fast fourier transform

    for i = 1:delT

       IR(i, :) =fliplr(fftshift((abs(ifft((maskedRadialView(i, :))))))); 

    end
    %recreating the image for display
    imgCreator = iradon(IR', 180/delT);
    imgCreator = rot90(imgCreator(16:sizeOfImage+15, 16:sizeOfImage+15),2);

    finalImg = imgCreator;
    waitbar(4/4)

    close(loadingScreen)    
end