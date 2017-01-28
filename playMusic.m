function playMusic(filename)
    [freq,tempo,numn] = readMusic;
    period = 60/tempo;
    time = 0:1/8192:period;
    size = length(time)*numn;
    wave = 2*sin(2*pi*(time.')*freq);
    y = zeros(1,size);
    for i = 1:size
        y(i) = wave(i);
    end
    y(y < -1) = -1; y(y > 1) = 1;
    fnl = length(filename) - 3;
    filename = strcat(filename(1:fnl),'wav');
    file = strcat(pwd,'\',filename);
    audiowrite(filename,y,8192);
    winopen(file);
    
    function [freq,tempo,numn] = readMusic
        fID = fopen(filename,'r');
        data = fread(fID,4);
        tempo = 100*data(1) + 10*data(2) + data(3) - 5328 ; 
        data = fread(fID,1,'*char');
        switch data
            case 'C', middle = 1; case 'D', middle = 3; 
            case 'E', middle = 5; case 'F', middle = 6;
            case 'G', middle = 8; case 'A', middle = 10;
            case 'B', middle = 12;
        end
        data = fread(fID,2);
        octave = data(1) - 48;
        data = fread(fID,4);
        numn = 100*data(1) + 10*data(2) + data(3) - 5328 ;
        data = fread(fID,4);
        lines = 10*data(1) + data(2) - 528;
        freq = zeros(lines,numn);
        err = 0;
        for j = 1:lines
            for k = 1:numn
                data = fread(fID,1,'*char');
                if isequal(data,'o')
                    note = middle + (lines + 1)/2 - j;
                    freq(j,k) = 15.434*2^(note/12 + octave);
                elseif ~isequal(data,'-')
                    err = err + 1;
                    note = middle + (lines + 1)/2 - j;
                    freq(j,k) = 15.434*2^(note/12 + octave);
                end
            end
            fread(fID,2);
        end
        freq = sum(freq);
        fclose(fID);
        if err > 0
            warning('%d unexpected character(s) in the file.',err);
        end
    end
end
