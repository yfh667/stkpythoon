
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

StartTime  =  '24 Feb 2012 18:00:00.000';
StopTime =  '25 Feb 2012 18:00:00.000';
scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod('24 Feb 2012 16:00:00.000','25 Feb 2012 16:00:00.000');
scenario.StartTime = StartTime;
scenario.StopTime = StopTime;

root.ExecuteCommand('Animate * Reset');

% here we get the facuilt
facility = scenario.Children.New('eFacility','GroundStation1');
facility.Position.AssignGeodetic(0.75,101,0);

facility = scenario.Children.New('eFacility','GroundStation2');
facility.Position.AssignGeodetic(0.64,112,0);

facility = scenario.Children.New('eFacility','GroundStation3');
facility.Position.AssignGeodetic(10,112,0);



seedsatename = 'horizontal'
%we set the seed satellite
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 500;  % km
params.apogeeAlt = 500;
params.inclination = 0;
params.argOfPerigee = 0;
params.RAAN = 0;
params.Anomaly = 0;
%we set the first seed1 satellite
sat = sat();
sat.createSatellite(root, scenario, params);


% 定义 Walker 星座参数
params_constellation = struct();
params_constellation.seedSatelliteName =seedsatename;          % 种子卫星名称
params_constellation.numPlanes = 1;                             % 轨道平面数量
params_constellation.numSatsPerPlane = 20;                       % 每个平面的卫星数量
params_constellation.interPlaneTrueAnomalyIncrement = 50;       % 平面间真近点角增量，度
params_constellation.raanIncrement = 0;                         % RAAN 增量，度

% 调用函数来创建 Walker 星座
sat.createWalkerConstellation(root, params_constellation);
%we finish the waler ,so we need delet  the seed satellite
 root.ExecuteCommand(['Unload / */Satellite/' seedsatename]);




seedsatename2 = 'vertical'
%we set the seed satellite
params = struct();
params.satelliteName = seedsatename2;
params.perigeeAlt = 500;  % km
params.apogeeAlt = 500;
params.inclination = 90;
params.argOfPerigee = 0;
params.RAAN = 0;
params.Anomaly = 0;
% we set up the seed2 satellite
sat.createSatellite(root, scenario, params);
params_constellation.seedSatelliteName =seedsatename2;          % 种子卫星名称
sat.createWalkerConstellation(root, params_constellation);
root.ExecuteCommand(['Unload / */Satellite/' seedsatename2]);



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
reportParams.startTime = StartTime;
reportParams.stopTime =StopTime;
reportParams.timeStep = 60;
% name = 'GroundStation'
%  ExportRe.RePort(root, 'Facility',name,reportParams);
station2 = station();
station_names =station2.getStation_names(scenario);
ExportRe.MultilRePort(root,'Facility', station_names,reportParams);

