%����Ϊ���Դ��룬����
% �����Ƿ�ʹ�� STK Engine
USE_ENGINE = 0;

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

% �������Ѿ��� root �� scenario ����
% root = ...; 
% scenario = ...;

% ���ѭ�����������ظ����Σ����紴�����鲻ͬ��������
%RAAN = 10.2


N = 10
P = 3
RAAN = 360/10

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
    params.RAAN          = i*RAAN;       % ������ྭ(�ɰ�����ѭ���и�)
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


numberofsatellite = P*N
position = module.Get_Position()
timestep = 1
new_satellite_names =sat.getSatelliteNames(scenario);

max_raw = 3600
 for i =1:numberofsatellite
 
  satellite1_name =new_satellite_names(i)
  satellite1_name =  satellite1_name{1,1}
  
  filename = num2str(i)
  
 % pwd = 'C:\usrspace\stkfile\sats\output.txt'
 pwd = ['C:\usrspace\stkfile\position\',filename,'.txt']
 
 
position.GetPositionxyz(root, satellite1_name,scenario.StartTime,scenario.StopTime,timestep,pwd,max_raw)


 end
 
 
 % ��ʼ�� STK
if USE_ENGINE

    %------% �ر�engine
    % 1. �ͷŸ�����AgStkObjectRoot��
    delete(root);
    clear root;
    % 3. �ͷ� STKXApplication ����
    delete(app);
    clear STKXApplication;

end


