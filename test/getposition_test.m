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

%设置动画轴
%root.ExecuteCommand('Animate * Reset');


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
P = 2
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
    params_constellation.numSatsPerPlane         = 30;   % 每个平面的卫星数
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


QF0101 = root.GetObjectFromPath('Satellite/QF_01_01');

timestep = 1
position = QF0101.DataProviders.Item('Vectors(Fixed)').Group.Item('Position').Exec(scenario.StartTime,scenario.StopTime,timestep);


position_x  = position.DataSets.GetDataSetByName('x').GetValues

position_y  = position.DataSets.GetDataSetByName('y').GetValues
position_z  = position.DataSets.GetDataSetByName('z').GetValues


 

position_time  = position.DataSets.GetDataSetByName('Time').GetValues;

 

data_table = table(position_time, position_x,position_y,position_z, 'VariableNames', {'Time', 'x','y','z'});

 
% 将表写入到一个文本文件
%writetable(data_table, pwd, 'Delimiter', '\t');
writetable(data_table, 'C:\usrspace\stkfile\sats\output.txt', 'Delimiter', '\t');
    
position = module.Get_Position()
 satellite1_name = 'QF_01_01'
 timestep = 1
 pwd = 'C:\usrspace\stkfile\sats\output.txt'
 
position.GetPositionxyz(root, satellite1_name,scenario.StartTime,scenario.StopTime,timestep,pwd)