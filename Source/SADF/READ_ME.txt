%% Project: MATLAB supported Synchro-measurement Application Development Framework (SADF)
% Author: Matija Naglic
% Email: m.naglic@tudelft.nl
% Version: 2.0
% Date: 08/01/2018
% Reference paper: M. Naglic, M. Popov, M. Van Der Meijden, V. Terzija, "Synchro-measurement Application Development Framework: an IEEE Standard C37.118.2-2011 Supported MATLAB Library", IEEE Transactions on Instrumentation & Measurements, 2018 
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



Operation instructions:
- Verify the existence of C-compiler or similar and install it if needed. To check type "mex -setup" into MATLAB Command Window

- Edit "SADF_settings.m" file using a text editor or MATLAB Editor by typing "edit SADF_settings.m" in the MATLAB Command Window
  Set IP address of a PMU/PDC, UDP/TCP protocol used, and device ID of a PMU/PDC.

- Run the main script by typing "run SADF_run.m" in the MATLAB Command Window

- In case of flowing error:
	"
	Error using icinterface/fopen (line 83)
	Unsuccessful open: Connection refused: connect

	Error in ICT_initialisation (line 73)
	        fopen(SADF.Connection_primary);

	Error in SADF_run (line 58)
	ICT_initialisation();

	Error in run (line 86)
	evalin('caller', [script ';']);
	"	
please verify the connection parameters in "SADF_settings.m" file.

- to code a user-defied application, please edit the main loop in "SADF_run.m" and take a look into the example application "demo_WAMS.m"

- in case of problems please send an email to: m.naglic@tudelft.nl
