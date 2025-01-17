
 

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

Gnd = module.station();
Gnd.SetStation(root, scenario, 'Facility1')


% 3. 为卫星添加传感器
name  =  'QF_02_01'
satellite = root.GetObjectFromPath(['Satellite/' name]);
sensor = satellite.Children.New('eSensor',name); % 创建传感器
%设置角度为
sensor.CommonTasks.SetPatternSimpleConic(45, 0.1)
 
% 3. 为地面站添加传感器
facilityName = 'Facility1';
facility = root.GetObjectFromPath(['Facility/' facilityName]);
sensor = facility.Children.New('eSensor',facilityName); % 创建传感器
%设置角度为
sensor.CommonTasks.SetPatternSimpleConic(70, 0.1)





% 1. 获取对象
satelliteName = 'QF_02_01';
facilityName = 'Facility1';
satellite = root.GetObjectFromPath(['Satellite/' satelliteName]);
facility = root.GetObjectFromPath(['Facility/' facilityName]);
% 2. 获取传感器对象
satelliteSensor = satellite.Children.Item(satelliteName); % 获取卫星的传感器
facilitySensor = facility.Children.Item(facilityName); % 获取地面站的传感器
% 3. 创建访问分析
access = satelliteSensor.GetAccessToObject(facilitySensor);

% 4. 计算访问
access.ComputeAccess();


% 5. 获取访问结果
results = access.DataProviders.Item('Access Data');

% 6. 提取访问时间段
startTimes =scenario.StartTime;
stopTimes =scenario.StopTime;


resInfo = results.Exec(startTimes, stopTimes);

Access_Start_Time  = resInfo.DataSets.GetDataSetByName('Start Time').GetValues;

Access_Stop_Time  = resInfo.DataSets.GetDataSetByName('Stop Time').GetValues;
%Access_Duration_Time  = resInfo.DataSets.GetDataSetByName('Duration').GetValues;

% 初始化普通数组存储合并结果
access_time = strings(length(Access_Start_Time), 2);

% 循环合并开始和结束时间
for i = 1:length(Access_Start_Time)
    access_time(i, 1) = Access_Start_Time{i}; % 开始时间
    access_time(i, 2) = Access_Stop_Time{i}; % 结束时间
end
% 将字符串数组转换为表格
access_time_table = array2table(access_time, ...
    'VariableNames', {'Start_Time', 'Stop_Time'}); % 添加列标题

% 定义保存路径
filepath = 'C:\usrspace\stkfile\los\access_time.txt';

% 保存表格到文件
writetable(access_time_table, filepath, 'Delimiter', '\t');

disp(['数据已保存到文件：', filepath]);
 
 



 
