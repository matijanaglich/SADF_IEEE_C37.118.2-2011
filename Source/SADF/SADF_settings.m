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

%% SIMULATION SETTINGS
SADF.verbose_info = true;                      %Show status window output (SADF), default(false) - speed increase
SADF.verbose_debug = true;                     %Show command window output (PMU Messages), default(false) - speed increase
SADF.session_report = true;                    %Print SADF session report, default(true)
SADF.sim_time = (60)+1;                        %Max run time in SECONDS


%% PMU/PDC CONNECTION SETTINGS
SADF.com_mode = true;                          %For 'Commanded mode' select: true; for 'Spontaneous mode' select: false
SADF.protocol = 'tcp';                         %Transport protocol used, select: 'tcp'; 'udp'; or mixed 'tcp/udp' (where udp protocol and primary interface are for receiving DATA, and tcp protocol and secondary interface are for sending CMD and receiving HDR, CFG-1, CFG-2, CFG-3)

% Primary interface, used for 'tcp', 'udp' mode as outgoing and incoming connecton; and for mixed 'tcp/udp' mode as udp incoming connection
SADF.ip_address_primary = '192.168.1.1';       %PMU/PDC Primary interface IP Address
SADF.port_primary = 4701;                      %PMU/PDC Primary interface port number

% Secondary interface, used only for mixed 'tcp/udp' mode as a tcp incomming and outgoing connection
SADF.ip_address_secondary = '192.168.1.2';     %PMU/PDC Secondary interface IP Address, used only in case of mixed 'tcp/udp' transport protocol is used. Primary interface is used for incoming 'udp' connection configuration.
SADF.port_secondary = 6006;                    %PMU/PDC Secondary interface port number, used only in case of mixed 'tcp/udp' transport protocol is used. Primary interface is used for incoming 'udp' connection configuration.

% PMU/PDC device settings
SADF.device_id = 1;                            %PMU/PDC ID value
SADF.conf_fr_ver = 3;                          %For IEEE C37.118-2005 select: 2; for  IEEE C37.118-2011 select: 3


