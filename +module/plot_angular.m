 


function F = plot_angular
    F.GetAzimuth = @GetAzimuth;
  F.GetPitch = @GetPitch;
    
end


% 获取方位角（Azimuth）速度
function GetAzimuth(root, sats1, sats2, starttime, endtime, timestep)
   
angular = module.stk_angular_velocity()
datatable = angular.GetAzimuth(root, sats1, sats2,starttime, endtime, timestep);
  varNames = datatable.Properties.VariableNames; 
   timeStr = datatable.(varNames{1});
    omega = datatable.(varNames{2});
time = datetime(datatable{:, varNames{1}}, ...
                'InputFormat', 'd MMM yyyy HH:mm:ss.SSSSSSSSS', ...
                'Locale', 'en_US');
    % 计算角加速度
    dt = seconds(diff(time));
alpha = diff(omega) ./ seconds(diff(time));     % 角加速度
time_alpha = time(2:end);                        % 对应的时间（后一点）
    % 绘图
    figure;

    subplot(2,1,1);
    plot(time, omega, '-o');
    ylabel('角速度 (deg/s)');
 
    grid on;

    subplot(2,1,2);
    plot(time_alpha, alpha, '-o');
    ylabel('角加速度 (deg/s?)');
    xlabel('时间');
    title('角加速度（差分推导）');
    grid on;
end

function GetPitch(root, sats1, sats2, starttime, endtime, timestep)
   
angular = module.stk_angular_velocity()
datatable = angular.GetPitch(root, sats1, sats2,starttime, endtime, timestep);
  varNames = datatable.Properties.VariableNames; 
   timeStr = datatable.(varNames{1});
    omega = datatable.(varNames{2});
time = datetime(datatable{:, varNames{1}}, ...
                'InputFormat', 'd MMM yyyy HH:mm:ss.SSSSSSSSS', ...
                'Locale', 'en_US');
    % 计算角加速度
    dt = seconds(diff(time));
alpha = diff(omega) ./ seconds(diff(time));     % 角加速度
time_alpha = time(2:end);                        % 对应的时间（后一点）
    % 绘图
    figure;

    subplot(2,1,1);
    plot(time, omega, '-o');
    ylabel('角速度 (deg/s)');
 
    grid on;

    subplot(2,1,2);
    plot(time_alpha, alpha, '-o');
    ylabel('角加速度 (deg/s?)');
    xlabel('时间');
    title('角加速度（差分推导）');
    grid on;
end

