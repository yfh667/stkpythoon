
 

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

Gnd = module.station();
Gnd.SetStation(root, scenario, 'Facility1')


% 3. Ϊ������Ӵ�����
name  =  'QF_02_01'
satellite = root.GetObjectFromPath(['Satellite/' name]);
sensor = satellite.Children.New('eSensor',name); % ����������
%���ýǶ�Ϊ
sensor.CommonTasks.SetPatternSimpleConic(45, 0.1)
 
% 3. Ϊ����վ��Ӵ�����
facilityName = 'Facility1';
facility = root.GetObjectFromPath(['Facility/' facilityName]);
sensor = facility.Children.New('eSensor',facilityName); % ����������
%���ýǶ�Ϊ
sensor.CommonTasks.SetPatternSimpleConic(70, 0.1)





% 1. ��ȡ����
satelliteName = 'QF_02_01';
facilityName = 'Facility1';
satellite = root.GetObjectFromPath(['Satellite/' satelliteName]);
facility = root.GetObjectFromPath(['Facility/' facilityName]);
% 2. ��ȡ����������
satelliteSensor = satellite.Children.Item(satelliteName); % ��ȡ���ǵĴ�����
facilitySensor = facility.Children.Item(facilityName); % ��ȡ����վ�Ĵ�����
% 3. �������ʷ���
access = satelliteSensor.GetAccessToObject(facilitySensor);

% 4. �������
access.ComputeAccess();


% 5. ��ȡ���ʽ��
results = access.DataProviders.Item('Access Data');

% 6. ��ȡ����ʱ���
startTimes =scenario.StartTime;
stopTimes =scenario.StopTime;


resInfo = results.Exec(startTimes, stopTimes);

Access_Start_Time  = resInfo.DataSets.GetDataSetByName('Start Time').GetValues;

Access_Stop_Time  = resInfo.DataSets.GetDataSetByName('Stop Time').GetValues;
%Access_Duration_Time  = resInfo.DataSets.GetDataSetByName('Duration').GetValues;

% ��ʼ����ͨ����洢�ϲ����
access_time = strings(length(Access_Start_Time), 2);

% ѭ���ϲ���ʼ�ͽ���ʱ��
for i = 1:length(Access_Start_Time)
    access_time(i, 1) = Access_Start_Time{i}; % ��ʼʱ��
    access_time(i, 2) = Access_Stop_Time{i}; % ����ʱ��
end
% ���ַ�������ת��Ϊ���
access_time_table = array2table(access_time, ...
    'VariableNames', {'Start_Time', 'Stop_Time'}); % ����б���

% ���屣��·��
filepath = 'C:\usrspace\stkfile\los\access_time.txt';

% �������ļ�
writetable(access_time_table, filepath, 'Delimiter', '\t');

disp(['�����ѱ��浽�ļ���', filepath]);
 
 



 
