 


function F = stk_angular_velocity
    F.GetAzimuth = @GetAzimuth;
    F.GetPitch = @GetPitch;
    F.GetAngularVelocity = @GetAngularVelocity;
end

% ��ȡ��λ�ǣ�Azimuth���ٶ�
function data_table = GetAzimuth(root, satellite1_name, satellite2_name, starttime, endtime, timestep)
    % ������֤
    if nargin < 3
        error('��Ҫ�ṩ root ����������������ơ�');
    end
    
    % Ψһǰ׺
    unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    azimuth_angle_name = [unique_name_prefix, '_Azimuth'];
projection_vector_name =  [unique_name_prefix, '_Projection_Vector'];
    % ��ȡ���Ƕ���
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);

    % ��ȡ�������ĵ�
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');

    % ����λ��ʸ����ֻ����һ�Σ�
    displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(displacement_vector_name, center_satellite1, center_satellite2);
    
    % ��ȡ����1��Body Y���������ڼ��㷽λ�ǣ�
    satellite1_bodyY_vector = satellite1.vgt.Vector.Item('Body.Y');
        satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');
        
    %����ͶӰ����
        displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
        projection_vector_name, '', 'eCrdnVectorTypeProjection');

    
    displacement_vector_projection.Source.SetVector(displacement_vector);
    displacement_vector_projection.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    

    % ������λ�Ƕ���
    azimuth_angle = satellite1.vgt.Angles.Factory.Create(azimuth_angle_name, '', 'eCrdnAngleTypeBetweenVectors');
    azimuth_angle.FromVector.SetVector(satellite1_bodyY_vector);
    azimuth_angle.ToVector.SetVector(displacement_vector_projection);

    % ��ʾ�������
    disp('��λ�ǹ�����ɣ�');

    % ��ȡ��λ�����ݲ�������ٶ�
    angleAZ = satellite1.DataProviders.Item('Angles').Group.Item(azimuth_angle_name).Exec(starttime, endtime, timestep);
    angleAZData_AngleRate = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues;
    angleAZData_Time = angleAZ.DataSets.GetDataSetByName('Time').GetValues;

    % չ������������
    AngleRate = cell2mat(angleAZData_AngleRate);

    % �������
    data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'Azimuth_AngleRate'});

    % ɾ��ʸ������������
    if satellite1.vgt.Vectors.Contains(displacement_vector_name)
        satellite1.vgt.Vectors.Remove(displacement_vector_name);
        disp(['ʸ�� "', displacement_vector_name, '" �ѳɹ�ɾ����']);
    else
        disp(['ʸ�� "', displacement_vector_name, '" �����ڣ��޷�ɾ����']);
    end
end

% ��ȡ�����ǣ�Pitch���ٶ�
function data_table = GetPitch(root, satellite1_name, satellite2_name, starttime, endtime, timestep)
    % ������֤
    if nargin < 3
        error('��Ҫ�ṩ root ����������������ơ�');
    end
    
    % Ψһǰ׺
    unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    pitch_angle_name = [unique_name_prefix, '_Pitch'];

    % ��ȡ���Ƕ���
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);

    % ��ȡ�������ĵ�
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');

    % ����λ��ʸ����ֻ����һ�Σ�
    displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(displacement_vector_name, center_satellite1, center_satellite2);

    % ��ȡ����1��Body XYƽ�棨���ڼ��㸩���ǣ�
    satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');

    % ���������Ƕ���
    pitch_angle = satellite1.vgt.Angles.Factory.Create(pitch_angle_name, '', 'eCrdnAngleTypeToPlane');
    pitch_angle.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    pitch_angle.ReferenceVector.SetVector(displacement_vector);

    % ��ʾ�������
    disp('�����ǹ�����ɣ�');

    % ��ȡ���������ݲ�������ٶ�
    anglePit = satellite1.DataProviders.Item('Angles').Group.Item(pitch_angle_name).Exec(starttime, endtime, timestep);
    anglePitData_AngleRate = anglePit.DataSets.GetDataSetByName('AngleRate').GetValues;
    anglePitData_Time = anglePit.DataSets.GetDataSetByName('Time').GetValues;

    % չ������������
    AngleRate = cell2mat(anglePitData_AngleRate);

    % �������
    data_table = table(anglePitData_Time, AngleRate, 'VariableNames', {'Time', 'Pitch_AngleRate'});

    % ɾ��ʸ������������
    if satellite1.vgt.Vectors.Contains(displacement_vector_name)
        satellite1.vgt.Vectors.Remove(displacement_vector_name);
        disp(['ʸ�� "', displacement_vector_name, '" �ѳɹ�ɾ����']);
    else
        disp(['ʸ�� "', displacement_vector_name, '" �����ڣ��޷�ɾ����']);
    end
end




function data_table = GetAngularVelocity(root, satellite1_name, satellite2_name, starttime, endtime, timestep, pwd)
    % ������֤
    if nargin < 3
        error('��Ҫ�ṩ root ����������������ơ�');
    end
    
    % ��ȡ��λ�����ݣ�Azimuth��
    Az = GetAzimuth(root, satellite1_name, satellite2_name, starttime, endtime, timestep);
    
    % ��ȡ���������ݣ�Pitch��
    Pit = GetPitch(root, satellite1_name, satellite2_name, starttime, endtime, timestep);
    
    % ��ȡ Azimuth �� Pitch ��ʱ��ͽǶ�����
    Az_Time = Az.Time;
    Az_AngleRate = Az.Azimuth_AngleRate;
    
    Pit_Time = Pit.Time;
    Pit_AngleRate = Pit.Pitch_AngleRate;
    
    % ȷ��ʱ����루ȡ��ͬʱ���Ľ�����
    [common_time, Az_idx, Pit_idx] = intersect(Az_Time, Pit_Time);  % �ҵ���ͬ��ʱ���
    
    % �� Az �� Pit ����ȡ�����ĽǶ�����
    Az_AngleRate_Common = Az_AngleRate(Az_idx);
    Pit_AngleRate_Common = Pit_AngleRate(Pit_idx);
    
    % �����ϲ��ı��
    data_table = table(common_time, Az_AngleRate_Common, Pit_AngleRate_Common, ...
        'VariableNames', {'Time', 'Azimuth_AngleRate_deg', 'Pitch_AngleRate_deg'});
    
    % �����д�뵽�ļ�
    writetable(data_table, pwd, 'Delimiter', '\t');
    
    % ��ʾ�ļ��ѱ���
    disp(['�����ѱ��浽�ļ�: ', pwd]);
end


