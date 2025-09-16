function r_eci = ecef2eci(r_ecef, utc_datetime)
    % r_ecef: 3x1 ECEF ��������
    % utc_datetime: datetime ���ͣ�UTC ʱ��
    % r_eci: 3x1 ECI ��������

    % 1. ����������
    JD = juliandate(utc_datetime);

    % 2. �� J2000.0 �������������
    T = (JD - 2451545.0) / 36525;

    % 3. ���� GMST����λ���ȣ�
    GMST = 280.46061837 + ...
           360.98564736629 * (JD - 2451545) + ...
           0.000387933 * T^2 - ...
           (T^3) / 38710000;

    % 4. �� GMST ��һ����ת��Ϊ����
    theta = mod(GMST, 360) * pi / 180;

    % 5. ��������ת������ Z ����ʱ����ת theta��
    R_inv = [cos(theta), -sin(theta), 0;
             sin(theta),  cos(theta), 0;
             0,           0,          1];

    % 6. ECEF �� ECI
    r_eci = R_inv * r_ecef;
end
% �������Ѿ���һ�� ECEF ���꣨��λ��km��
% r_ecef = [  4404.651206 ; -5971.834353 ;592.805101];
% 
% ʱ�䣨UTC��
% utc_time = datetime(2012, 2, 24, 18, 0, 0);
% 
% ת��Ϊ ECI ����
% r_eci = ecef2eci(r_ecef, utc_time)
