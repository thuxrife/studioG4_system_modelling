function smlink_unlinkinv
% Unregisters the Simscape Multibody Link add-in with Inventor.
% Inventor must be installed, and the add-in must already
% be registered with Inventor. Only works on Windows.

% Check for the supported platform win32 and win64
if strcmp(computer, 'PCWIN')
    arch = 'win32';
elseif strcmp(computer, 'PCWIN64')
    arch = 'win64';
else
    error(message('physmod:smlink:invaddin:WindowsOnly'));
end

dllPath = ['bin\' arch];
dllName = 'cl_inventor2sm.dll';
fullDllPath = sprintf('\"%s\\%s\\%s\"', matlabroot, dllPath, dllName);
commandStr = ['regsvr32 /u ' fullDllPath];
disp (['Unregistering dll: ' commandStr]);

% invoke the DOS command.
system (commandStr, '-echo', '-runAsAdmin');
%-------------------------------------------------------------------------
