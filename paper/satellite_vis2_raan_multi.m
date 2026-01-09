

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
StartTime  =  '6 Jan 2025 00:00:00.000';
dayIdx=0
baseDT = datetime(StartTime, 'InputFormat','d MMM yyyy HH:mm:ss.SSS', 'Locale','en_US');
dayStartDT = baseDT + days(dayIdx);
dayStopDT  = baseDT + days(dayIdx+1);
StartTime = datestr(dayStartDT, 'dd mmm yyyy HH:MM:SS.FFF');
StopTime  = datestr(dayStopDT,  'dd mmm yyyy HH:MM:SS.FFF');

    scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
    % 1) 设置当天 scenario 时间窗口
    scenario.SetTimePeriod(StartTime, StopTime);
    scenario.StartTime = StartTime;
    scenario.StopTime  = StopTime;


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


folder = 'C:\usrspace\stkfile\position\stationfile';

% 1. 获取所有地面站文件
files = dir(fullfile(folder, '*.txt'));
numFiles = length(files);

% ================= 核心步骤：按数字 ID 对文件列表排序 =================
% 提取每个文件的数字 ID
file_IDs = zeros(numFiles, 1);
for k = 1:numFiles
    [~, nameNoExt, ~] = fileparts(files(k).name);
    % 假设文件名就是数字 (如 "1.txt" -> 1)
    file_IDs(k) = str2double(nameNoExt); 
end

% 获取排序后的索引 (从小到大)
[sorted_IDs, sortIndex] = sort(file_IDs);

% 使用排序索引重新排列 files 结构体数组
% 现在的 sortedFiles 就是按 1.txt, 2.txt, 3.txt... 顺序排列的了
sortedFiles = files(sortIndex);

% =================================================================

% 初始化结构体 (可选，但推荐)
% 注意：如果你的最大ID是100，这里会自动扩展到100
stations = struct('id', {}, 'position', {}, 'angle', {});

disp('开始按顺序读取...');

% 2. 遍历排序后的文件列表
for k = 1:numFiles
    % 获取文件信息
    thisFile = sortedFiles(k);
    fullFileName = fullfile(folder, thisFile.name);
    
    % 获取 ID (前面已经算过一次，但为了代码清晰再取一次，或者直接用 sorted_IDs(k))
    currentID = sorted_IDs(k); 
    
    % 读取数据
    xyz_data = load(fullFileName);
    
    % 容错处理：确保是一行向量
    if size(xyz_data, 1) > 1
        pos = xyz_data(1, 1:3);
    else
        pos = xyz_data(1, 1:3); % 假设数据本身就是行向量
    end
    
    % ================= 关键步骤 =================
    % 这里的下标使用 currentID，而不是 k
    % 这样 station(1) 永远存放 1.txt 的数据，哪怕 1.txt 是第10个被读取的
    % ===========================================
    stations(currentID).id = currentID;
    stations(currentID).position = pos;
    stations(currentID).angle = deg2rad(20); 
    
    fprintf('已存入 stations(%d): 文件 %s, 坐标 [%.1f, ...]\n', ...
        currentID, thisFile.name, pos(1));
end

disp('读取完成。');

 

P =18

N = 36

 RAAN = 10.2
 
  height =561

 Anomaly_base = 4.5
 

 
timestep = 1

 
% --- 生成带 baseRaan 标记的输出文件夹 ---
baseOutDir = 'C:\usrspace\stkfile\position\differentraan';
if ~exist(baseOutDir, 'dir')
    mkdir(baseOutDir);
end
 
export = module.Export_Position_STK();
read_file = module.Read_All_E_Files_XYZ();

% 用 datetime 做“+1天”，避免手写日期字符串出错
% baseDT = datetime(StartTime, 'InputFormat','d MMM yyyy HH:mm:ss.SSS', 'Locale','en_US');

baseRaan_LIST = [15, 55, 95, 135, 175, 215, 255, 295, 325];

for baseRaan = baseRaan_LIST
     

 
for i = 1:P  
    
    
    %=============== 
    % 1. 设置“种子卫星”参数
    %=============== 
    % 为了区分不同循环生成的卫星，给种子卫星起一个带下标的名字
    seedSatelliteName = sprintf('QF_%d', i);
	
    % 轨道与初始状态参数
    params = struct();
    params.satelliteName = seedSatelliteName;
    params.perigeeAlt    = height;    % km
    params.apogeeAlt     = height;    % km
    params.inclination   = 89;      % 度
    params.argOfPerigee  = 0;       % 近地点幅角
    params.RAAN          =  baseRaan+(i-1)*RAAN;       % 升交点赤经(可按需在循环中改)
    params.Anomaly       = (i-1)*Anomaly_base;       % 真近点角(或平近点角)

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

%  名字重新取一次
satellite_names = sat.getSatelliteNames(scenario); % <-- 重取一次
numberofsatellite = length(satellite_names);


    % 2) 当天输出目录：day_YYYYMMDD
    dayTag = sprintf('baseRaan_%d', baseRaan);
    
    outDir = fullfile(baseOutDir, [dayTag]);
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    output_folder = fullfile(outDir, 'satellite_pos');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % 3) 导出当天卫星位置（你原本的调用不变）
    export.Export_Pos_Line(root, scenario, output_folder);

     root.ExecuteCommand('UnloadMulti / */Satellite/*');
    % 4) 读取当天 .e 文件（你原本的调用不变）
    XYZ = read_file.Read_All_E_Files_XYZ_Serial(output_folder);

    output_file_dir = fullfile(outDir, ['station_visible_satellites_' dayTag '.xml']);
 
    Station_View_Result = module.Calculate_Constellation_Visibility_para2(stations, XYZ, output_file_dir);

    clear XYZ Station_View_Result;


 end


 
% ====== 按天仿真结束 ======
  



%  Station_View_Result = module.Calculate_Constellation_Visibility2(root, stations, XYZ,filepath)
 
% 
% Station_View_Result = module.Calculate_Constellation_Visibility_para2(  stations, XYZ,filepath)
% 
%  


 




%  
%  root.ExecuteCommand('UnloadMulti / */Satellite/*');
%  
%    





 
 



% 初始化 STK
if USE_ENGINE


    %------% 关闭engine
    % 1. 释放根对象（AgStkObjectRoot）
    delete(root);
    clear root;
    % 3. 释放 STKXApplication 对象
    delete(app);
    clear STKXApplication;

end
 


 

