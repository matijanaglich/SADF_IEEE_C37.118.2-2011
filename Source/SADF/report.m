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

function report
    global CFG_1 CFG_2_3 DATA CMD HDR SADF
    
    disp('Session report: ');
    disp(['  Total sent command frames: ', int2str(CMD.counter)]);
    disp(['  Total received packages: ', int2str(HDR.counter + DATA.counter  + CFG_1.counter + CFG_2_3.counter)]);
    disp(['    Total received DATA frames: ', int2str(DATA.counter)]);
    disp(['    Total received CFG-1 frames: ', int2str(CFG_1.counter)]);
    disp(['    Total received CFG-2 or CFG-3 frames: ', int2str(CFG_2_3.counter)]);
    disp(['    Total received  HDR frames: ', int2str(HDR.counter)]);
    disp(['  Total received corrupted packages: ', int2str(HDR.counter_error + DATA.counter_error  + CFG_1.counter_error + CFG_2_3.counter_error + SADF.counter_error)]);
    disp(['    Total received corrupted DATA frames: ', int2str(DATA.counter_error)]);
    disp(['    Total received corrupted CFG-1 frames: ', int2str(CFG_1.counter_error)]);
    disp(['    Total received corrupted CFG-2 or CFG-3 frames: ', int2str(CFG_2_3.counter_error)]);
    disp(['    Total received corrupted HDR frames: ', int2str(HDR.counter_error)]);
    disp(['    Total received unknown TCP/UDP packets/frames: ', int2str(SADF.counter_error)]);
    disp(['  Total received duplicated packages: ', int2str(DATA.counter_duplicated + CFG_1.counter_duplicated + CFG_2_3.counter_duplicated)]);
    disp(['    Total received duplicated DATA frames: ', int2str(DATA.counter_duplicated)]);
    disp(['    Total received duplicated CFG-1 frames: ', int2str(CFG_1.counter_duplicated)]);
    disp(['    Total received duplicated CFG-2 or CFG-3 frames: ', int2str(CFG_2_3.counter_duplicated)]);
    disp(['  Total received not-in-order DATA frames: ', int2str(DATA.counter_notOrder)]);
    disp(['  Total discarded DATA frames: ', int2str(DATA.counter_discarded)]);
  end
