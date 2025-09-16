
 

 % �����Ƿ�ʹ�� STK Engine
USE_ENGINE = false;
 
% ��ʼ�� STK
if USE_ENGINE
    % ��ʼ�� STK Engine
    app = actxserver('STKX11.application');
    root = actxserver('AgStkObjects11.AgStkObjectRoot');
else
    % ��ʼ�� STK Ӧ�ó���
    app = actxserver('STK11.application');
    root = app.Personality2; 
end
%����senario��ʱ��
StartTime  =  '24 Feb 2012 18:00:00.000';
StopTime =  '25 Feb 2012 18:00:00.000';
scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod(StartTime,StopTime);
scenario.StartTime = StartTime;
scenario.StopTime = StopTime;

 


% �������Ѿ��� root �� scenario ����
% root = ...; 
% scenario = ...;

% ���ѭ�����������ظ����Σ����紴�����鲻ͬ��������

% P =18
% N = 36
P =10
N = 10
for i = 1:P
    
    %=============== 
    % 1. ���á��������ǡ�����
    %=============== 
    % Ϊ�����ֲ�ͬѭ�����ɵ����ǣ�������������һ�����±������
    seedSatelliteName = sprintf('QF_%d', i);
	
    % ������ʼ״̬����
    params = struct();
    params.satelliteName = seedSatelliteName;
    params.perigeeAlt    = 1066;    % km
    params.apogeeAlt     = 1066;    % km
    params.inclination   = 89;      % ��
    params.argOfPerigee  = 0;       % ���ص����
    params.RAAN          = i*10.2;       % ������ྭ(�ɰ�����ѭ���и�)
    params.Anomaly       = i*4.5;       % ������(��ƽ�����)

    %=============== 
    % 2. ������������
    %=============== 
    satObj = module.sat();  % ���Զ���� sat ��
    satObj.createSatellite(root, scenario, params);

    %=============== 
    % 3. ���岢���� Walker ����
    %=============== 
    % ��������1������桢ÿ��30�����ǣ����������λ����
    params_constellation = struct();
    params_constellation.seedSatelliteName       = seedSatelliteName; 
    params_constellation.numPlanes               = 1;    % ���ƽ������
    params_constellation.numSatsPerPlane         = N;   % ÿ��ƽ���������
    params_constellation.interPlanePhaseIncrement= 0;    % ƽ�����λ����(�˴�Ϊ0)

    satObj.createWalkerConstellation_Delta(root, params_constellation);

    %=============== 
    % 4. ж����������
    %=============== 
    % ���� Walker �����Ѵ����꣬����ɾ��ԭ�ȵ���������
    unloadCmd = sprintf('Unload / */Satellite/%s', seedSatelliteName);
    root.ExecuteCommand(unloadCmd);

end

 

 sat = module.sat();

satellite_names =sat.getSatelliteNames(scenario);
sat.batchRenameSatellitesInSTK(root,satellite_names)


%we set the station
facilityName = 'Facility1'
 
Gnd = module.station();

Gnd.SetStation(root, scenario,facilityName )

 
% we se the sensror for the station
Los = module.SensorModule();
Los.CreateGndSensor(root,facilityName,70);


 
% �����ļ�·��

filepath = 'C:\usrspace\stkfile\los';

 
 
 
% % ���� P �� N �Ѷ���


for i = 1:P
    for j = 1:N
 
         if i < 10
            startx = ['0', num2str(i)];
        else
            startx = num2str(i);
        end
        
        % ���� j �ĸ�ʽ����λ���֣�
        if j < 10
            starty = ['0', num2str(j)];
        else
            starty = num2str(j);
        end
        
        % ��������1����
        sat1 = ['QF_', startx, '_',starty];
% Ϊsat1����angle
    Los.CreateSatSensor(root,sat1,45)
    Los.LosCalculate(root, sat1, facilityName,scenario.StartTime,scenario.StopTime, filepath)
    end
end



 
