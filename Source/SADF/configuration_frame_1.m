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

function  configuration_frame_1(data_raw)
    global CFG_1 SADF
    
    if  CFG_1.counter == 0 || CFG_1.Config_Counter(CFG_1.counter, 1) < swapbytes(typecast(data_raw(swapbytes(typecast(data_raw(3:4),'uint16'))-5:swapbytes(typecast(data_raw(3:4),'uint16'))-4),'uint16'))
        
        SADF.CFG_1_recieved = true;
        SADF.reset_wait = toc(SADF.sim_start) + 10;
        CFG_1.counter = CFG_1.counter + 1;
        CFG_1.CodeID(CFG_1.counter, :) = swapbytes(typecast(data_raw(5:6), 'uint16'));
        %CFG_1.SOC=datenum([1970 1 1 0 0 double(swapbytes(typecast(data_raw(7:10), 'uint32')))]);
        CFG_1.SOC(CFG_1.counter, :) = 719529 + double(swapbytes(typecast(data_raw(7:10), 'uint32'))) / 864e2;
        CFG_1.Time_Quality(CFG_1.counter, :) = dec2bin(data_raw(11),8);
        CFG_1.FOS(CFG_1.counter, :) = double(swapbytes(typecast([0; data_raw(12:14)], 'uint32')));
        CFG_1.Time_Base(CFG_1.counter, :) = double(swapbytes(typecast(data_raw(15:18),'uint32')));
        CFG_1.Num_PMU(CFG_1.counter, :) = double(swapbytes(typecast(data_raw(19:20),'uint16')));
        
        if (SADF.verbose_info || SADF.verbose_debug)
            disp([   datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 CFG-1']);
        end
        
        if (SADF.verbose_debug)
            
            CFG_1.RAW_config_1(1:length(data_raw), CFG_1.counter) = data_raw;
            
            switch CFG_1.Time_Quality(CFG_1.counter,5:8)
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
            
            disp(['  Synchronization word (hex): "AA31"']); %checked before entered
            disp(['  Framesize: ' num2str(swapbytes(typecast(data_raw(3:4),'uint16'))) ' Bytes']);
            disp(['  PMU/PDC ID number: ' num2str(CFG_1.CodeID(CFG_1.counter, :))]);
            disp(['  SOC timestamp: ' datestr(CFG_1.SOC(CFG_1.counter, :), 'yyyy-mm-dd HH:MM:SS')]);
            disp('  Time quality flags: ');
            if CFG_1.Time_Quality(CFG_1.counter,2) == '1'; disp('    Leap second direction'); end
            if CFG_1.Time_Quality(CFG_1.counter,3) == '1'; disp('    Leap second occurred'); end
            if CFG_1.Time_Quality(CFG_1.counter,4) == '1'; disp('    Leap second pending'); end
            disp(['    Time quality indicator: ' leapTQ]);
            disp(['  Fraction of second (raw): ' num2str(CFG_1.FOS(CFG_1.counter, :))]);
            disp(['  Resolution of fractional second time stamp: ' num2str(CFG_1.Time_Base(CFG_1.counter, :))]);
            disp(['  Number of PMU blocks included in the frame: ' num2str(CFG_1.Num_PMU(CFG_1.counter, :))]);
        end
        
        a2 = 20; %Header part
        for pmui = 1 : CFG_1.Num_PMU(CFG_1.counter, :)
            a1 = a2 + 1;
            a2 = a2 + 16;
            CFG_1.Station_Name(:, pmui, CFG_1.counter) = data_raw(a1:a2);
            
            a1 = a2 + 1;
            a2 = a2 + 2;
            CFG_1.PMUsID(1, pmui, CFG_1.counter) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
            
            a1 = a2 + 1;
            a2 = a2 + 2;
            CFG_1.PMUsDataFormat(1:8, pmui, CFG_1.counter) = uint8(dec2bin(swapbytes(typecast(data_raw(a1:a2),'uint16')),8) - '0');
            
            pmuformat=[];
            if CFG_1.PMUsDataFormat(5, pmui, CFG_1.counter) == 1; pmuformat(:,1) = uint16('"IEEE floating point"'); else; pmuformat(:,1) = uint16('"16-bit integer"     '); end
            if CFG_1.PMUsDataFormat(6, pmui, CFG_1.counter) == 1; pmuformat(:,2) = uint16('"IEEE floating point"'); else; pmuformat(:,2) = uint16('"16-bit integer"     '); end
            if CFG_1.PMUsDataFormat(7, pmui, CFG_1.counter) == 1; pmuformat(:,3) = uint16('"IEEE floating point"'); else; pmuformat(:,3) = uint16('"16-bit integer"     '); end
            if CFG_1.PMUsDataFormat(8, pmui, CFG_1.counter) == 1; pmunotation= ('"magnitude and angle (polar)"'); else; pmunotation= ('"real and imaginary (rectangular)"     '); end
            
            a1 = a2 + 1;
            a2 = a2 + 2;
            CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
            
            a1 = a2 + 1;
            a2 = a2 + 2;
            CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
            
            a1 = a2 + 1;
            a2 = a2 + 2;
            CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
            
            if (SADF.verbose_debug)
                disp(' ');
                disp(['    Station #' num2str(pmui) ': "' char(CFG_1.Station_Name(:, pmui, CFG_1.counter))' '"']);
                disp(['      PMU/PDC ID number: ' num2str(CFG_1.PMUsID(1, pmui, CFG_1.counter))])
                disp('      Data format in data frame')
                disp(['        FREQ/DFREQ format: ' char(pmuformat(:,1)')])
                disp(['        Analog values format: ' char(pmuformat(:,2)')])
                disp(['        Phasor format: ' char(pmuformat(:,3)')])
                disp(['        Phasor notation: ' pmunotation])
                disp(['      Number of phasors: ' num2str(CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter))])
                disp(['      Number of analog values: ' num2str(CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter))])
                disp(['      Number of digital status words: ' num2str(CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter))])
            end
            
            if CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter) > 0
                if (SADF.verbose_debug); disp(['      Phasor names (' num2str(CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter)) ')']); end
                for phasori = 1 : CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter)
                    a1 = a2 + 1;
                    a2 = a2 + 16;
                    CFG_1.PMUsPhasorName(:, phasori, pmui, CFG_1.counter) = data_raw(a1:a2);
                    if (SADF.verbose_debug); disp(['        Phasor #' num2str(phasori) ': name: "' char(CFG_1.PMUsPhasorName(:, phasori, pmui, CFG_1.counter))' '"']); end
                end
            end
            
            if CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter) > 0
                if (SADF.verbose_debug); disp(['      Analog names (' num2str(CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter)) ')']); end
                for analogi = 1 : CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter)
                    a1 = a2 + 1;
                    a2 = a2 + 16;
                    CFG_1.PMUsAnalogName(:, analogi, pmui, CFG_1.counter) = data_raw(a1:a2);
                    if (SADF.verbose_debug); disp(['        Analog #'  num2str(analogi) ': name: "' char(CFG_1.PMUsAnalogName(:, analogi, pmui, CFG_1.counter))' '"']); end
                end
            end
            
            if CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter) > 0
                if (SADF.verbose_debug); disp(['      Digital names (' num2str(CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter)) ')']); end
                for digitali = 1 : CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter)*16  %1 status = 16-bit boolean number
                    a1 = a2 + 1;
                    a2 = a2 + 16;
                    CFG_1.PMUsDigitalName(:, digitali, pmui, CFG_1.counter) = data_raw(a1:a2);
                    if (SADF.verbose_debug); disp(['        Digital #' num2str(digitali) ': name: "' char(CFG_1.PMUsDigitalName(:, digitali, pmui, CFG_1.counter))' '"']); end
                end
                
            end
            
            %If PHASORs are available, read them
            if CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter) > 0
                if (SADF.verbose_debug); disp(['      Phasor conversation factors (' num2str(CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter)) ')']); end
                for phasori = 1 : CFG_1.PMUsPhasorNum(1, pmui, CFG_1.counter)
                    a1 = a2 + 1;
                    a2 = a2 + 4;
                    tmp_pmuFU=dec2bin(data_raw(a1:a2),8)';
                    
                    CFG_1.PMUsPhasorFactor(:,phasori, pmui, CFG_1.counter) = bin2dec(tmp_pmuFU(9:end));
                    CFG_1.PMUsPhasorUnit(:, phasori, pmui, CFG_1.counter) = bin2dec(tmp_pmuFU(1:8));
                    if (SADF.verbose_debug)
                        if CFG_1.PMUsPhasorUnit(:, phasori, pmui, CFG_1.counter) ==1; pmuunit= '"Ampere"'; else; pmuunit= '"Volt"'; end
                        disp(['        Phasor #' num2str(phasori) ': factor: ' num2str(CFG_1.PMUsPhasorFactor(:, phasori, pmui, CFG_1.counter)) ', unit: ' pmuunit  ]);
                    end
                end
            end
            
            %If ANALOGs are available, read them
            if CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter) > 0
                if (SADF.verbose_debug); disp(['      Analog conversation factors (' num2str(CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter)) ')']); end
                for analogi = 1 : CFG_1.PMUsAnalogNum(1, pmui, CFG_1.counter)
                    a1 = a2 + 1;
                    a2 = a2 + 1;
                    CFG_1.PMUsAnalogType(:, analogi, pmui, CFG_1.counter) = double(data_raw(a1:a2));
                    
                    a1 = a2 + 1;
                    a2 = a2 + 3;
                    CFG_1.PMUsAnalogFactor(:,analogi, pmui, CFG_1.counter) = double(swapbytes(typecast([0; data_raw(a1:a2)], 'uint32')));
                    
                    if (SADF.verbose_debug)
                        switch CFG_1.PMUsAnalogType(:, analogi, pmui, CFG_1.counter)
                            case 0
                                pmuunit= '"single point-on-wave"';
                            case 1
                                pmuunit= '"rms of analog input"';
                            case 2
                                pmuunit= '"peak of analog input"';
                            otherwise
                                pmuunit= '"user defined"';
                        end
                        disp(['        Analog #' num2str(analogi) ': factor: ' num2str(CFG_1.PMUsAnalogFactor(:, analogi, pmui, CFG_1.counter)) ', unit: ' pmuunit  ]);
                    end
                end
            end
            
            %If DIGITALs are available, read them
            if CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter) > 0
                if (SADF.verbose_debug); disp(['      Mask for digital status 16-bit words (' num2str(CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter)) ')']); end
                for digitali = 1 : CFG_1.PMUsDigitalNum(1, pmui, CFG_1.counter)
                    a1 = a2 + 1;
                    a2 = a2 + 4;
                    tmp_pmuD=dec2bin(data_raw(a1:a2),8)';
                    
                    CFG_1.PMUsDigitalStatus(:,digitali, pmui, CFG_1.counter) = bin2dec(tmp_pmuD(1:end));
                    if (SADF.verbose_debug)
                        disp(['        Digital #' num2str(digitali) ': normal state: "' tmp_pmuD(1:16) '", valid bits: "' tmp_pmuD(17:end) '"']);
                    end
                end
            end
            
            %PMU nominal line freq
            a1 = a2 + 1;
            a2 = a2 + 2;
            
            if  swapbytes(typecast(data_raw(a1:a2),'uint16')) == 0
                CFG_1.PMUsFreqNominal(1, pmui, CFG_1.counter) = 60;
            else
                CFG_1.PMUsFreqNominal(1, pmui, CFG_1.counter) = 50;
            end
            
            if (SADF.verbose_debug); disp(['      Nominal line frequency: ' num2str(CFG_1.PMUsFreqNominal(1, pmui, CFG_1.counter)) ' Hz']); end
            
            %PMU config change rate count
            a1 = a2 + 1;
            a2 = a2 + 2;
            CFG_1.Config_Counter(CFG_1.counter, :) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
            if (SADF.verbose_debug); disp(['      Configuration change count: ' num2str(CFG_1.Config_Counter(CFG_1.counter, :)) ]); end
        end
        
        %PMU Frame rate (fps)
        a1 = a2 + 1;
        a2 = a2 + 2;
        CFG_1.Data_Rate(CFG_1.counter, :) = swapbytes(typecast(data_raw(a1:a2),'uint16'));
        
        %Checksum (checked before we enter into config-2 frame script)
        a1 = a2 + 1;
        a2 = a2 + 2;
        if (SADF.verbose_debug)
            disp(['  Rate of transmission: ' num2str(CFG_1.Data_Rate(CFG_1.counter, :)) ' frame(s) per second' ]);
            disp(['  Checksum (hex): ' dec2hex(swapbytes(typecast(data_raw(a1:a2),'uint16'))) ' [correct]'])
            disp('_______________________________________________________________________________________________________');
            disp(' ');
        end
    else
        CFG_1.counter_duplicated = CFG_1.counter_duplicated + 1;
        SADF.CFG_1_recieved = true;
        
        if (SADF.verbose_info || SADF.verbose_debug)
            disp([   datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    RCV - IEEE C37.118.2 CFG-1, duplicated']);
            disp('_______________________________________________________________________________________________________');
            disp(' ');
        end
    end
end
