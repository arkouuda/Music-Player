function playMusic(filename)
    [freq,tempo,lengthM] = readMusic;
    period = 60/tempo;
    t = 0:1/8192:period;
    for i = 1:lengthM
        wave = 2*sin(2*pi*freq(i)*t);
        sound(wave);
        pause(period);
    end
    
    function [freq,tempo,lengthM] = readMusic
        fID = fopen(filename,'r');
        data = fread(fID,4);
        tempo = 100*data(1) + 10*data(2) + data(3) - 5328 ; 
        data = fread(fID,1,'*char');
        switch data
            case 'C'
                middle = 1;
            case 'F'
                middle = 6;
            case 'G'
                middle = 8;
        end
        data = fread(fID,2);
        octave = data(1) - 48;
        data = fread(fID,4);
        lengthM = 100*data(1) + 10*data(2) + data(3) - 5328 ;
        data = fread(fID,4);
        lines = 10*data(1) + data(2) - 528;
        staff = -100*ones(lines,lengthM);
        for j = 1:lines
            data = zeros(1,lengthM);
            for k = 1:lengthM
                data(k) = fread(fID,1,'*char');
                switch data(k)
                    case 'o'
                        data(k) = middle + (lines + 1)/2 - j;
                    case '-'
                        data(k) = -500;
                end
            end
            staff(j,:) = data;
            fread(fID,2);
        end
        freq = 15.434*2.^(staff/12 + octave);
        freq = sum(freq);
        fclose(fID);
    end
end
