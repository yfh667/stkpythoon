function r_eci = ecef2eci(r_ecef, utc_datetime)
    % r_ecef: 3x1 ECEF 坐标向量
    % utc_datetime: datetime 类型，UTC 时间
    % r_eci: 3x1 ECI 坐标向量

    % 1. 计算儒略日
    JD = juliandate(utc_datetime);

    % 2. 从 J2000.0 起的儒略世纪数
    T = (JD - 2451545.0) / 36525;

    % 3. 计算 GMST（单位：度）
    GMST = 280.46061837 + ...
           360.98564736629 * (JD - 2451545) + ...
           0.000387933 * T^2 - ...
           (T^3) / 38710000;

    % 4. 将 GMST 归一化并转换为弧度
    theta = mod(GMST, 360) * pi / 180;

    % 5. 构建逆旋转矩阵（绕 Z 轴逆时针旋转 theta）
    R_inv = [cos(theta), -sin(theta), 0;
             sin(theta),  cos(theta), 0;
             0,           0,          1];

    % 6. ECEF → ECI
    r_eci = R_inv * r_ecef;
end
% 假设你已经有一个 ECEF 坐标（单位：km）
% r_ecef = [  4404.651206 ; -5971.834353 ;592.805101];
% 
% 时间（UTC）
% utc_time = datetime(2012, 2, 24, 18, 0, 0);
% 
% 转换为 ECI 坐标
% r_eci = ecef2eci(r_ecef, utc_time)
