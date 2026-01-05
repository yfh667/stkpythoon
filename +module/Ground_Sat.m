function ratio = Ground_Sat(station, satellite)
% GROUND_SAT 计算地面站与卫星的可见性及可见比率
% 
% 输入参数 (结构体):
%   station.position  : [x, y, z] 地面站坐标 (米)
%   station.angle     : 地面站最小仰角 (弧度)
%
%   satellite.position: [x, y, z] 卫星坐标 (米)
%   satellite.angle   : 卫星半波束角/可视角 (弧度)
%
% 输出:
%   ratio : 如果不可见返回 0; 如果可见返回 (距离 / 卫星地心距)

    % 1. 计算直线距离
    dist = GetDistance(station, satellite);
    
    % 2. 获取卫星当前的地心距离 (get_length)
    sat_len = norm(satellite.position);

    % 3. 地面站视角的截止距离判断 (Ground see the sat)
    % 注意: station.angle 对应 Python 中的 station.angle
    cutoff_gnd = get_cutoff_distance(satellite, station.angle);
    
    if (dist > cutoff_gnd)
        ratio = 0;
        return;
    end

    % 4. 卫星视角的截止距离判断 (Sat see the ground)
    % 注意: satellite.angle 对应 Python 中的 satellite.angle
    cutoff_sat = get_sat_angle_distance(satellite, satellite.angle);
    
    if (dist > cutoff_sat)
        ratio = 0;
        return;
    end

    % 5. 可见，计算比率
    ratio = dist / sat_len;

end

%% --- 以下是子函数实现 (对应 Python 中的其他 def) ---

function d = GetDistance(obj1, obj2)
    % 计算两个位置向量之间的欧几里得距离
    % 假设 obj1.position 和 obj2.position 都是行向量或列向量
    delta = obj1.position - obj2.position;
    d = norm(delta); % norm 等同于 sqrt(dx^2 + dy^2 + dz^2)
end

function d = get_cutoff_distance(sat, elevation_angle)
    % 对应 Python: get_cutoff_distance
    % 计算地面站仰角限制下的最大视距
    
    LEO_PROP_EARTH_RAD = 6.37101e6; % 地球半径 (米)
    
    hs = norm(sat.position); % get_length()
    
    a = 1;
    b = 2 * LEO_PROP_EARTH_RAD * sin(elevation_angle);
    c = LEO_PROP_EARTH_RAD^2 - hs^2;
    
    delta = b^2 - 4 * a * c;
    
    % 防止数值误差导致复数 (虽然理论上 c 是负数，delta 通常为正)
    if delta < 0
        d = 0;
    else
        d = (-b + sqrt(delta)) / (2 * a);
    end
end

function d = get_sat_angle_distance(sat, sat_elevation_angle)
    % 对应 Python: get_sat_angle_distance
    % 计算卫星圆锥角限制下的最大覆盖距离
    
    LEO_PROP_EARTH_RAD = 6.37101e6; % 地球半径 (米)
    
    hs_radius = norm(sat.position); % 卫星地心距
    satangle = sat_elevation_angle;
    
    % 计算最大可视角度 (asin 参数必须在 -1 到 1 之间)
    val = LEO_PROP_EARTH_RAD / hs_radius;
    if val > 1
        val = 1; 
    end
    theta_max = asin(val);

    % 如果卫星波束角大于地球视界角，则取地球切线距离
    if theta_max <= satangle
        d = sqrt(hs_radius^2 - LEO_PROP_EARTH_RAD^2);
        return;
    end

    % 对应 Python逻辑: hs = hs - LEO_PROP_EARTH_RAD
    % 这里 hs 变为高度 (Altitude)
    hs_alt = hs_radius - LEO_PROP_EARTH_RAD;
    
    b = -2.0 * cos(satangle) * (hs_alt + LEO_PROP_EARTH_RAD);
    c = hs_alt^2 + 2 * hs_alt * LEO_PROP_EARTH_RAD;
    
    disc = b^2 - 4 * c;
    
    if disc < 0
        d = 0;
    else
        d = (-b - sqrt(disc)) / 2.0;
    end
end


% 
% % === 测试脚本示例 ===
%  station.position = [1216362.376, -4736251.855, 4081268.723]; 
% station.angle = deg2rad(20); 
% 
% % 2. 构造卫星 (Satellite)
% satellite.position = [1938553.787, -5464462.851, 3700057.237]; 
% satellite.angle = deg2rad(45);
% 
% % 3. 直接调用函数 (假设你的函数在 +module 包文件夹下，或者是一个类静态方法)
% vis_ratio = module.Ground_Sat(station, satellite);
% 
% % 4. 输出结果
% if vis_ratio > 0
%     fprintf('可见! Ratio: %.4f\n', vis_ratio);
% else
%     disp('不可见');
% end
%  我们已经完成测试，该模块正常工作