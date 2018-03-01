%% Project: MATLAB supported Synchro-measurement Application Development Framework (SADF)
% Author: Matija Naglic
% Email: m.naglic@tudelft.nl
% Version: 2.0
% Date: 08/01/2018
% Reference paper: M. Naglic, M. Popov, M. Van Der Meijden, V. Terzija, "Synchro-measurement Application Development Framework: an IEEE Standard C37.118.2-2011 Supported MATLAB Library", IEEE Transactions on Instrumentation & Measurements 
% Reference paper DOI: https://doi.org/10.1109/TIM.2018.2807000

% // Copyright (C) 2018   Matija Naglic     <m.naglic@tudelft.nl>
% //
% // This program is free software; you can redistribute it and/or modify
% // it under the terms of the GNU General Public License as published by
% // the Free Software Foundation; either version 3 of the License, or
% // (at your option) any later version.
% //
% // This program is distributed in the hope that it will be useful,
% // but WITHOUT ANY WARRANTY; without even the implied warranty of
% // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% // GNU General Public License for more details.
% //
% // You should have received a copy of the GNU General Public License
% // along with this program; if not, see <http://www.gnu.org/licenses/>.

function data_frame(data_raw)
    
    global SADF DATA CFG_2_3
    
    SADF.DATA_recieved = true;
    DATA.counter = DATA.counter + 1;
    IDCODE = swapbytes(typecast(data_raw(5:6), 'uint16'));
    %SOC = datenum([1970 1 1 0 0 double(swapbytes(typecast(data_raw(7:10), 'uint32')))]);
    SOC = 719529 + double(swapbytes(typecast(data_raw(7:10), 'uint32'))) / 864e2;
    FOS = double(swapbytes(typecast([0; data_raw(12:14)], 'uint32')));
    TimeStamp_tmp = SOC + (FOS / CFG_2_3.Time_Base(CFG_2_3.counter, 1) / 86400);% Store MSG timestamp
    
    if SADF.tcp
        DATA.index = DATA.counter;
        DATA.index_max = DATA.counter;
        process_frame = true;
        if (SADF.verbose_info || SADF.verbose_debug)
            disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 DATA']);
        end
        
    else
        index_tmp = round(round((TimeStamp_tmp - DATA.TimeStamp(10, 1)) *86400, 3) * CFG_2_3.Data_Rate(CFG_2_3.counter, 1))+10;
        
        if isnan(index_tmp)
            DATA.index = 10;
            DATA.index_max = 10;
            process_frame = true;
            if (SADF.verbose_info || SADF.verbose_debug)
                disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 DATA']);
            end
            
        elseif index_tmp == DATA.index_max + 1
            DATA.index = index_tmp;
            DATA.index_max = index_tmp;
            process_frame = true;
            if (SADF.verbose_info || SADF.verbose_debug)
                disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 DATA']);
            end
            
        elseif index_tmp > DATA.index_max + 1
            DATA.index = index_tmp;
            DATA.index_max = index_tmp;
            DATA.counter_notOrder = DATA.counter_notOrder + 1;
            process_frame = true;
            if (SADF.verbose_info || SADF.verbose_debug)
                disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 DATA, out-of-order and/or missing']);
            end
            
        elseif index_tmp < DATA.index_max + 1 && isnan(DATA.TimeStamp(index_tmp,1))
            DATA.index = index_tmp;
            DATA.counter_notOrder = DATA.counter_notOrder + 1;
            process_frame = true;
            if (SADF.verbose_info || SADF.verbose_debug)
                disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 DATA, out-of-order and/or missing']);
            end
            
        elseif index_tmp < DATA.index_max+1 && ~isnan(DATA.TimeStamp(index_tmp,1))
            DATA.index = index_tmp;
            DATA.counter_duplicated = DATA.counter_duplicated + 1;
            process_frame = false;
            if (SADF.verbose_info || SADF.verbose_debug)
                disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 DATA, duplicated']);
            end
        end
    end
    
    SADF.t6(DATA.index,1)= now;
    
    if process_frame
        
        DATA.TimeStamp(DATA.index, 1) = TimeStamp_tmp;
        DATA.Time_Quality(DATA.index, 1:8) = dec2bin(data_raw(11),8);
        
        if (SADF.verbose_debug)
            DATA.RAW_data(1:length(data_raw), DATA.index) = data_raw;
            
            switch DATA.Time_Quality(DATA.index, 5:8)
                case '1111'
                    leapTQ = ('"Fault - clock failure, time not reliable"');
                case '1011'
                    leapTQ = ('"Time within 10 s of UTC"');
                case '1010'
                    leapTQ = ('"Time within 1 s of UTC"');
                case '1001'
                    leapTQ = ('"Time within 10^-1 s of UTC"');
                case '1000'
                    leapTQ = ('"Time within 10^-2 s of UTC"');
                case '0111'
                    leapTQ = ('"Time within 10^-3 s of UTC"');
                case '0110'
                    leapTQ = ('"Time within 10^-4 s of UTC"');
                case '0101'
                    leapTQ = ('"Time within 10^-5 s of UTC"');
                case '0100'
                    leapTQ = ('"Time within 10^-6 s of UTC"');
                case '0011'
                    leapTQ = ('"Time within 10^-7 s of UTC"');
                case '0010'
                    leapTQ = ('"Time within 10^-8 s of UTC"');
                case '0001'
                    leapTQ = ('"Time within 10^-9 s of UTC"');
                case '0000'
                    leapTQ = ('"Normal operation, clock locked to UTC traceable source"');
                otherwise
                    leapTQ = ('"error reading"');
            end
            
            disp('  Synchronization word (hex): "AA01"');  %Checked before entered
            disp(['  Framesize: ' num2str(swapbytes(typecast(data_raw(3:4),'uint16'))) ' Bytes']);
            disp(['  PMU/PDC ID number: ' num2str(IDCODE)]);
            disp(['  Timestamp: ' datestr(SOC + (FOS / CFG_2_3.Time_Base(CFG_2_3.counter, 1) / 86400), 'yyyy-mm-dd HH:MM:SS.FFF')]);
            disp('  Time quality flags: ');
            if DATA.Time_Quality(DATA.index, 2) == '1'; disp('    Leap second direction'); end
            if DATA.Time_Quality(DATA.index, 3) == '1'; disp('    Leap second occurred'); end
            if DATA.Time_Quality(DATA.index, 4) == '1'; disp('    Leap second pending'); end
            disp(['    Time quality indicator: ' leapTQ]);
            disp(['  Number of PMU blocks included in the frame: ' num2str(CFG_2_3.Num_PMU(CFG_2_3.counter, 1))]);
        end
        
        a2 = 14; %Reading start position (header)
        for pmui = 1 : CFG_2_3.Num_PMU(CFG_2_3.counter, 1)
            
            %status flags
            a1 = a2 + 1 ;
            a2 = a2 + 2;
            time_Q = dec2bin(data_raw(a1:a2),8)';
            DATA.Measurement_Quality(DATA.index, 1:16, pmui)  = time_Q(:)';
            
            if (SADF.verbose_debug)
                disp(' ');
                disp(['    Station #' num2str(pmui) ': "' char(CFG_2_3.Station_Name(1:16, pmui, CFG_2_3.counter))' '"']);
                disp(['      PMU ID number: ' num2str(CFG_2_3.PMUsID(1, pmui, CFG_2_3.counter))])
                disp('      Quality flags:');
                switch time_Q(1:2)
                    case '00'; disp('        Good measurement data, no errors');
                    case '01'; disp('        PMU error, no information about data');
                    case '10'; disp('        PMU in test mode or absent data inserted (do not use values)');
                    case '11'; disp('        PMU error (do not use values)');
                end
                
                sizemax=48;
                prop=zeros(sizemax,5);
                if time_Q(3)=='1'; prop(:,1)=padarray(uint16('"lost"')',sizemax-6,0, 'post'); else; prop(:,1)=padarray(uint16('"locked to UTC traceable time source"')',sizemax-37,0, 'post'); end
                if time_Q(4)=='1'; prop(:,2)=padarray(uint16('"by arrival"')',sizemax-12,0, 'post'); else; prop(:,2)=padarray(uint16('"by timestamp"')',sizemax-14,0, 'post'); end
                
                switch time_Q(8:10)
                    case '111'
                        prop(:,3)=padarray(uint16('"max time error > 10 ms or time error unknown"')',sizemax-46,0, 'post');
                    case '110'
                        prop(:,3)=padarray(uint16('"max time error < 10 ms"')',sizemax-24,0, 'post');
                    case '101'
                        prop(:,3)=padarray(uint16('"max time error < 1 ms"')',sizemax-23,0, 'post');
                    case '100'
                        prop(:,3)=padarray(uint16('"max time error < 100 us"')',sizemax-25,0, 'post');
                    case '011'
                        prop(:,3)=padarray(uint16('"max time error < 10 us"')',sizemax-24,0, 'post');
                    case '010'
                        prop(:,3)=padarray(uint16('"max time error < 1 us"')',sizemax-23,0, 'post');
                    case '001'
                        prop(:,3)=padarray(uint16('"max time error < 100 ns"')',sizemax-25,0, 'post');
                    case '000'
                        prop(:,3)=padarray(uint16('"not used"')',sizemax-10,0, 'post');
                    otherwise
                        prop(:,3)=padarray(uint16('"error reading"')',sizemax-15,0, 'post');
                end
                
                switch time_Q(11:12)
                    case '00'
                        prop(:,4)=padarray(uint16('"locked or unlocked less than 10 s"')',sizemax-35,0, 'post');
                    case '01'
                        prop(:,4)=padarray(uint16('"unlocked 10 s or longer but less than 100 s"')',sizemax-45,0, 'post');
                    case '10'
                        prop(:,4)=padarray(uint16('"unlocked 100 s or longer but less than 1000 s "')',sizemax-48,0, 'post');
                    case '11'
                        prop(:,4)=padarray(uint16('"unlocked 1000 s or more "')',sizemax-26,0, 'post');
                    otherwise
                        prop(:,4)=padarray(uint16('"error reading"')',sizemax-15,0, 'post');
                end
                
                switch time_Q(13:end)
                    case '1111'
                        prop(:,5)=padarray(uint16('"user defined"')',sizemax-14,0, 'post');
                    case '1011'
                        prop(:,5)=padarray(uint16('"user defined"')',sizemax-14,0, 'post');
                    case '1010'
                        prop(:,5)=padarray(uint16('"user defined"')',sizemax-14,0, 'post');
                    case '1001'
                        prop(:,5)=padarray(uint16('"user defined"')',sizemax-14,0, 'post');
                    case '1000'
                        prop(:,5)=padarray(uint16('"user defined"')',sizemax-14,0, 'post');
                    case '0111'
                        prop(:,5)=padarray(uint16('"digital"')',sizemax-9,0, 'post');
                    case '0110'
                        prop(:,5)=padarray(uint16('"reserved"')',sizemax-10,0, 'post');
                    case '0101'
                        prop(:,5)=padarray(uint16('"df/dt high"')',sizemax-12,0, 'post');
                    case '0100'
                        prop(:,5)=padarray(uint16('"frequency high or low"')',sizemax-23,0, 'post');
                    case '0011'
                        prop(:,5)=padarray(uint16('"phase angle diff"')',sizemax-18,0, 'post');
                    case '0010'
                        prop(:,5)=padarray(uint16('"magnitude high"')',sizemax-16,0, 'post');
                    case '0001'
                        prop(:,5)=padarray(uint16('"magnitue low"')',sizemax-14,0, 'post');
                    case '0000'
                        prop(:,5)=padarray(uint16('"manual"')',sizemax-8,0, 'post');
                    otherwise
                        prop(:,5)=padarray(uint16('"error reading"')',sizemax-15,0, 'post');
                end
                
                disp(['        Time synchronization: ' char(prop(:,1))']);
                disp(['        Data sorting: ' char(prop(:,2))']);
                if time_Q(5) == '1'; disp('        Trigger detected'); end
                if time_Q(6) == '1'; disp('        Configuration change within 1 minute'); end
                if time_Q(7) == '1'; disp('        Data modified (post-processing)'); end
                disp(['        Time quality: ' char(prop(:,3))']);
                disp(['        Time source: ' char(prop(:,4))']);
                disp(['        Trigger reason: ' char(prop(:,5))']);
            end
            
            if CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter) > 0
                if (SADF.verbose_debug)
                    disp(['      Phasors (' num2str(CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)) ')'])
                end
                
                
                if SADF.conf_fr_ver == 2 % Config 2
                    if CFG_2_3.PMUsDataFormat(8, pmui, CFG_2_3.counter)==1 %Phasor magnitude and angle (polar)
                        if CFG_2_3.PMUsDataFormat(7, pmui, CFG_2_3.counter)==1 %IEEE floating point , NO SCALING NEEDED
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = swapbytes(typecast(swapbytes(data_raw(a1:a2)),'single'));
                                
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single'));
                            end
                        else  %16-bit integer
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = double(swapbytes(typecast(data_raw(a1:a2),'uint16'))) / 10^5 * CFG_2_3.PMUsPhasorFactor(:,phasori, pmui, CFG_2_3.counter);
                                
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * double(swapbytes(typecast(data_raw(a1:a2),'int16'))) / 10^4;
                            end
                        end
                        
                    else %phasor real an imaginary (rectangular)
                        if CFG_2_3.PMUsDataFormat(7, pmui, CFG_2_3.counter)==1 %IEEE floating point
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Real
                                real = swapbytes(typecast(swapbytes(data_raw(a1:a2)),'single'));
                                
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Imaginary
                                imag = swapbytes(typecast(swapbytes(data_raw(a1:a2)),'single'));
                                
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = abs(real + imag*1j);
                                
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * angle(real + imag*1j);
                            end
                        else  %16-bit integer
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Real
                                real = double(swapbytes(typecast(data_raw(a1:a2),'int16')));
                                
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Imaginary
                                imag = double(swapbytes(typecast(data_raw(a1:a2),'int16')));
                                
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = abs(real + imag*1j) * CFG_2_3.PMUsPhasorFactor(:,phasori, pmui, CFG_2_3.counter) / 10^5;
                                
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * angle(real + imag*1j);
                            end
                        end
                    end
                    
                else % Config 3
                    if CFG_2_3.PMUsDataFormat(8, pmui, CFG_2_3.counter)==1 %Phasor magnitude and angle (polar)
                        if CFG_2_3.PMUsDataFormat(7, pmui, CFG_2_3.counter)==1 %IEEE floating point
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = swapbytes(typecast(swapbytes(data_raw(a1:a2)),'single'));
                                
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * (swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single')) - CFG_2_3.PMUsPhasorAdj(:,phasori, pmui, CFG_2_3.counter));
                            end
                        else  %16-bit integer
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = double(swapbytes(typecast(data_raw(a1:a2),'uint16')))  * CFG_2_3.PMUsPhasorFactor(:,phasori, pmui, CFG_2_3.counter);
                                
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * (double(swapbytes(typecast(data_raw(a1:a2),'int16'))) - CFG_2_3.PMUsPhasorAdj(:,phasori, pmui, CFG_2_3.counter)) / 10^4;
                            end
                        end
                        
                    else %phasor real an imaginary (rectangular)
                        if CFG_2_3.PMUsDataFormat(7, pmui, CFG_2_3.counter)==1 %IEEE floating point , NO SCALING NEEDED
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Real
                                real = swapbytes(typecast(swapbytes(data_raw(a1:a2)),'single'));
                                
                                a1 = a2 + 1;
                                a2 = a2 + 4;
                                %Imaginary
                                imag = swapbytes(typecast(swapbytes(data_raw(a1:a2)),'single'));
                                
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = abs(real + imag*1j);
                                
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * (angle(real + imag*1j) - CFG_2_3.PMUsPhasorAdj(:,phasori, pmui, CFG_2_3.counter));
                            end
                        else  %16-bit integer
                            for phasori = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Real
                                real = double(swapbytes(typecast(data_raw(a1:a2),'int16')));
                                
                                a1 = a2 + 1;
                                a2 = a2 + 2;
                                %Imaginary
                                imag = double(swapbytes(typecast(data_raw(a1:a2),'int16')));
                                
                                %Magnitude
                                DATA.Magnitude(DATA.index, phasori, pmui) = abs(real + imag*1j) * CFG_2_3.PMUsPhasorFactor(:,phasori, pmui, CFG_2_3.counter);
                                
                                %Angle
                                DATA.Angle(DATA.index, phasori, pmui) = (180 / pi) * angle(real + imag*1j) - CFG_2_3.PMUsPhasorAdj(:,phasori, pmui, CFG_2_3.counter);
                            end
                        end
                    end
                end
                if (SADF.verbose_debug)
                    for phasorij = 1 : CFG_2_3.PMUsPhasorNum(1, pmui, CFG_2_3.counter)
                        if CFG_2_3.PMUsPhasorUnit(:, phasorij, pmui, CFG_2_3.counter)==1; pmu_unit='A'; else; pmu_unit='V'; end
                        disp(['        Phasor #' num2str(phasorij) ': name: "' char(CFG_2_3.PMUsPhasorName(:, phasorij, pmui, CFG_2_3.counter))' '", magnitude: ' num2str( DATA.Magnitude(DATA.index, phasorij, pmui) ) ' ' pmu_unit ', angle: ' num2str(DATA.Angle(DATA.index, phasorij, pmui)) ' deg'])
                    end
                end
                
            else; phasori = 0;
            end
            
            if CFG_2_3.PMUsDataFormat(5, pmui, CFG_2_3.counter)==1 %FREQ and ROCOF in IEEE floating point
                a1 = a2 + 1;
                a2 = a2 + 4;
                DATA.Freq(DATA.index, 1, pmui) = CFG_2_3.PMUsFreqNominal(1, pmui, CFG_2_3.counter) + swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single'))*10^-3;
                DATA.FreqDev(DATA.index, 1, pmui) = swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single'))*10^-3;
                
                a1 = a2 + 1;
                a2 = a2 + 4;
                DATA.ROCOF(DATA.index, 1, pmui) = swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single'));
                
            else %FREQ and ROCOF in 16-bit format
                a1 = a2 + 1;
                a2 = a2 + 2;
                DATA.Freq(DATA.index, 1, pmui) = CFG_2_3.PMUsFreqNominal(1, pmui, CFG_2_3.counter) + double(swapbytes(typecast(data_raw(a1:a2),'int16')))*10^-3;
                DATA.FreqDev(DATA.index, 1, pmui) =  double(swapbytes(typecast(data_raw(a1:a2),'int16')))*10^-3;
                
                a1 = a2 + 1;
                a2 = a2 + 2;
                DATA.ROCOF(DATA.index, 1, pmui) = double(swapbytes(typecast(data_raw(a1:a2),'int16')));
            end
            
            if (SADF.verbose_debug)
                disp(['        System frequency: ' num2str(DATA.Freq(DATA.index, 1, pmui)) ' Hz']);
                disp(['        System frequency deviation: ' num2str(DATA.FreqDev(DATA.index, 1, pmui)) ' Hz']);
                disp(['        Rate-of-change-of-frequency (ROCOF): ' num2str(DATA.ROCOF(DATA.index, 1, pmui)) ' Hz/s']);
            end
            
            if CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter) > 0
                if (SADF.verbose_debug)
                    disp(['      Analog values (' num2str(CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter)) ')'])
                end
                
                
                if SADF.conf_fr_ver == 2 % Config 2
                    if CFG_2_3.PMUsDataFormat(6, pmui, CFG_2_3.counter)==1 %Analog in IEEE floating point
                        for analogi = 1 : CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter)
                            a1 = a2 + 1;
                            a2 = a2 + 4;
                            DATA.Analog(DATA.index, analogi, pmui) = swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single'));
                        end
                    else %Analog in 16-bit format
                        for analogi = 1 : CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter)
                            a1 = a2 + 1;
                            a2 = a2 + 2;
                            DATA.Analog(DATA.index, analogi, pmui) = double(swapbytes(typecast(data_raw(a1:a2),'int16'))) * CFG_2_3.PMUsAnalogFactor(:,analogi, pmui, CFG_2_3.counter);
                        end
                    end
                    
                else % Config 3
                    if CFG_2_3.PMUsDataFormat(6, pmui, CFG_2_3.counter)==1 %Analog in IEEE floating point
                        for analogi = 1 : CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter)
                            a1 = a2 + 1;
                            a2 = a2 + 4;
                            DATA.Analog(DATA.index,  analogi, pmui) = (swapbytes(typecast(swapbytes(data_raw(a1:a2)), 'single')) + CFG_2_3.PMUsAnalogAdj(:,analogi, pmui, CFG_2_3.counter)) * CFG_2_3.PMUsAnalogFactor(:,analogi, pmui, CFG_2_3.counter);
                        end
                    else %Analog in 16-bit format
                        for analogi = 1 : CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter)
                            a1 = a2 + 1;
                            a2 = a2 + 2;
                            DATA.Analog(DATA.index,  analogi, pmui) = (double(swapbytes(typecast(data_raw(a1:a2),'int16'))) + CFG_2_3.PMUsAnalogAdj(:,analogi, pmui, CFG_2_3.counter)) * CFG_2_3.PMUsAnalogFactor(:,analogi, pmui, CFG_2_3.counter);
                        end
                    end
                    
                end
                if (SADF.verbose_debug)
                    for analogij = 1 : CFG_2_3.PMUsAnalogNum(1, pmui, CFG_2_3.counter)
                        disp(['        Analog #'  num2str(analogij) ': name: "' char(CFG_2_3.PMUsAnalogName(:, analogij, pmui, CFG_2_3.counter))' '", value: ' num2str(DATA.Analog(DATA.index,  analogij, pmui))])
                    end
                end
            else; analogi = 0;
                
            end
            
            if CFG_2_3.PMUsDigitalNum(1, pmui, CFG_2_3.counter) > 0
                if (SADF.verbose_debug)
                    disp(['      Digitals (' num2str(CFG_2_3.PMUsDigitalNum(1, pmui, CFG_2_3.counter)) ')'])
                end
                
                for digitali = 1 : CFG_2_3.PMUsDigitalNum(1, pmui, CFG_2_3.counter)
                    
                    a1 = a2 + 1;
                    a2 = a2 + 2;
                    
                    DATA.Digital(DATA.index,  digitali, pmui) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
                    
                end
                if (SADF.verbose_debug)
                    for digitalij = 1 : CFG_2_3.PMUsDigitalNum(1, pmui, CFG_2_3.counter)
                        digstatus= fliplr(dec2bin(CFG_2_3.PMUsDigitalStatus(:,digitalij, pmui, CFG_2_3.counter),32));
                        digiword=fliplr(dec2bin(DATA.Digital(DATA.index, digitalij, pmui),16));
                        
                        for biti = 1 : CFG_2_3.PMUsDigitalNum(1, pmui, CFG_2_3.counter)*16
                            if digstatus(biti)=='1'
                                if digiword(biti) == digstatus(biti + 16)
                                    disp(['        Digital #'  num2str(biti) ': name: "' char(CFG_2_3.PMUsDigitalName(:, biti * digitalij, pmui, CFG_2_3.counter))' '", status-flag: UNSET'])
                                else
                                    disp(['        Digital #'  num2str(biti) ': name: "' char(CFG_2_3.PMUsDigitalName(:, biti * digitalij, pmui, CFG_2_3.counter))' '", status-flag: SET'])
                                    
                                end
                            end
                        end
                    end
                end
                
            else; digitali = 0;
            end
            
        end
        a1 = a2 + 1;
        a2 = a2 + 2;
        
        if (SADF.verbose_debug)
            disp(['  Checksum (hex): "' dec2hex(swapbytes(typecast(data_raw(a1:a2),'uint16'))) '" [correct]'])   %Checksum (checked before we enter into data frame script)
            disp('_______________________________________________________________________________________________________');
            disp(' ');
        end
    end
end
