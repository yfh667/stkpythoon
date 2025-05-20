%下属为测试代码，很乱
% 设置是否使用 STK Engine
USE_ENGINE = 0;

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
StartTime  =  '1 Jan 2025 06:00:00.000';
StopTime =  '2 Jan 2025 06:00:00.000';
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

folder_base = "C:\usrspace\stkfile\task3";

timestep = 1
sats1 = 'C1_2101';
sats2 = 'C4_1101';
% 定义基础路径和任务名

FILENAME = "C1_C4"; % 假设FILENAME是字符串变量
task=module.task_linshi_code()
task.cal(root,scenario, sats1, sats2,folder_base,FILENAME,timestep)
