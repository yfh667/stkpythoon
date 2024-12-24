
% �����Ƿ�ʹ�� STK Engine
USE_ENGINE = true;

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


% ���� Walker ��������
params_constellation = struct();
params_constellation.seedSatelliteName =seedsatename;          % ������������
params_constellation.numPlanes = 10;                             % ���ƽ������
params_constellation.numSatsPerPlane =18;                       % ÿ��ƽ�����������
params_constellation.interPlanePhaseIncrement = 0;

 
 


% ���ú��������� Walker ����
sat.createWalkerConstellation_Delta(root, params_constellation);
%we finish the waler ,so we need delet  the seed satellite
 root.ExecuteCommand(['Unload / */Satellite/' seedsatename]);



 



%we get the report
% Satellite
% Facility
% ���屨�����
reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % ʹ����Ч�ı�����ʽ
reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
 
reportParams.startTime = '24 Feb 2012 16:00:00.000';
reportParams.stopTime = '25 Feb 2012 16:00:00.000';
reportParams.timeStep = 1;
% name = 'Satellite1'

% get the satellite name so we could print the waypoint
satellite_names =sat.getSatelliteNames(scenario);
ExportRe = ExportRe();
% ���ú������ɱ���
%ExportRe.RePort(root, name,'Satellite',reportParams);


ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);

 
% ��python�ű�ȥ����matlab̫����
%ExportRe.MultiModifyReport('Satellite', 'E:/STK_file/sats')

% ��ʼ�� STK
if USE_ENGINE

    %------% �ر�engine
    % 1. �ͷŸ�����AgStkObjectRoot��
    delete(root);
    clear root;
    % 3. �ͷ� STKXApplication ����
    delete(STKXApplication);
    clear STKXApplication;

end