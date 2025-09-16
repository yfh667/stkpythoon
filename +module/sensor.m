

i=1
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
    satObj = sat();  % ���Զ���� sat ��
    satObj.createSatellite(root, scenario, params);
    
     
 

% 3. Ϊ������Ӵ�����
name  =  'QF_02_01'
satellite = root.GetObjectFromPath(['Satellite/' name]);
sensor = satellite.Children.New('eSensor',name); % ����������
%���ýǶ�Ϊ
sensor.CommonTasks.SetPatternSimpleConic(45, 0.1)
 

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


Los = SensorModule();
 Los.LosCalculate(root, satelliteName, facilityName,scenario.StartTime,scenario.StopTime, filepath)

 


 
