

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

 
 




station = module.station();
 



% --- 1. 获取对象句柄和地面站名称（必须放在最前面） ---
position = module.Get_Position();
% 必须先获取名称列表，才能计算数量和进行循环
station_names = station.getStation_names(scenario); 
numberOfStations = length(station_names); % 修改变量名为 numberOfStations 以符合语境
% 设置时间步长
timestep = 1; 

% --- 2. 生成带 baseRaan 标记的输出文件夹 ---
baseOutDir = 'C:\usrspace\stkfile\position';

outDir = fullfile(baseOutDir, 'paper1stationfile');

% 若文件夹不存在则创建
if ~exist(outDir, 'dir')
    mkdir(outDir);
end


% ===== 按 "_S<number>" 的 number 排序：S1, S2, S3... =====
tok = regexp(station_names, '_S(\d+)$', 'tokens', 'once');

sId = nan(size(station_names));
for k = 1:numel(station_names)
    if ~isempty(tok{k})
        sId(k) = str2double(tok{k}{1});
    else
        sId(k) = inf;   % 没有 _S数字 的放到最后
    end
end

[~, idx] = sort(sId, 'ascend');
station_names = station_names(idx);



% --- 3. 循环生成每个地面站的文件 ---
for i = 1:numberOfStations
    % 获取当前地面站名称 (例如 'BEIJIN1')
    currentStationName = station_names{i}; 

    % 生成文件名，例如 1.txt, 2.txt
    filename = sprintf('%d.txt', i);
    
    % 【关键修改】不要用 pwd 做变量名，pwd 是 MATLAB 获取当前路径的内置命令
    % 改用 outFilePath
    outFilePath = fullfile(outDir, filename);

    % 调用你的自定义函数导出位置
    % 注意：这里假设你的 GetPositionxyz 内部能够处理 Facility 类型的对象
    % 如果你的函数只能识别 "Satellite/" 路径，这里可能需要手动拼接 "Facility/" 前缀
    position.GetPositionxyz_Station_Fixed(root, currentStationName, scenario.StartTime, scenario.StopTime, timestep, outFilePath);
    
    % 打印进度（可选）
    fprintf('正在导出第 %d 个地面站: %s\n', i, currentStationName);
end

 
 
 

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
 