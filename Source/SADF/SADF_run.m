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


%% Make clean workspace
clc
clear all
close all force
instrreset
feature accel on
format short

%% Enable MATLAB process in real-time priority 
pid=feature('getpid');
[~,~] = system(sprintf('wmic process where processid="%d" CALL setpriority 256',pid));


%% Welcome message
disp('#############################################################################################################');
disp(' Welcome to MATLAB supported Synchro-measurement (IEEE C37.118 std.) Application Development Framework (SADF)');
disp(' Version: 2.0');
disp(' Developed by: Matija Naglic, EEMCS, TU Delft, e-mail: m.naglic@tudelft.nl');
disp('#############################################################################################################');
disp('_____________________________________________________________________________________________________________');
disp(' ');

%% PMU/PDC connection initialisation
global SADF DATA CFG_1 CFG_2_3 HDR CMD demo

% Simulation and PMU/PDC connection setting (edit before use)
SADF_settings();

% Variables initialisation
VAR_initialisation();

% ICT Connection initialisation
ICT_initialisation();

%% Start parsing the IEEE C37.118 std messages
while (toc(SADF.sim_start) < SADF.sim_time )
        
    IEEE_C37_118_2_parser();
    
    %Example application - Online PMU monitoring
    demo_WAMS();
    
    %%%%%                                                   %%%%%                                                 
    %%%                                                       %%%
    % Build your synchro-measurement supported application here %
    %%%                                                       %%%
    %%%%%                                                   %%%%% 
    
end

%% ICT Connection close
ICT_close();

% Print session report
if SADF.session_report; report(); end
