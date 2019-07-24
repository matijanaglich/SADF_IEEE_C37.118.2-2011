# Synchro-measurement Application Development Framework: an IEEE Standard C37.118.2-2011 Supported MATLAB Library

Synchro-measurement Application Development Framework (SADF) is a MATLAB supported library to facilitate simplified design and online validation of advanced closed-loop control Wide Area Monitoring, Protection, and Control (WAMPAC) applications, as well as PMU/PDC performance and compliance verification under realistic conditions. 
The SADF enables a seamless integration between the Synchronized Measurement Technology (SMT) supported electric power system and synchro-measurement supported user-defined applications. This is done by online receiving and parsing of IEEE Std. C37.118-2005 and C37.118.2-2011 specified machine-readable messages into a human-readable MATLAB format. SADF enables receiving of TCP, UDP, or TCP/UDP synchro-measurement data stream by using either "commanded" or "spontaneous" mode. Combining this library with MATLAB's signal processing and visualization functions allows mastering the design and validation of complex WAMPAC applications.

For details: https://doi.org/10.1109/TIM.2018.2807000

## **Content**
- Matlab scripts to enable fully automated online receiving and parsing of PMU/PDC data stream (IEEE Standard C37.118-2005 and IEEE Standard C37.118.2-2011) content into a user-friendly format.

- Example application for online Voltage Magnitude Monitoring. The plotting automatically displays voltage magnitude channels of all available PMU stations.


## **Quick-start documentation**
- Edit "SADF_settings.m" file using a text editor or MATLAB Editor by typing "edit SADF_settings.m" in the MATLAB Command Window.
  Set IP address of a PMU/PDC, UDP/TCP protocol used, and device ID of a PMU/PDC.

- Run the main script by typing "run SADF_run.m" in the MATLAB Command Window.

- For speed increase (optionally): Verify the existence of a C-compiler and install it if needed. To check this type "mex -setup" into     MATLAB Command Window. Navigate into "crc_16_CCITT_8bit_sources/" directory and open "crc_16_CCITT_8bit.prj", and compile mex file for your own MATLAB version. Afterwards rename the existing "crc_16_CCITT_8bit.m" file in the root SADF folder into "crc_16_CCITT_8bit_matlab(bck).m" and copy the newly MEX generated file instead with the name "crc_16_CCITT_8bit.mexw64". This will increase the execution speed of SADF.

- In case of flowing error:

      Error using icinterface/fopen (line 83)
      Unsuccessful open: Connection refused: connect
      Error in ICT_initialisation (line 73)
      fopen(SADF.Connection_primary);
      Error in SADF_run (line 58)	
      ICT_initialisation();
      Error in run (line 86)
      evalin('caller', [script ';']);	
	
     please verify the connection parameters in "SADF_settings.m" file. 

- to code a user-defied application, please edit the main loop in "SADF_run.m" and take a look into the example application "demo_WAMS.m"

## **Support** ##
**For support and referring:**
**_M. Naglic, M. Popov, M. Meijden and V. Terzija, “Synchro-measurement Application Development Framework: an IEEE Standard C37.118.2-2011 Supported MATLAB Library,” IEEE Transactions on Instrumentation and Measurement, vol. 67, no. 8, pp. 1804–1814, Aug. 2018._**

**_Paper DOI: https://doi.org/10.1109/TIM.2018.2807000_**

In case of problems please send an email.
