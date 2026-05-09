function smlink_linksw
% Registers the Simscape Multibody Link add-in with SolidWorks.
% This function works on Windows only. SolidWorks must also be installed.

if strcmp(computer, 'PCWIN')
    arch = 'win32';
elseif strcmp(computer,'PCWIN64')
    arch = 'win64';
else
    error(message('physmod:smlink:swaddin:WindowsOnly'));
end
dllPath = ['bin\' arch];
dllName = 'cl_sldwks2sm.dll';
fullDllPath = sprintf('\"%s\\%s\\%s\"', matlabroot, dllPath, dllName);
commandStr = ['regsvr32 ' fullDllPath];
disp (['Registering dll: ' commandStr]);

% invoke the DOS command.
system (commandStr, '-echo', '-runAsAdmin');
%-------------------------------------------------------------------------
