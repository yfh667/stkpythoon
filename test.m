
% 设置是否使用 STK Engine
USE_ENGINE = false;

% 初始化 STK
if USE_ENGINE
    % 初始化 STK Engine
    app = actxserver('STKX11.application');
    root = actxserver('AgStkObjects11.AgStkObjectRoot');
else
    % 初始化 STK 应用程序
    app = actxserver('STK11.application');
    root = app.Personality2; 
end





scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod('24 Feb 2012 16:00:00.000','25 Feb 2012 16:00:00.000');
scenario.StartTime = '24 Feb 2012 16:00:00.000';
scenario.StopTime = '25 Feb 2012 16:00:00.000';
root.ExecuteCommand('Animate * Reset');

facility = scenario.Children.New('eFacility','GroundStation');
facility.Position.AssignGeodetic(36.1457,-114.5946,0);



seedsatename = 'Satellite1'
%we set the satellite
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 35788.1;
params.apogeeAlt = 35788.1;
params.inclination = 0;
params.argOfPerigee = 0;
params.ascNodeValue = 245;
params.locationValue = 180;

sat = sat();
sat.createSatellite(root, scenario, params);


% 定义 Walker 星座参数
params = struct();
params.seedSatelliteName =seedsatename;          % 种子卫星名称
params.numPlanes = 1;                             % 轨道平面数量
params.numSatsPerPlane = 4;                       % 每个平面的卫星数量
params.interPlaneTrueAnomalyIncrement = 50;       % 平面间真近点角增量，度
params.raanIncrement = 0;                         % RAAN 增量，度

% 调用函数来创建 Walker 星座
sat.createWalkerConstellation(root, params);
%we finish the waler ,so we need delet  the seed satellite
 root.ExecuteCommand(['Unload / */Satellite/' seedsatename]);



%we get the report
% Satellite
% Facility
% 定义报告参数
reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % 使用有效的报告样式
reportParams.filePath = 'E:/STK_file/sats';
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 60;
% name = 'Satellite1'

% get the satellite name so we could print the waypoint
satellite_names =sat.getSatelliteNames(scenario);
ExportRe = ExportRe();
% 调用函数生成报告
%ExportRe.RePort(root, name,'Satellite',reportParams);


ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);




reportParams = struct();

reportParams.reportStyle = 'fixed';  % 使用有效的报告样式
reportParams.filePath = 'E:/STK_file/stations';
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 60;
name = 'GroundStation'
ExportRe.RePort(root, 'Facility',name,reportParams);
