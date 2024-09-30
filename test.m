
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

StartTime  =  '24 Feb 2012 18:00:00.000';
StopTime =  '25 Feb 2012 18:00:00.000';
scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod('24 Feb 2012 16:00:00.000','25 Feb 2012 16:00:00.000');
scenario.StartTime = StartTime;
scenario.StopTime = StopTime;

root.ExecuteCommand('Animate * Reset');

% here we get the facuilt
facility = scenario.Children.New('eFacility','GroundStation1');
facility.Position.AssignGeodetic(0.75,101,0);

facility = scenario.Children.New('eFacility','GroundStation2');
facility.Position.AssignGeodetic(0.64,112,0);

facility = scenario.Children.New('eFacility','GroundStation3');
facility.Position.AssignGeodetic(10,112,0);



seedsatename = 'horizontal'
%we set the seed satellite
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 500;  % km
params.apogeeAlt = 500;
params.inclination = 0;
params.argOfPerigee = 0;
params.RAAN = 0;
params.Anomaly = 0;
%we set the first seed1 satellite
sat = sat();
sat.createSatellite(root, scenario, params);


% ���� Walker ��������
params_constellation = struct();
params_constellation.seedSatelliteName =seedsatename;          % ������������
params_constellation.numPlanes = 1;                             % ���ƽ������
params_constellation.numSatsPerPlane = 20;                       % ÿ��ƽ�����������
params_constellation.interPlaneTrueAnomalyIncrement = 50;       % ƽ�����������������
params_constellation.raanIncrement = 0;                         % RAAN ��������

% ���ú��������� Walker ����
sat.createWalkerConstellation(root, params_constellation);
%we finish the waler ,so we need delet  the seed satellite
 root.ExecuteCommand(['Unload / */Satellite/' seedsatename]);




seedsatename2 = 'vertical'
%we set the seed satellite
params = struct();
params.satelliteName = seedsatename2;
params.perigeeAlt = 500;  % km
params.apogeeAlt = 500;
params.inclination = 90;
params.argOfPerigee = 0;
params.RAAN = 0;
params.Anomaly = 0;
% we set up the seed2 satellite
sat.createSatellite(root, scenario, params);
params_constellation.seedSatelliteName =seedsatename2;          % ������������
sat.createWalkerConstellation(root, params_constellation);
root.ExecuteCommand(['Unload / */Satellite/' seedsatename2]);



%we get the report
% Satellite
% Facility
% ���屨�����
reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % ʹ����Ч�ı�����ʽ
reportParams.filePath = 'E:/STK_file/sats';
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 60;
% name = 'Satellite1'

% get the satellite name so we could print the waypoint
satellite_names =sat.getSatelliteNames(scenario);
ExportRe = ExportRe();
% ���ú������ɱ���
%ExportRe.RePort(root, name,'Satellite',reportParams);


ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);




reportParams = struct();
reportParams.reportStyle = 'fixed';  % ʹ����Ч�ı�����ʽ
reportParams.filePath = 'E:/STK_file/stations';
reportParams.startTime = StartTime;
reportParams.stopTime =StopTime;
reportParams.timeStep = 60;
% name = 'GroundStation'
%  ExportRe.RePort(root, 'Facility',name,reportParams);
station2 = station();
station_names =station2.getStation_names(scenario);
ExportRe.MultilRePort(root,'Facility', station_names,reportParams);

