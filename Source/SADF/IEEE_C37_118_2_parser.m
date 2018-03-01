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

function IEEE_C37_118_2_parser()
    
    global SADF
    
    if  ~SADF.tcp && ~SADF.UDP_firewall   %%Temporary used just to open firewall ports
        SADF.UDP_firewall = true;
        command_frame('0007', 'sync');
    end
    
    time_sim_start = toc(SADF.sim_start);
    
    while (SADF.com_mode && get(SADF.Connection_primary,'BytesAvailable') > 0) || (~SADF.com_mode && SADF.UDP_received > SADF.UDP_processed) || (SADF.tcp_udp && get(SADF.Connection_secondary,'BytesAvailable') > 0)
        
        if  SADF.tcp || SADF.udp && SADF.com_mode %TCP or UDP Commanded mode of communication
            if ~SADF.HDR_recieved || ~SADF.CFG_2_3_recieved || ~SADF.CFG_1_recieved
                %Read whole TCP/UDP buffer size
                data_raw = zeros(get(SADF.Connection_primary,'BytesAvailable'), 1, 'uint8');
                data_raw = uint8(fread(SADF.Connection_primary, get(SADF.Connection_primary,'BytesAvailable')));
            else
                %Read DATA frame size TCP/UDP buffer size specified in CFG-2/CFG-3
                data_raw = zeros(SADF.data_size_sum,1, 'uint8');
                data_raw = uint8(fread(SADF.Connection_primary, SADF.data_size_sum)); %by default it reads in uint8 format precision
            end
            
        elseif SADF.udp && ~SADF.com_mode %UDP Spontaneous mode of communication
            %Read UDP buffer size specified in MATLAB DatagramReceivedFcn
            SADF.UDP_processed = SADF.UDP_processed + 1;
            data_raw = uint8(fread(SADF.Connection_primary, SADF.UDP_size_sum(SADF.UDP_processed))); %by default it reads in uint8 format precision
            
        elseif  SADF.tcp_udp  %Mix of UDP and TCP Commanded mode of communication
            if get(SADF.Connection_secondary,'BytesAvailable') > 0
                %Read whole TCP buffer size
                data_raw = zeros(get(SADF.Connection_secondary,'BytesAvailable'), 1, 'uint8');
                data_raw = uint8(fread(SADF.Connection_secondary, get(SADF.Connection_secondary,'BytesAvailable')));
                
            else
                %Read UDP DATA frame size specified in MATLAB DatagramReceivedFcn
                data_raw = zeros(SADF.data_size_sum, 1, 'uint8');
                data_raw = fread(SADF.Connection_primary, SADF.data_size_sum); %by default it reads in uint8 format precision
                
            end
        end
        
        switch swapbytes(typecast(data_raw(1:2), 'uint16')) %Check Frame SYNC code
            case 43521 %hex2dec('AA01') DATA frame read from input buffer
                if (SADF.HDR_recieved && SADF.CFG_2_3_recieved && crc_16_CCITT_8bit(data_raw(1:end-2)) == swapbytes(typecast(data_raw(end-1:end),'uint16')) &&  swapbytes(typecast(data_raw(5:6), 'uint16'))== SADF.device_id)
                    SADF.reset_wait = time_sim_start + 10;
                    data_frame(data_raw);
                    
                else
                    if SADF.CFG_2_3_recieved && crc_16_CCITT_8bit(data_raw(1:end-2)) ~= swapbytes(typecast(data_raw(end-1:end),'uint16'))
                        error_frame(1, data_raw);
                        
                    elseif SADF.CFG_2_3_recieved && swapbytes(typecast(data_raw(5:6), 'uint16')) ~= SADF.device_id
                        error_frame(1.1, data_raw);
                        
                    elseif ~SADF.CFG_2_3_recieved &&  swapbytes(typecast(data_raw(5:6), 'uint16')) == SADF.device_id
                        error_frame(1.2, data_raw);
                        
                        % Send STOP DATA Command to PMU/PDC
                        if time_sim_start > SADF.resend_wait_2 && SADF.com_mode
                            SADF.resend_wait_2 = time_sim_start + 2;
                            command_frame('0001', 'async');
                        end
                        
                    elseif ~SADF.CFG_2_3_recieved && swapbytes(typecast(data_raw(5:6), 'uint16')) ~= SADF.device_id
                        error_frame(1.3, data_raw);
                    end
                end
                
            case 43537  %hex2dec('AA11') HDR frame read from input buffer
                if (crc_16_CCITT_8bit(data_raw(1:end-2)) == swapbytes(typecast(data_raw(end-1:end),'uint16')) &&  swapbytes(typecast(data_raw(5:6), 'uint16'))== SADF.device_id || crc_16_CCITT_8bit(data_raw(1:end-2)) == swapbytes(typecast(data_raw(end-1:end),'uint16')) &&  swapbytes(typecast(data_raw(5:6), 'uint16'))== 0)  %IDCODE = 0 in case of OpenPDC
                    header_frame(data_raw);
                    
                else
                    if crc_16_CCITT_8bit(data_raw(1:end-2)) ~= swapbytes(typecast(data_raw(end-1:end),'uint16'))
                        error_frame(2, data_raw);
                        
                    elseif swapbytes(typecast(data_raw(5:6), 'uint16')) ~= SADF.device_id
                        error_frame(2.1, data_raw);
                    end
                end
                
            case 43553  %hex2dec('AA21') CFG-1 frame read from input buffer
                if (crc_16_CCITT_8bit(data_raw(1:end-2)) == swapbytes(typecast(data_raw(end-1:end),'uint16')) &&  swapbytes(typecast(data_raw(5:6), 'uint16'))== SADF.device_id)
                    configuration_frame_1(data_raw);
                    
                else
                    if crc_16_CCITT_8bit(data_raw(1:end-2)) ~= swapbytes(typecast(data_raw(end-1:end),'uint16'))
                        error_frame(3, data_raw);
                        
                    elseif swapbytes(typecast(data_raw(5:6), 'uint16')) ~= SADF.device_id
                        error_frame(3.1, data_raw);
                    end
                end
                
            case 43569  %hex2dec('AA31') CFG-2 frame read from input buffer
                if (crc_16_CCITT_8bit(data_raw(1:end-2)) == swapbytes(typecast(data_raw(end-1:end),'uint16')) &&  swapbytes(typecast(data_raw(5:6), 'uint16'))== SADF.device_id)
                    configuration_frame_2(data_raw);
                    
                else
                    if crc_16_CCITT_8bit(data_raw(1:end-2)) ~= swapbytes(typecast(data_raw(end-1:end),'uint16'))
                        error_frame(4, data_raw);
                        
                    elseif swapbytes(typecast(data_raw(5:6), 'uint16')) ~= SADF.device_id
                        error_frame(4.1, data_raw);
                    end
                end
                
            case 43602 %hex2dec('AA52') CFG-3 frame read from input buffer
                if (crc_16_CCITT_8bit(data_raw(1:end-2)) == swapbytes(typecast(data_raw(end-1:end),'uint16')) &&  swapbytes(typecast(data_raw(5:6), 'uint16'))== SADF.device_id)
                    configuration_frame_3(data_raw);
                    
                else
                    if crc_16_CCITT_8bit(data_raw(1:end-2)) ~= swapbytes(typecast(data_raw(end-1:end),'uint16'))
                        error_frame(5, data_raw);
                        
                    elseif swapbytes(typecast(data_raw(5:6), 'uint16')) ~= SADF.device_id
                        error_frame(5.1, data_raw);
                    end
                end
                
            otherwise %% Unknown MSG received
                error_frame(6, data_raw);
        end
    end
    
    if SADF.com_mode  %Commanded mode communication
        if time_sim_start > SADF.reset_wait %Implementation of fall-back algorithm
            if ~SADF.HDR_recieved  %In case device does not support HDF frame request
                SADF.HDR_recieved = true;
                SADF.reset_wait = time_sim_start + 10;
                
                if SADF.verbose_info || SADF.verbose_debug
                    disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    Skipping HDR request, switching to CFG-1 request']);
                    if (SADF.verbose_debug)
                        disp('_______________________________________________________________________________________________________');
                        disp(' ');
                    end
                end
                
            elseif ~SADF.CFG_1_recieved %In case device does not support CFG-1 frame request
                SADF.CFG_1_recieved = true;
                SADF.CFG_2_3_recieved = false;
                SADF.reset_wait = time_sim_start + 10;
                
                if SADF.verbose_info || SADF.verbose_debug
                    disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    Skipping CFG-1 request, switching to CFG-2/CFG-3 request']);
                    if (SADF.verbose_debug)
                        disp('_______________________________________________________________________________________________________');
                        disp(' ');
                    end
                end
                
            elseif ~SADF.CFG_2_3_recieved && SADF.conf_fr_ver == 3 %In case device does not support CFG-3 frame request
                SADF.conf_fr_ver = 2;
                SADF.reset_wait = time_sim_start + 10;
                
                if SADF.verbose_info || SADF.verbose_debug
                    disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    Skipping CFG-3 request, switching to CFG-2 request']);
                    if (SADF.verbose_debug)
                        disp('_______________________________________________________________________________________________________');
                        disp(' ');
                    end
                end
                
            else
                % ICT Connection reset
                ICT_initialisation();
                SADF.reset_wait = time_sim_start + 10;
            end
            
            
        elseif ~SADF.DATA_recieved % CMD data requests
            if ~SADF.HDR_recieved && time_sim_start > SADF.resend_wait
                SADF.resend_wait = time_sim_start + 2;
                
                % Send HDR frame request
                command_frame('0003', 'async');
                
            elseif ~SADF.CFG_1_recieved && time_sim_start > SADF.resend_wait
                SADF.resend_wait = time_sim_start + 2;
                
                % Send CFG 1 frame request
                command_frame('0004', 'async');
                
            elseif ~SADF.CFG_2_3_recieved && time_sim_start > SADF.resend_wait
                SADF.resend_wait = time_sim_start + 2;
                
                % Send CFG 2 or 3 frame request
                if SADF.conf_fr_ver == 2
                    command_frame('0005', 'async');
                elseif SADF.conf_fr_ver == 3
                    command_frame('0006', 'async');
                end
                
            elseif SADF.CFG_2_3_recieved && time_sim_start > SADF.resend_wait
                SADF.resend_wait = time_sim_start + 2;
                
                %Send START DATA Command to PMU/PDC
                command_frame('0002', 'async');
            end
        end
    end
end
