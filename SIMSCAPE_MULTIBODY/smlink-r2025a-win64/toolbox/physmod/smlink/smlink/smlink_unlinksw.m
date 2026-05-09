function smlink_unlinksw
% Unregisters the Simscape Multibody Link add-in with SolidWorks.
% SolidWorks must be installed, and the add-in must already
% be registered with SolidWorks. Only works on Windows.

if strcmp(computer, 'PCWIN')
    arch = 'win32';
elseif strcmp(computer, 'PCWIN64')
    arch = 'win64';
else
    error(message('physmod:smlink:swaddin:WindowsOnly'));
end
dllPath = ['bin\' arch];
dllName = 'cl_sldwks2sm.dll';
fullDllPath = sprintf('\"%s\\%s\\%s\"', matlabroot, dllPath, dllName);
commandStr = ['regsvr32 /u ' fullDllPath];
disp (['Unregistering dll: ' commandStr]);

% invoke the DOS command.
system (commandStr, '-echo', '-runAsAdmin');
%-------------------------------------------------------------------------
