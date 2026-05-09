function smlink_linkinv
% Registers the Simscape Multibody Link add-in with Inventor.
% This function works on Windows only. Inventor must also be installed.

if strcmp(computer, 'PCWIN')

%   Copyright 2015 The MathWorks, Inc.

    arch = 'win32';
elseif strcmp(computer,'PCWIN64')
    arch = 'win64';
else
    error(message('physmod:smlink:invaddin:WindowsOnly'));
end
dllPath = ['bin\' arch];
dllName = 'cl_inventor2sm.dll';
fullDllPath = sprintf('\"%s\\%s\\%s\"', matlabroot, dllPath, dllName);
commandStr = ['regsvr32 ' fullDllPath];
disp (['Registering dll: ' commandStr]);

% invoke the DOS command.
system (commandStr, '-echo', '-runAsAdmin');
%-------------------------------------------------------------------------
