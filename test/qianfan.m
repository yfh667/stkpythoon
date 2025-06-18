
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
StartTime  =  '6 Jan 2025 00:00:00.000';
StopTime =  '7 Jan 2025 00:00:00.000';
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

 P =18
 N = 36
%P =3
%N = 36
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
sat.batchRenameSatellitesInSTK2(root,satellite_names)




 

%first we get all the satellite name
 satellite_names =sat.getSatelliteNames(scenario);
 
 %then we need pair the satellite, for example  QF_01_01 pair with QF_02_01
 %all the name is start with QF_x_y, x means the track,and y mean the id 
 

% �����ļ�·��

filepath = 'C:\usrspace\stkfile\sats\';


 

 
% % ���� P �� N �Ѷ���
for i = 1:P-1
    for j = 1:N
        % ���� i �ĸ�ʽ����λ���֣�
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
        
        % ���� i+1 �ĸ�ʽ����λ���֣�
        if i+1 < 10
            startx2 = ['0', num2str(i+1)];
        else
            startx2 = num2str(i+1);
        end
        
        % ��������2����
        if j < 10
            starty2 = ['0', num2str(j)];
        else
            starty2 = num2str(j);
        end
        sat2 = ['QF_', startx2, '_',starty2];
        
        % �����ļ���
        filename = sprintf('%02d_%02d.txt', i, j);
        path = fullfile(filepath, filename);
        
        % ���� Azimuth_Angle ����
        % �������
        disp(['�������: ', filename]);

        Azmuth  = module.Get_Azimuth();

        Azmuth.Azimuth_Angle(root, sat1, sat2,scenario.StartTime,scenario.StopTime,1,path)
 
    end
end







 


% reportParams = struct();
% %reportParams.satelliteName = 'Satellite1';
% reportParams.reportStyle = 'fixed';  % ʹ����Ч�ı�����ʽ
% reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
%  
% reportParams.startTime = '24 Feb 2012 16:00:00.000';
% reportParams.stopTime = '25 Feb 2012 16:00:00.000';
% reportParams.timeStep = 1;
% 
% % get the satellite name so we could print the waypoint
% 
% 
% ExportRe = ExportRe();
% % ���ú������ɱ���
% %ExportRe.RePort(root, name,'Satellite',reportParams);
% 
% 
% %ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);
% %���ǲ��ò��У�ע�⣬Ŀǰֻ��matlb�˲����ˣ�ʵ������stk�Լ�Ҳ���Բ��У��Ժ�������
% ExportRe.MultilRePort_Para(root,'Satellite', satellite_names,reportParams);


if USE_ENGINE

try
    delete(app); % �ͷ� COM ����
    disp('STK Ӧ���ѹرա�');
catch ME
    disp('�޷��ر� STK Ӧ�á�');
end

end

 