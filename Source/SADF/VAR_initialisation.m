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

function VAR_initialisation()
    global  SADF DATA CFG_1 CFG_2_3 CMD HDR
    
    %% VARIABLES INITIALISATION
    SADF.counter_error = 0;
    HDR.counter_error = 0;
    DATA.counter_error = 0;
    CFG_1.counter_error = 0;
    CFG_2_3.counter_error = 0;
    CMD.counter = 0;
    DATA.counter = 0;
    DATA.counter_discarded = 0;
    DATA.counter_duplicated = 0;
    DATA.counter_notOrder = 0;
    DATA.index_max = 0;
    CFG_1.counter = 0;
    CFG_1.counter_duplicated = 0;
    CFG_2_3.counter = 0;
    CFG_2_3.counter_duplicated = 0;
    HDR.counter = 0;
    SADF.HDR_recieved = false;
    SADF.CFG_1_recieved = false;
    SADF.CFG_2_3_recieved = false;
    SADF.DATA_recieved = false;
    SADF.resend_wait = 0; %used for command resend
    SADF.resend_wait_2 = 0; %used to silence the communication channel
    SADF.sim_start = tic;
    SADF.reset_wait = toc(SADF.sim_start) + 10; % Use to reset ICT connection if nothing happens in 5 seconds
    
    if ~ strcmpi(SADF.protocol,'tcp') %if spontaneous mode
        SADF.UDP_firewall = false;
        SADF.UDP_received = 0;
        SADF.UDP_processed = 0;
        SADF.UDP_size_sum = NaN(SADF.sim_time * 50,1); % Here we assume the reporting rate will be 50
    end
end
