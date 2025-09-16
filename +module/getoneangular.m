function getoneangular(root,scenario,satellite1, satellite2, filepath)


% 
% 
% QF0101 = root.GetObjectFromPath('Satellite/C1_1101');
% QF0201 = root.GetObjectFromPath('Satellite/C1_2101');

   QF0101 = root.GetObjectFromPath(['Satellite/', satellite1]);
    QF0201 = root.GetObjectFromPath(['Satellite/', satellite2]);
 
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

 AB_vector_D_data_vector =  [x, y, z];

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

% ��ʱ�䵥Ԫ������ת��Ϊ�ַ�������
time_str = cellfun(@(x) char(x), AB_vector_D_data_Time, 'UniformOutput', false);
time_str = string(time_str); % ת��Ϊ�ַ�������

omega_x = omega_deg_per_sec(:,1);
omega_y = omega_deg_per_sec(:,2);
omega_z = omega_deg_per_sec(:,3);


% �������
result_table = table(...
    time_str, omega_x, omega_y, omega_z, ...
    'VariableNames', {'Time', 'Omega_X_deg_s', 'Omega_Y_deg_s', 'Omega_Z_deg_s'});
%folder = "C:\usrspace\stkfile\angularvelocity"; % ��ʹ����б�ܱ���ת��
%filename = "text.txt";

% �ϲ�·��
 

% д����
writetable(result_table, filepath, 'Delimiter', '\t');
 vectorName ='AB_vector';
    if QF0101.vgt.Vectors.Contains(vectorName)
        % ɾ��ʸ��
        QF0101.vgt.Vectors.Remove(vectorName);
        disp(['ʸ�� "', vectorName, '" �ѳɹ�ɾ����']);
    else
        disp(['ʸ�� "', vectorName, '" �����ڣ��޷�ɾ����']);
    end

 
end
