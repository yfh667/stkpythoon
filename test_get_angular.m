
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

% �������Ѿ��� root �� scenario ����
% root = ...; 
% scenario = ...;

% ���ѭ�����������ظ����Σ����紴�����鲻ͬ��������


P = 2
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
    satObj = satsetup();  % ���Զ���� sat ��
    satObj.createSatellite(root, scenario, params);

    %=============== 
    % 3. ���岢���� Walker ����
    %=============== 
    % ��������1������桢ÿ��30�����ǣ����������λ����
    params_constellation = struct();
    params_constellation.seedSatelliteName       = seedSatelliteName; 
    params_constellation.numPlanes               = 1;    % ���ƽ������
    params_constellation.numSatsPerPlane         = 30;   % ÿ��ƽ���������
    params_constellation.interPlanePhaseIncrement= 0;    % ƽ�����λ����(�˴�Ϊ0)

    satObj.createWalkerConstellation_Delta(root, params_constellation);

    %=============== 
    % 4. ж����������
    %=============== 
    % ���� Walker �����Ѵ����꣬����ɾ��ԭ�ȵ���������
    unloadCmd = sprintf('Unload / */Satellite/%s', seedSatelliteName);
    root.ExecuteCommand(unloadCmd);

end


sat = sat();

satellite_names =sat.getSatelliteNames(scenario);
sat.batchRenameSatellitesInSTK(root,satellite_names)


 



QF0101 = root.GetObjectFromPath('Satellite/QF_01_01');
QF0201 = root.GetObjectFromPath('Satellite/QF_02_01');
centerQF0101 = QF0101.vgt.Points.Item('Center');
centerQF0201 = QF0201.vgt.Points.Item('Center');
QF0101Body_xy =  QF0101.vgt.Plane.Item('Body.XY');
QF0101_vector_bodyx =  QF0101.vgt.Vector.Item('Body.X');
AB_vector = QF0101.vgt.Vectors.Factory.CreateDisplacementVector('AB_vector',centerQF0101,centerQF0201);

AB_vector_projection = QF0101.vgt.Vectors.Factory.Create('AB_vector_projection','','eCrdnVectorTypeProjection');
 
AB_vector_projection.Source.SetVector(AB_vector);
AB_vector_projection.ReferencePlane.SetPlane(QF0101Body_xy) 

Azimuth = QF0101.vgt.Angles.Factory.Create('Azimuth','','eCrdnAngleTypeBetweenVectors');
Azimuth.FromVector.SetVector(QF0101_vector_bodyx);
Azimuth.ToVector.SetVector(AB_vector_projection);

angleAZ = QF0101.DataProviders.Item('Angles').Group.Item('Azimuth').Exec(scenario.StartTime,scenario.StopTime,60);

angleAZData_AngleRate  = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues
angleAZData_Time  = angleAZ.DataSets.GetDataSetByName('Time').GetValues
 
 
% չ�����������ݣ��������ڵ�Ԫ���У�
AngleRate = cell2mat(angleAZData_AngleRate);

% ������table��������ʱ��Ϊ�ַ�����ʽ
data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'AngleRate'});

  

% ����д�뵽һ���ı��ļ�
writetable(data_table, 'C:\usrspace\stkfile\sats\output.txt', 'Delimiter', '\t');

% ��ʾ��ʾ��Ϣ
disp('�����ѳɹ������� output.txt �ļ��С�');


%here we need delete the vector
% ���� QF0101 ��Ŀ�����Ƕ���
QF0101 = root.GetObjectFromPath('Satellite/QF_01_01');

% ����Ƿ����Ŀ��ʸ��
vectorName = 'AB_vector';
if QF0101.vgt.Vectors.Contains(vectorName)
    % ɾ��ʸ��
    QF0101.vgt.Vectors.Remove(vectorName);
    disp(['ʸ�� "', vectorName, '" �ѳɹ�ɾ����']);
else
    disp(['ʸ�� "', vectorName, '" �����ڣ��޷�ɾ����']);
end

 
%����ͶӰ

Azmuth  = Get_Azimuth();

pwd = 'C:\usrspace\stkfile\sats\output.txt'
Azmuth.Azimuth_Angle(root, 'QF_01_01', 'QF_02_01',scenario.StartTime,scenario.StopTime,60,pwd)






 %����BA����
cmd = 'VectorTool * Satellite/QF_01_01 Create Vector Displacement_QF "Displacement" "Satellite/QF_01_01 Center" "Satellite/QF_02_01 Center"';
root.ExecuteCommand(cmd);


cmd = 'VectorTool * Satellite/QF_01_01 Create Vector Displacement_QF_Project "Projection" "Satellite/QF_01_01 Displacement_QF"   "  Satellite/QF_01_01 Body.XY"';
root.ExecuteCommand(cmd);


%������λ��
cmd = 'VectorTool * Satellite/QF_01_01 Create Angle  AZ_QF  "Between Vectors"	  "Satellite/QF_01_01 Body.X"  "Satellite/QF_01_01 Displacement_QF_Project"';
root.ExecuteCommand(cmd);



qf1 = root.GetObjectFromPath('Satellite/QF_01_01');
dp = qf1.DataProviders.Item('Angles');

satelliteDP3 = dp.Group.Item('AZ_QF')


% ���� "AZ_QF" �� TimeVar
dpTimeVar = satelliteDP3;  

startTime = '24 Feb 2012 18:00:00.000';
stopTime  = '25 Feb 2012 18:00:00.000';
timeStep  = 60;  % 60��

% ��Ҫ���У����磺Time��Angle��AngleRate
elements = {'Time','AngleRate'};

% ִ�в�ѯ
drResult = dpTimeVar.ExecElements(startTime, stopTime, timeStep, elements);
da = drResult.DataSets


%test
%satellite= children.Item('QF_01_01');

satellite= root.GetObjectFromPath('Satellite/QF_01_01');
dpPos2 = satellite.DataProviders.GetDataPrvTimeVarFromPath("Cartesian Position//J2000");


 
elems  ={'Time', 'x','y', 'z' };
 
resPos= dpPos2.ExecElements(StartTime, StopTime, 60, elems);
dsPos = resPos.DataSets;




reportParams = struct();
%reportParams.satelliteName = 'Satellite1';
reportParams.reportStyle = 'fixed';  % ʹ����Ч�ı�����ʽ
reportParams.filePath = 'C:/usrspace/stkfile/matlabfile';
 
 
reportParams.startTime = StartTime;
reportParams.stopTime =StopTime;
reportParams.timeStep = 1;

% get the satellite name so we could print the waypoint


ExportRe = ExportRe();
% ���ú������ɱ���
%ExportRe.RePort(root, name,'Satellite',reportParams);


%ExportRe.MultilRePort(root,'Satellite', satellite_names,reportParams);
%���ǲ��ò��У�ע�⣬Ŀǰֻ��matlb�˲����ˣ�ʵ������stk�Լ�Ҳ���Բ��У��Ժ�������
ExportRe.MultilRePort_Para(root,'Satellite', satellite_names,reportParams);


