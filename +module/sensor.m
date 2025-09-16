

i=1
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
    satObj = sat();  % 您自定义的 sat 类
    satObj.createSatellite(root, scenario, params);
    
     
 

% 3. 为卫星添加传感器
name  =  'QF_02_01'
satellite = root.GetObjectFromPath(['Satellite/' name]);
sensor = satellite.Children.New('eSensor',name); % 创建传感器
%设置角度为
sensor.CommonTasks.SetPatternSimpleConic(45, 0.1)
 

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


Los = SensorModule();
 Los.LosCalculate(root, satelliteName, facilityName,scenario.StartTime,scenario.StopTime, filepath)

 


 
