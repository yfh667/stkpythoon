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
QF0201 = root.GetObjectFromPath('Satellite/QF_02_01');
centerQF0101 = QF0101.vgt.Points.Item('Center');
centerQF0201 = QF0201.vgt.Points.Item('Center');

timestep = 1
%first we need create the AB_vector

AB_vector = QF0101.vgt.Vectors.Factory.CreateDisplacementVector('AB_vector',centerQF0101,centerQF0201);

% we need get the ab_vector data in the A body referrence system
AB_vector_data = QF0101.DataProviders.Item('Vectors(Body)').Group.Item('AB_vector').Exec(scenario.StartTime,scenario.StopTime,timestep);
AB_vector_data_Time  = AB_vector_data.DataSets.GetDataSetByName('Time').GetValues
AB_vector_data_x =  AB_vector_data.DataSets.GetDataSetByName('x').GetValues
AB_vector_data_y =  AB_vector_data.DataSets.GetDataSetByName('y').GetValues
AB_vector_data_z =  AB_vector_data.DataSets.GetDataSetByName('z').GetValues
x = cell2mat(AB_vector_data_x); % 将 {[627.3107]} 转换为 [627.3107; ...]
y = cell2mat(AB_vector_data_y);
z = cell2mat(AB_vector_data_z);
AB_vector_data_vector = [x, y, z]; % 得到 N×3 的矩阵，每行代表一个向量 [x, y, z]


QF0101Axes=  QF0101.vgt.Axes.Item('Body'); 
% sencond we get  the deriative of the ab_vector
 
 
  AB_vector_D = QF0101.vgt.Vectors.Factory.Create('AB_vector_D','','eCrdnVectorTypeDerivative');

  AB_vector_D.Vector.SetVector(AB_vector);
  AB_vector_D.ReferenceAxes.SetAxes(QF0101Axes);
  
  AB_vector_D_data = QF0101.DataProviders.Item('Vectors(Body)').Group.Item('AB_vector_D').Exec(scenario.StartTime,scenario.StopTime,timestep);
AB_vector_D_data_Time  = AB_vector_D_data.DataSets.GetDataSetByName('Time').GetValues;
AB_vector_D_data_x =  AB_vector_D_data.DataSets.GetDataSetByName('x').GetValues;
AB_vector_D_data_y =  AB_vector_D_data.DataSets.GetDataSetByName('y').GetValues;
AB_vector_D_data_z =  AB_vector_D_data.DataSets.GetDataSetByName('z').GetValues;
  
 x = cell2mat(AB_vector_D_data_x); % 将 {[627.3107]} 转换为 [627.3107; ...]
y = cell2mat(AB_vector_D_data_y);
z = cell2mat(AB_vector_D_data_z);
AB_vector_D_data_vector = [x, y, z]; % 得到 N×3 的矩阵，每行代表一个向量 [x, y, z]

 

% 计算叉乘
cross_product = cross(AB_vector_data_vector, AB_vector_D_data_vector, 2);

% 计算模长平方
r_norm_sq = sum(AB_vector_data_vector.^2, 2);

% 处理极小值
epsilon = 1e-10;
r_norm_sq = max(r_norm_sq, epsilon);

% 计算角速度
omega = cross_product ./ r_norm_sq;
% 定义弧度到角度的转换因子
rad2deg = 180 / pi;

% 将整个矩阵转换为度/秒
omega_deg_per_sec = omega * rad2deg;

 


 
%so we get the omage,and we need get the azmiuth and the elevation


%azmiuth:exactly the projection in the XOY.it is the  omega(z)



%elevation:exactly  it is the  omega(y)


% 提取数据
omega_z = omega_deg_per_sec(:, 1);
N = size(omega_deg_per_sec, 1);
t = 0:N-1;

% 设置自适应图形窗口
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]);

% 绘制曲线
plot(t, omega_z, 'LineWidth', 2);
xlabel('时间 (秒)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('角速度 z 分量 (°/s)', 'FontSize', 14, 'FontWeight', 'bold');
title('角速度 z 分量随时间变化', 'FontSize', 16, 'FontWeight', 'bold');
grid on;

% 坐标轴美化
ax = gca;
ax.FontSize = 12;
ax.LineWidth = 1.5;
xlim([min(t), max(t)]);
ylim([min(omega_z)*1.1, max(omega_z)*1.1]);

 
