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

function command_frame(CMDi, writeasync)
    global CMD SADF
    
    CMD.counter = CMD.counter + 1;
    SYNC = 'AA41'; %Command frame HEX
    FRAMESIZE = '0000'; %It is recalculated at the end
    IDCODE = sprintf('%.4X', SADF.device_id); %PMU/PDC ID code
    time_now = now;
    %SOC = sprintf('%.8X', int32(dateNumToUnixTime(time_now)));
    SOC = sprintf('%.8X', int32(round(864e2 * (time_now - 719529)))); % datenum to Unix
    Time_Quality = '00000000'; %Modify according to time source quality
    TQ = sprintf('%.4X', bin2dec(Time_Quality));
    FOS = sprintf('%.4X', str2double(datestr(time_now, 'FFF')));
    raw_HEX_data = [SYNC FRAMESIZE IDCODE SOC TQ FOS CMDi];
    FRAMESIZE = sprintf('%.4X', (length(raw_HEX_data) + 4) / 2); % +4 due to CRC CHK at the end
    raw_HEX_data = [SYNC FRAMESIZE IDCODE SOC TQ FOS CMDi];
    message = uint8(hex2dec(regexp(raw_HEX_data, '\w{1,2}', 'match')));
    CRC=typecast(crc_16_CCITT_8bit(message),'uint8');
    message=[message; CRC(2); CRC(1)];
    
    switch CMDi
        case '0001'
            command='"turn off DATA"';
        case '0002'
            command='"turn on DATA"';
        case '0003'
            command='"send HDR"';
        case '0004'
            command='"send CFG-1"';
        case '0005'
            command='"send CFG-2"';
        case '0006'
            command='"send CFG-3"';
        case '0008'
            command='"send EXT"';
        case '0007'
            command='"Opening UDP port"';
        otherwise
            command='"ERROR, unknown command"';
    end
    
    if (SADF.verbose_info || SADF.verbose_debug)
        disp([   datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    SND - IEEE C37.118.2 CMD: ' command]);
    end
    
    if (SADF.verbose_debug)
        
        CMD.RAW_command(1:length(message), CMD.counter) = message;
        
        switch Time_Quality(5:8)
            case '1111'
                leapTQ=('"Fault-clock failure, time not reliable"');
            case '1011'
                leapTQ=('"Time within 10 s of UTC"');
            case '1010'
                leapTQ=('"Time within 1 s of UTC"');
            case '1001'
                leapTQ=('"Time within 10^-1 s of UTC"');
            case '1000'
                leapTQ=('"Time within 10^-2 s of UTC"');
            case '0111'
                leapTQ=('"Time within 10^-3 s of UTC"');
            case '0110'
                leapTQ=('"Time within 10^-4 s of UTC"');
            case '0101'
                leapTQ=('"Time within 10^-5 s of UTC"');
            case '0100'
                leapTQ=('"Time within 10^-6 s of UTC"');
            case '0011'
                leapTQ=('"Time within 10^-7 s of UTC"');
            case '0010'
                leapTQ=('"Time within 10^-8 s of UTC"');
            case '0001'
                leapTQ=('"Time within 10^-9 s of UTC"');
            case '0000'
                leapTQ=('"Normal operation, clock locked to UTC traceable source"');
            otherwise
                leapTQ=('"error reading"');
        end
        
        disp(['  Synchronization word (hex): "' SYNC '"']);
        disp(['  Framesize: ' num2str(hex2dec(FRAMESIZE)) ' Bytes']);
        disp(['  PMU/PDC ID number: ' num2str(SADF.device_id)]);
        disp(['  SOC timestamp: ' datestr(time_now, 'yyyy-mm-dd HH:MM:SS')]);   %%CHECK this and try to make it nicer
        disp('  Time quality flags: ');
        if Time_Quality(2) == '1'; disp('    Leap second direction'); end
        if Time_Quality(3) == '1'; disp('    Leap second occurred'); end
        if Time_Quality(4) == '1'; disp('    Leap second pending'); end
        disp(['    Time quality indicator: ' leapTQ]);
        disp(['  Fraction of second (raw): ' num2str(hex2dec(FOS))]);
        disp('_______________________________________________________________________________________________________');
        disp(' ');
    end
    
    if ~SADF.tcp_udp ||  strcmpi(CMDi,'0007')
        flushinput(SADF.Connection_primary);
        flushoutput(SADF.Connection_primary);
        fwrite(SADF.Connection_primary, message, 'uint8', writeasync)
    else
        flushinput(SADF.Connection_primary);
        flushoutput(SADF.Connection_secondary);
        fwrite(SADF.Connection_secondary, message, 'uint8', writeasync)
    end
    
    %Save command in log
    CMD.DeviceID(CMD.counter, 1) = SADF.device_id;
    CMD.TimeSent(CMD.counter, 1) = time_now;
    CMD.Command(CMD.counter, 1:length(double(command))) = double(command);
end
