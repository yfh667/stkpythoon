%����Ϊ���Դ��룬����
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
    satObj = module.sat();  % ���Զ���� sat ��
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


sat = module.sat();

satellite_names =sat.getSatelliteNames(scenario);
sat.batchRenameSatellitesInSTK(root,satellite_names)


 
    


QF0101 = root.GetObjectFromPath('Satellite/QF_01_01');
QF0201 = root.GetObjectFromPath('Satellite/QF_02_01');
centerQF0101 = QF0101.vgt.Points.Item('Center');
centerQF0201 = QF0201.vgt.Points.Item('Center');

timestep = 1
%first we need create the AB_vector

AB_vector = QF0101.vgt.Vectors.Factory.CreateDisplacementVector('AB_vector',centerQF0101,centerQF0201);

% we need get the ab_vector data in the A body referrence system
AB_vector_data = QF0101.DataProviders.Item('Vectors(Body)').Group.Item('AB_vector').Exec(scenario.StartTime,scenario.StopTime,timestep);
AB_vector_data_Time  = AB_vector_data.DataSets.GetDataSetByName('Time').GetValues
AB_vector_data_x =  AB_vector_data.DataSets.GetDataSetByName('x').GetValues
AB_vector_data_y =  AB_vector_data.DataSets.GetDataSetByName('y').GetValues
AB_vector_data_z =  AB_vector_data.DataSets.GetDataSetByName('z').GetValues
x = cell2mat(AB_vector_data_x); % �� {[627.3107]} ת��Ϊ [627.3107; ...]
y = cell2mat(AB_vector_data_y);
z = cell2mat(AB_vector_data_z);
AB_vector_data_vector = [x, y, z]; % �õ� N��3 �ľ���ÿ�д���һ������ [x, y, z]


QF0101Axes=  QF0101.vgt.Axes.Item('Body'); 
% sencond we get  the deriative of the ab_vector
 
 
  AB_vector_D = QF0101.vgt.Vectors.Factory.Create('AB_vector_D','','eCrdnVectorTypeDerivative');

  AB_vector_D.Vector.SetVector(AB_vector);
  AB_vector_D.ReferenceAxes.SetAxes(QF0101Axes);
  
  AB_vector_D_data = QF0101.DataProviders.Item('Vectors(Body)').Group.Item('AB_vector_D').Exec(scenario.StartTime,scenario.StopTime,timestep);
AB_vector_D_data_Time  = AB_vector_D_data.DataSets.GetDataSetByName('Time').GetValues;
AB_vector_D_data_x =  AB_vector_D_data.DataSets.GetDataSetByName('x').GetValues;
AB_vector_D_data_y =  AB_vector_D_data.DataSets.GetDataSetByName('y').GetValues;
AB_vector_D_data_z =  AB_vector_D_data.DataSets.GetDataSetByName('z').GetValues;
  
 x = cell2mat(AB_vector_D_data_x); % �� {[627.3107]} ת��Ϊ [627.3107; ...]
y = cell2mat(AB_vector_D_data_y);
z = cell2mat(AB_vector_D_data_z);
AB_vector_D_data_vector = [x, y, z]; % �õ� N��3 �ľ���ÿ�д���һ������ [x, y, z]

 

% ������
cross_product = cross(AB_vector_data_vector, AB_vector_D_data_vector, 2);

% ����ģ��ƽ��
r_norm_sq = sum(AB_vector_data_vector.^2, 2);

% ����Сֵ
epsilon = 1e-10;
r_norm_sq = max(r_norm_sq, epsilon);

% ������ٶ�
omega = cross_product ./ r_norm_sq;
% ���廡�ȵ��Ƕȵ�ת������
rad2deg = 180 / pi;

% ����������ת��Ϊ��/��
omega_deg_per_sec = omega * rad2deg;

 


 
%so we get the omage,and we need get the azmiuth and the elevation


%azmiuth:exactly the projection in the XOY.it is the  omega(z)



%elevation:exactly  it is the  omega(y)


% ��ȡ����
omega_z = omega_deg_per_sec(:, 1);
N = size(omega_deg_per_sec, 1);
t = 0:N-1;

% ��������Ӧͼ�δ���
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]);

% ��������
plot(t, omega_z, 'LineWidth', 2);
xlabel('ʱ�� (��)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('���ٶ� z ���� (��/s)', 'FontSize', 14, 'FontWeight', 'bold');
title('���ٶ� z ������ʱ��仯', 'FontSize', 16, 'FontWeight', 'bold');
grid on;

% ����������
ax = gca;
ax.FontSize = 12;
ax.LineWidth = 1.5;
xlim([min(t), max(t)]);
ylim([min(omega_z)*1.1, max(omega_z)*1.1]);

 
