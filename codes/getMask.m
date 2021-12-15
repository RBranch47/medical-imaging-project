function mask = getMask(S, maskType, maskPercent)
    switch maskType 
        case 1
            
            mask = ones(S);
            value = 0;
            
            if maskPercent > .9

                maskPercent = .9;

            end

            offset = round((min(S)/2) * (1-maskPercent));

            for i=1+offset:S(1)-offset

                for j=1+offset:S(2)-offset

                    mask(i,j) = value;

                end
            end
        case 2

            rad = round(min(S)/2 * maskPercent);
            cWidth = S(2)/2;
            cHeight = S(1)/2;
            [Width,Height] = meshgrid(1:S(2),1:S(1));
            mask = ((Width-cWidth).^2 + (Height-cHeight).^2) < rad^2;

        otherwise

            mask = ones(S);

    end
end