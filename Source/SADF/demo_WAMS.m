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


%% demo, Online PMU monitoring
function demo_WAMS()
    global DATA CFG_2_3 demo
    
 
    if ~isfield(demo,'window')   %demo VAR initialisation
        figure('units', 'normalized', 'outerposition', [0 0 1 1], 'name','Synchro-measurement Application Development Framework');
        demo.window = 50; %display_samples
        demo.phasor = 1;
        demo.processed = 0;
    end
    
    if DATA.index_max >  demo.processed %Check for new data
        
        demo.processed = DATA.index_max;
        clf;
        hold on;
        title_plot=[];
        
        for i = 1:CFG_2_3.Num_PMU(CFG_2_3.counter, 1)
            if DATA.index_max <= demo.window
                demo.dataset = [DATA.TimeStamp(1:DATA.index_max,1) DATA.Magnitude(1:DATA.index_max,demo.phasor,i)];
            else
                demo.dataset = [DATA.TimeStamp(DATA.index_max-demo.window:DATA.index_max,1) DATA.Magnitude(DATA.index_max-demo.window:DATA.index_max,demo.phasor,i)];
            end
            stairs(demo.dataset(~isnan(demo.dataset(:,1)),1), demo.dataset(~isnan(demo.dataset(:,1)),2));
            title_plot = [title_plot strtrim(char(CFG_2_3.Station_Name(:, i))') ' - ' strtrim(char(CFG_2_3.PMUsPhasorName(:, demo.phasor, i))') ', '];
        end
        
        ax = gca;
        ax.XTick = demo.dataset(~isnan(demo.dataset(:,1)),1);
        if CFG_2_3.PMUsPhasorUnit(1, demo.phasor, i) == 1; pmu_unit = 'current magnitude (I)'; else; pmu_unit = 'voltage magnitude (V)'; end
        xlabel('timestamp (UTC)'); ylabel(pmu_unit);
        title(['Online Monitoring: ' title_plot ])
        grid on
        datetick('x', 'dd-mm-yyyy HH:MM:SS.FFF', 'keeplimits', 'keepticks')
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'XTickLabelRotation', 45)
        set(findall(gca, 'Type', 'Line'),'LineWidth',1);
        drawnow
        % disp([datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF') '  PLOT ']);
    end
end
