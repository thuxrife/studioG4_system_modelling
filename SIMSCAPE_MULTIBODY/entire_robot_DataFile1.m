% Simscape(TM) Multibody(TM) version: 25.1

% This is a model data file derived from a Simscape Multibody Import XML file using the smimport function.
% The data in this file sets the block parameter values in an imported Simscape Multibody model.
% For more information on this file, see the smimport function help page in the Simscape Multibody documentation.
% You can modify numerical values, but avoid any other changes to this file.
% Do not add code to this file. Do not edit the physical units shown in comments.

%%%VariableName:smiData


%============= RigidTransform =============%

%Initialize the RigidTransform structure array by filling in null values.
smiData.RigidTransform(4).translation = [0.0 0.0 0.0];
smiData.RigidTransform(4).angle = 0.0;
smiData.RigidTransform(4).axis = [0.0 0.0 0.0];
smiData.RigidTransform(4).ID = "";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(1).translation = [-1180.3064414824889 1016.7457521207604 1121.2119553962605];  % mm
smiData.RigidTransform(1).angle = 4.5854299439285005e-16;  % rad
smiData.RigidTransform(1).axis = [0.40924388237009707 -0.91242503513584616 -8.5610977536793652e-17];
smiData.RigidTransform(1).ID = "B[top-1:-:BaseR-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(2).translation = [-1180.3064413748873 1016.7457521888216 1121.2119553962229];  % mm
smiData.RigidTransform(2).angle = 1.5823112613210486e-16;  % rad
smiData.RigidTransform(2).axis = [0.48510539856995022 0.87445568914513305 3.3561073093149502e-17];
smiData.RigidTransform(2).ID = "F[top-1:-:BaseR-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(3).translation = [-1180.3064413748843 1016.7457521887991 979.69195539621319];  % mm
smiData.RigidTransform(3).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(3).axis = [1 0 0];
smiData.RigidTransform(3).ID = "B[BaseR-1:-:]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(4).translation = [100.00000000000006 0 99.999999999999091];  % mm
smiData.RigidTransform(4).angle = 1.6664335535985506;  % rad
smiData.RigidTransform(4).axis = [0.9086608545660243 -0.29524180884432893 0.29524180884432893];
smiData.RigidTransform(4).ID = "F[BaseR-1:-:]";


%============= Solid =============%
%Center of Mass (CoM) %Moments of Inertia (MoI) %Product of Inertia (PoI)

%Initialize the Solid structure array by filling in null values.
smiData.Solid(2).mass = 0.0;
smiData.Solid(2).CoM = [0.0 0.0 0.0];
smiData.Solid(2).MoI = [0.0 0.0 0.0];
smiData.Solid(2).PoI = [0.0 0.0 0.0];
smiData.Solid(2).color = [0.0 0.0 0.0];
smiData.Solid(2).opacity = 0.0;
smiData.Solid(2).ID = "";

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(1).mass = 0;  % kg
smiData.Solid(1).CoM = [0 0 0];  % mm
smiData.Solid(1).MoI = [0 0 0];  % kg*mm^2
smiData.Solid(1).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(1).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(1).opacity = 1;
smiData.Solid(1).ID = "top*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(2).mass = 0;  % kg
smiData.Solid(2).CoM = [0 0 0];  % mm
smiData.Solid(2).MoI = [0 0 0];  % kg*mm^2
smiData.Solid(2).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(2).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(2).opacity = 1;
smiData.Solid(2).ID = "BaseR*:*Default";


%============= Joint =============%
%X Revolute Primitive (Rx) %Y Revolute Primitive (Ry) %Z Revolute Primitive (Rz)
%X Prismatic Primitive (Px) %Y Prismatic Primitive (Py) %Z Prismatic Primitive (Pz) %Spherical Primitive (S)
%Constant Velocity Primitive (CV) %Lead Screw Primitive (LS)
%Position Target (Pos)

%Initialize the RectangularJoint structure array by filling in null values.
smiData.RectangularJoint(1).Px.Pos = 0.0;
smiData.RectangularJoint(1).Py.Pos = 0.0;
smiData.RectangularJoint(1).ID = "";

smiData.RectangularJoint(1).Px.Pos = 0;  % m
smiData.RectangularJoint(1).Py.Pos = 0;  % m
smiData.RectangularJoint(1).ID = "[BaseR-1:-:]";


%Initialize the RevoluteJoint structure array by filling in null values.
smiData.RevoluteJoint(1).Rz.Pos = 0.0;
smiData.RevoluteJoint(1).ID = "";

smiData.RevoluteJoint(1).Rz.Pos = -46.211276565303066;  % deg
smiData.RevoluteJoint(1).ID = "[top-1:-:BaseR-1]";

