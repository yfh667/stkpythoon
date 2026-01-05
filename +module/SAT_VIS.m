function sats_visibility = SAT_VIS(root, satellite_name, starttime, endtime, timestep, stations)
    % 1. 实例化位置读取对象
    % 假设 module 是一个包，Get_Position 是类
    pos_obj = module.Get_Position();

    % 2. 读取卫星轨迹
    % 注意：修复了原代码参数中多余的逗号
    [x_m, y_m, z_m] = pos_obj.GetPositionxyz_read(root, satellite_name, starttime, endtime, timestep);

    % 3. 获取循环边界
    % [重要修正] 不要用 'length' 作为变量名，会覆盖 MATLAB 内置函数
    num_steps = length(x_m);       
    num_stations = length(stations);

    % 4. 初始化输出结果
    % 创建一个矩阵来存结果：行=时间步，列=站点ID
    % 这样 sats_visibility(t, s) 就是第 t 时刻第 s 个站的可见性
    sats_visibility = zeros(num_steps, num_stations);

    % 5. 双重循环计算
    % [语法修正] MATLAB 循环是 for i = 1:N
    for i = 1:num_steps
        
        % 构造当前时刻的卫星
        satellite.position = [x_m(i), y_m(i), z_m(i)];
        satellite.angle = deg2rad(45); % 设定半波束角

        % 遍历所有地面站
        for j = 1:num_stations
            % [语法修正] MATLAB 使用圆括号 () 访问数组/结构体数组
            current_station = stations(j);

            % 计算可见性
            vis_ratio = module.Ground_Sat(current_station, satellite);

            % 保存结果到矩阵中
            sats_visibility(i, j) = vis_ratio;

            % 打印日志 (可选)
            if vis_ratio > 0
                % 假设 station 结构体里有 .id 字段
                fprintf('时间步 %d, 站点 %s: 可见! Ratio: %.4f\n', ...
                        i, num2str(current_station.id), vis_ratio);
            end
        end
    end
    
    % 函数结束时，sats_visibility 会被自动返回
end