
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

if USE_ENGINE
    % �� USE_ENGINE Ϊ true �������ִ�е��߼�
    % �������߼�����
else
    % �� USE_ENGINE Ϊ false ʱ��ִ�и�λ��������
    try
        root.ExecuteCommand('Animate * Reset');
        disp('�����Ѹ�λ�ɹ�');
    catch ME
        disp('������λʧ��:');
        disp(ME.message);
    end
end



%������������
seedsatename = 'horizontal'
%we set the seed satellite
%������ýṹ��ȥ��ֵ���������
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 1000;  % km
params.apogeeAlt = 1000;
params.inclination =53;
params.argOfPerigee = 0;
params.RAAN = 0;
params.Anomaly = 0;
%we set the first seed1 satellite
sat = sat();
sat.createSatellite(root, scenario, params);

%������������
seedsatename = 'horizontal2'
%we set the seed satellite
%������ýṹ��ȥ��ֵ���������
params = struct();
params.satelliteName = seedsatename;
params.perigeeAlt = 1000;  % km
params.apogeeAlt = 1000;
params.inclination =53;
params.argOfPerigee = 0;
params.RAAN = 10;
params.Anomaly =20;
%we set the first seed1 satellite
sat = sat();
sat.createSatellite(root, scenario, params);


reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % ʹ����Ч�ı�����ʽ
reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
 
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 1;

% get the satellite name so we could print the waypoint
satellite_names =sat.getSatelliteNames(scenario);
ExportRe = ExportRe();
% ���ú������ɱ���
%ExportRe.RePort(root, name,'Satellite',reportParams);


%ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);
%���ǲ��ò��У�ע�⣬Ŀǰֻ��matlb�˲����ˣ�ʵ������stk�Լ�Ҳ���Բ��У��Ժ�������
ExportRe.MultilRePort_Para(root,'Satellite', satellite_names,reportParams);

