STKXApplication = actxserver('STKX11.application');
root = actxserver('AgStkObjects11.AgStkObjectRoot');

scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod('24 Feb 2012 16:00:00.000','25 Feb 2012 16:00:00.000');
scenario.StartTime = '24 Feb 2012 16:00:00.000';
scenario.StopTime = '25 Feb 2012 16:00:00.000';
root.ExecuteCommand('Animate * Reset');

facility = scenario.Children.New('eFacility','GroundStation');
facility.Position.AssignGeodetic(36.1457,-114.5946,0);

% 定义卫星参数
params = struct();
params.satelliteName = 'Satellite1';
params.perigeeAlt = 35788.1;
params.apogeeAlt = 35788.1;
params.inclination = 0;
params.argOfPerigee = 0;
params.ascNodeValue = 245;
params.locationValue = 180;
sat().createSatellite(root, scenario, params);

% 
% 
% satellite = scenario.Children.New('eSatellite','Satellite1');
% keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');   
% keplerian.SizeShapeType = 'eSizeShapeAltitude';
% 
% 
% keplerian.LocationType = 'eLocationTrueAnomaly';
% keplerian.Orientation.AscNodeType = 'eAscNodeLAN';
% 
% 
% keplerian.SizeShape.PerigeeAltitude = 35788.1;
% keplerian.SizeShape.ApogeeAltitude = 35788.1;
% keplerian.Orientation.Inclination = 0;
% keplerian.Orientation.ArgOfPerigee = 0;
% keplerian.Orientation.AscNode.Value = 245;
% keplerian.Location.Value = 180;
% satellite.Propagator.InitialState.Representation.Assign(keplerian);
% satellite.Propagator.Propagate;



% 定义变量
satellite_name = 'Satellite1';
report_style = 'fixed';  % 使用有效的报告样式
file_path = 'E:/STK_file/stations/test.txt';  % 使用正斜杠
start_time = '24 Feb 2012 16:00:00.000';
stop_time = '25 Feb 2012 16:00:00.000';
time_step = 60;

% 确保目录存在
folder_path = 'E:/STK_file/stations';
if ~exist(folder_path, 'dir')
    mkdir(folder_path);
end

% 构建命令字符串
command = ['ReportCreate */Satellite/' satellite_name ...
    ' Type Save' ...
    ' Style "' report_style '"' ...
    ' File "' file_path '"' ...
    ' TimePeriod "' start_time '" "' stop_time '"' ...
    ' TimeStep ' num2str(time_step)];

% 打印命令以检查
disp('执行的命令：');
disp(command);

% 执行命令并捕获错误
try
    root.ExecuteCommand(command);
    disp('报告已成功生成。');
catch ME
    disp('执行命令时发生错误：');
    disp(ME.message);
end


%------% 关闭engine
% 1. 释放根对象（AgStkObjectRoot）
delete(root);
clear root;
% 3. 释放 STKXApplication 对象
delete(STKXApplication);
clear STKXApplication;

