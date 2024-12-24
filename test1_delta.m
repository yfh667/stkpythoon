
% 设置是否使用 STK Engine
USE_ENGINE = true;

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


% 定义 Walker 星座参数
params_constellation = struct();
params_constellation.seedSatelliteName =seedsatename;          % 种子卫星名称
params_constellation.numPlanes = 10;                             % 轨道平面数量
params_constellation.numSatsPerPlane =18;                       % 每个平面的卫星数量
params_constellation.interPlanePhaseIncrement = 0;

 
 


% 调用函数来创建 Walker 星座
sat.createWalkerConstellation_Delta(root, params_constellation);
%we finish the waler ,so we need delet  the seed satellite
 root.ExecuteCommand(['Unload / */Satellite/' seedsatename]);



 



%we get the report
% Satellite
% Facility
% 定义报告参数
reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % 使用有效的报告样式
reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
 
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 1;
% name = 'Satellite1'

% get the satellite name so we could print the waypoint
satellite_names =sat.getSatelliteNames(scenario);
ExportRe = ExportRe();
% 调用函数生成报告
%ExportRe.RePort(root, name,'Satellite',reportParams);


ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);

 
% 用python脚本去后处理，matlab太慢了
%ExportRe.MultiModifyReport('Satellite', 'E:/STK_file/sats')

% 初始化 STK
if USE_ENGINE

    %------% 关闭engine
    % 1. 释放根对象（AgStkObjectRoot）
    delete(root);
    clear root;
    % 3. 释放 STKXApplication 对象
    delete(STKXApplication);
    clear STKXApplication;

end