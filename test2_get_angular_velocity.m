
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
%设置senario的时间
StartTime  =  '24 Feb 2012 18:00:00.000';
StopTime =  '25 Feb 2012 18:00:00.000';
scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod(StartTime,StopTime);
scenario.StartTime = StartTime;
scenario.StopTime = StopTime;

if USE_ENGINE
    % 在 USE_ENGINE 为 true 的情况下执行的逻辑
    % 添加你的逻辑代码
else
    % 当 USE_ENGINE 为 false 时，执行复位动画命令
    try
        root.ExecuteCommand('Animate * Reset');
        disp('动画已复位成功');
    catch ME
        disp('动画复位失败:');
        disp(ME.message);
    end
end



%设置种子卫星
seedsatename = 'horizontal'
%we set the seed satellite
%这里采用结构化去赋值，方便管理
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 1000;  % km
params.apogeeAlt = 1000;
params.inclination =53;
params.argOfPerigee = 0;
params.RAAN = 0;
params.Anomaly = 0;
%we set the first seed1 satellite
sat = sat();
sat.createSatellite(root, scenario, params);

%设置种子卫星
seedsatename = 'horizontal2'
%we set the seed satellite
%这里采用结构化去赋值，方便管理
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 1000;  % km
params.apogeeAlt = 1000;
params.inclination =53;
params.argOfPerigee = 0;
params.RAAN = 10;
params.Anomaly =20;
%we set the first seed1 satellite
sat = sat();
sat.createSatellite(root, scenario, params);


reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % 使用有效的报告样式
reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
 
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 1;

% get the satellite name so we could print the waypoint
satellite_names =sat.getSatelliteNames(scenario);
ExportRe = ExportRe();
% 调用函数生成报告
%ExportRe.RePort(root, name,'Satellite',reportParams);


%ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);
%我们采用并行，注意，目前只在matlb端并行了，实际上是stk自己也可以并行，以后再折腾
ExportRe.MultilRePort_Para(root,'Satellite', satellite_names,reportParams);

