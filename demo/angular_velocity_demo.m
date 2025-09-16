%下属为测试代码，很乱
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

% 假设您已经有 root 和 scenario 对象
% root = ...; 
% scenario = ...;

% 外层循环，假设想重复两次（例如创建两组不同的星座）

N = 36
P = 18
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


 
    


QF0101 = root.GetObjectFromPath('Satellite/QF_01_01');
QF0201 = root.GetObjectFromPath('Satellite/QF_02_01');
centerQF0101 = QF0101.vgt.Points.Item('Center');
centerQF0201 = QF0201.vgt.Points.Item('Center');


%first 


QF0101Body_xy =  QF0101.vgt.Plane.Item('Body.XY');
QF0101_vector_bodyx =  QF0101.vgt.Vector.Item('Body.X');
AB_vector = QF0101.vgt.Vectors.Factory.CreateDisplacementVector('AB_vector',centerQF0101,centerQF0201);

AB_vector_projection = QF0101.vgt.Vectors.Factory.Create('AB_vector_projection','','eCrdnVectorTypeProjection');
 
AB_vector_projection.Source.SetVector(AB_vector);
AB_vector_projection.ReferencePlane.SetPlane(QF0101Body_xy) 

Azimuth = QF0101.vgt.Angles.Factory.Create('Azimuth','','eCrdnAngleTypeBetweenVectors');
Azimuth.FromVector.SetVector(QF0101_vector_bodyx);
Azimuth.ToVector.SetVector(AB_vector_projection);

angleAZ = QF0101.DataProviders.Item('Angles').Group.Item('Azimuth').Exec(scenario.StartTime,scenario.StopTime,60);

angleAZData_AngleRate  = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues
angleAZData_Time  = angleAZ.DataSets.GetDataSetByName('Time').GetValues
 
 
% 展开角速率数据（如数据在单元格中）
AngleRate = cell2mat(angleAZData_AngleRate);

% 创建表（table），保持时间为字符串格式
data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'AngleRate'});

%   
% 
% % 将表写入到一个文本文件
% writetable(data_table, 'C:\usrspace\stkfile\sats\output.txt', 'Delimiter', '\t');
% 
% % 显示提示信息
% disp('数据已成功导出到 output.txt 文件中。');


%here we need delete the vector
% 假设 QF0101 是目标卫星对象
% QF0101 = root.GetObjectFromPath('Satellite/QF_01_01');

% 检查是否存在目标矢量
% vectorName = 'AB_vector';
% if QF0101.vgt.Vectors.Contains(vectorName)
%     % 删除矢量
%     QF0101.vgt.Vectors.Remove(vectorName);
%     disp(['矢量 "', vectorName, '" 已成功删除。']);
% else
%     disp(['矢量 "', vectorName, '" 不存在，无法删除。']);
% end

 
  
 

