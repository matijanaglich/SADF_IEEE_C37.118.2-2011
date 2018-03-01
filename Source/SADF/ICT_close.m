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

function ICT_close()
    global SADF
    
    %Send STOP Request to PMU/PDC
    if SADF.DATA_recieved && SADF.com_mode
        command_frame('0001', 'sync');
    end
    
    if  isfield(SADF,'Connection_primary')
        stopasync(SADF.Connection_primary);
        fclose(SADF.Connection_primary);
        flushinput(SADF.Connection_primary);
        delete(SADF.Connection_primary);
        SADF = rmfield(SADF,'Connection_primary');
    end
    
    if  isfield(SADF,'Connection_secondary')
        stopasync(SADF.Connection_secondary);
        fclose(SADF.Connection_secondary);
        flushinput(SADF.Connection_secondary);
        delete(SADF.Connection_secondary);
        SADF = rmfield(SADF,'Connection_secondary');
    end
    
    instrreset
    
    if SADF.verbose_info || SADF.verbose_debug
        disp(' ');
        disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '    PMU/PDC connection closed']);
        disp('_______________________________________________________________________________________________________');
        disp(' ');
    end
end
