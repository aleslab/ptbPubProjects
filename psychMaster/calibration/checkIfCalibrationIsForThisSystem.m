function [ status, message ] = checkIfCalibrationIsForThisSystem( expInfo, calibInfo )
%checkIfCalibrationIsForThisSystem Checks if the calibration info matches the current system  
%  [ status, msg ] = checkIfCalibrationIsForThisSystem( expInfo, calibInfo )
% Detailed explanation goes here

message = '';

%Check a bunch of things to make sure the loaded calibrations were done on
%the correct system


currentComputer = Screen('Computer');


%The calibration is valid unless we find proof that it is not.
status = true;

%The following are checking for any differences between the information
%stored in the calibration info structure and the current computer/settings

%First check the display mode. 
if ~isequal(calibInfo.modeInfo,expInfo.modeInfo)
    status = false;
    message = 'Monitor display modes do not match';
end

%Now lets check the computer.

if ~strcmp(currentComputer.hw.machine,calibInfo.computer.hw.machine) ...
        || ~strcmp(currentComputer.hw.model,calibInfo.computer.hw.model)
    
    status = false;
    message = 'Computer machine and/or model string does not match';

end


%Check if we have the window info structure for comparing graphics card
%information.
if ~isfield(calibInfo.expInfo, 'windowInfo')
    warning('Calibration info missing graphics card information, likely due to calibration prior to 0.31.0');
    return
end

%Check graphics card model information
%NOTE: Fix this logic to work one minortype is not a string.
if ~strcmp( expInfo.windowInfo.GPUCoreId, calibInfo.expInfo.windowInfo.GPUCoreId) 
%     ...
%         || ~strcmp( expInfo.windowInfo.GPUMinorType, calibInfo.expInfo.windowInfo.GPUMinorType) ...
    status = false;
    message = 'Current graphics card model does not match calibration';
end

%Check the opengl version driver versions

if ~strcmp( expInfo.windowInfo.GLVersion, calibInfo.expInfo.windowInfo.GLVersion) ...
        || ~strcmp( expInfo.windowInfo.GLVendor, calibInfo.expInfo.windowInfo.GLVendor) ...
        || ~strcmp( expInfo.windowInfo.GLRenderer, calibInfo.expInfo.windowInfo.GLRenderer) ...

    status = false;
    message = 'Current graphics driver version is different from calibration';

end



end
