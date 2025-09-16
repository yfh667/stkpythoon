
 

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

 


% 假设您已经有 root 和 scenario 对象
% root = ...; 
% scenario = ...;

% 外层循环，假设想重复两次（例如创建两组不同的星座）

% P =18
% N = 36
P =10
N = 10
for i = 1:P
    
    %=============== 
    % 1. 设置“种子卫星”参数
    %=============== 
    % 为了区分不同循环生成的卫星，给种子卫星起一个带下标的名字
    seedSatelliteName = sprintf('QF_%d', i);
	
    % 轨道与初始状态参数
    params = struct();
    params.satelliteName = seedSatelliteName;
    params.perigeeAlt    = 1066;    % km
    params.apogeeAlt     = 1066;    % km
    params.inclination   = 89;      % 度
    params.argOfPerigee  = 0;       % 近地点幅角
    params.RAAN          = i*10.2;       % 升交点赤经(可按需在循环中改)
    params.Anomaly       = i*4.5;       % 真近点角(或平近点角)

    %=============== 
    % 2. 创建种子卫星
    %=============== 
    satObj = module.sat();  % 您自定义的 sat 类
    satObj.createSatellite(root, scenario, params);

    %=============== 
    % 3. 定义并创建 Walker 星座
    %=============== 
    % 这里设置1个轨道面、每面30颗卫星，不分面间相位增量
    params_constellation = struct();
    params_constellation.seedSatelliteName       = seedSatelliteName; 
    params_constellation.numPlanes               = 1;    % 轨道平面数量
    params_constellation.numSatsPerPlane         = N;   % 每个平面的卫星数
    params_constellation.interPlanePhaseIncrement= 0;    % 平面间相位增量(此处为0)

    satObj.createWalkerConstellation_Delta(root, params_constellation);

    %=============== 
    % 4. 卸载种子卫星
    %=============== 
    % 由于 Walker 星座已创建完，可以删除原先的种子卫星
    unloadCmd = sprintf('Unload / */Satellite/%s', seedSatelliteName);
    root.ExecuteCommand(unloadCmd);

end

 

 sat = module.sat();

satellite_names =sat.getSatelliteNames(scenario);
sat.batchRenameSatellitesInSTK(root,satellite_names)


%we set the station
facilityName = 'Facility1'
 
Gnd = module.station();

Gnd.SetStation(root, scenario,facilityName )

 
% we se the sensror for the station
Los = module.SensorModule();
Los.CreateGndSensor(root,facilityName,70);


 
% 设置文件路径

filepath = 'C:\usrspace\stkfile\los';

 
 
 
% % 假设 P 和 N 已定义


for i = 1:P
    for j = 1:N
 
         if i < 10
            startx = ['0', num2str(i)];
        else
            startx = num2str(i);
        end
        
        % 处理 j 的格式（两位数字）
        if j < 10
            starty = ['0', num2str(j)];
        else
            starty = num2str(j);
        end
        
        % 生成卫星1名称
        sat1 = ['QF_', startx, '_',starty];
% 为sat1建立angle
    Los.CreateSatSensor(root,sat1,45)
    Los.LosCalculate(root, sat1, facilityName,scenario.StartTime,scenario.StopTime, filepath)
    end
end



 
