
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
StartTime  =  '6 Jan 2025 00:00:00.000';
StopTime =  '7 Jan 2025 00:00:00.000';
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

 P =18
 N = 36
%P =3
%N = 36
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
sat.batchRenameSatellitesInSTK2(root,satellite_names)




 

%first we get all the satellite name
 satellite_names =sat.getSatelliteNames(scenario);
 
 %then we need pair the satellite, for example  QF_01_01 pair with QF_02_01
 %all the name is start with QF_x_y, x means the track,and y mean the id 
 

% 设置文件路径

filepath = 'C:\usrspace\stkfile\sats\';


 

 
% % 假设 P 和 N 已定义
for i = 1:P-1
    for j = 1:N
        % 处理 i 的格式（两位数字）
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
        
        % 处理 i+1 的格式（两位数字）
        if i+1 < 10
            startx2 = ['0', num2str(i+1)];
        else
            startx2 = num2str(i+1);
        end
        
        % 生成卫星2名称
        if j < 10
            starty2 = ['0', num2str(j)];
        else
            starty2 = num2str(j);
        end
        sat2 = ['QF_', startx2, '_',starty2];
        
        % 生成文件名
        filename = sprintf('%02d_%02d.txt', i, j);
        path = fullfile(filepath, filename);
        
        % 调用 Azimuth_Angle 函数
        % 输出进度
        disp(['处理完成: ', filename]);

        Azmuth  = module.Get_Azimuth();

        Azmuth.Azimuth_Angle(root, sat1, sat2,scenario.StartTime,scenario.StopTime,1,path)
 
    end
end







 


% reportParams = struct();
% %reportParams.satelliteName = 'Satellite1';
% reportParams.reportStyle = 'fixed';  % 使用有效的报告样式
% reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
%  
% reportParams.startTime = '24 Feb 2012 16:00:00.000';
% reportParams.stopTime = '25 Feb 2012 16:00:00.000';
% reportParams.timeStep = 1;
% 
% % get the satellite name so we could print the waypoint
% 
% 
% ExportRe = ExportRe();
% % 调用函数生成报告
% %ExportRe.RePort(root, name,'Satellite',reportParams);
% 
% 
% %ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);
% %我们采用并行，注意，目前只在matlb端并行了，实际上是stk自己也可以并行，以后再折腾
% ExportRe.MultilRePort_Para(root,'Satellite', satellite_names,reportParams);


if USE_ENGINE

try
    delete(app); % 释放 COM 对象
    disp('STK 应用已关闭。');
catch ME
    disp('无法关闭 STK 应用。');
end

end

 