function F = GetAzimuth
    F.GetAzimuth = @GetAzimuth;
      F.Azimuth_Angle = @Azimuth_Angle;
            F.Azimuth_Angle_vector = @Azimuth_Angle_vector;

      
end

function  Azimuth_Angle(root, satellite1_name, satellite2_name,starttime,endtime,timestep,pwd)
    % ������֤
    if nargin < 3
        error('��Ҫ�ṩ root ����������������ơ�');
    end
        unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    projection_vector_name = [unique_name_prefix, '_Projection_Vector'];
    azimuth_angle_name = [unique_name_prefix, '_Azimuth'];
    
    
    % ��ȡ���Ƕ���
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);
    
    % ��ȡ�������ǵ����ĵ�
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');
    
    % ��ȡ����1��Body XYƽ���Body X����ʸ��
    satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');
    satellite1_bodyY_vector = satellite1.vgt.Vector.Item('Body.Y');
    
    % ����������1������2��λ��ʸ��
%     displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
%         'Displacement_Vector', center_satellite1, center_satellite2);
%     
        displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
       displacement_vector_name, center_satellite1, center_satellite2);
    
    
    
    % ����λ��ʸ��������1 Body XYƽ���ϵ�ͶӰ
%     displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
%         'Displacement_Vector_Projection', '', 'eCrdnVectorTypeProjection');
%     
       displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
        projection_vector_name, '', 'eCrdnVectorTypeProjection');
    
    
    displacement_vector_projection.Source.SetVector(displacement_vector);
    displacement_vector_projection.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    
    % ���㷽λ�ǣ�Azimuth��
   % azimuth_angle = satellite1.vgt.Angles.Factory.Create( 'Azimuth', '', 'eCrdnAngleTypeBetweenVectors'  );
     
        azimuth_angle = satellite1.vgt.Angles.Factory.Create(azimuth_angle_name, '', 'eCrdnAngleTypeBetweenVectors'  );

    azimuth_angle.FromVector.SetVector(satellite1_bodyY_vector);
    azimuth_angle.ToVector.SetVector(displacement_vector_projection);
 
    % ��ʾ�������
    disp('��λ�ǹ�����ɣ�');
    
  
     
    angleAZ = satellite1.DataProviders.Item('Angles').Group.Item(azimuth_angle_name).Exec(starttime,endtime,timestep);

    angleAZData_AngleRate  = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues;

    angleAZData_Time  = angleAZ.DataSets.GetDataSetByName('Time').GetValues;

    % չ�����������ݣ��������ڵ�Ԫ���У�
    AngleRate = cell2mat(angleAZData_AngleRate);
    % ������table��������ʱ��Ϊ�ַ�����ʽ

    data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'AngleRate'});

    % ����д�뵽һ���ı��ļ�
    writetable(data_table, pwd, 'Delimiter', '\t');
    
    % and we need delete the vector
    
    % ����Ƿ����Ŀ��ʸ��
        vectorName =displacement_vector_name;
        if satellite1.vgt.Vectors.Contains(vectorName)
            % ɾ��ʸ��
            satellite1.vgt.Vectors.Remove(vectorName);
            disp(['ʸ�� "', vectorName, '" �ѳɹ�ɾ����']);
        else
            disp(['ʸ�� "', vectorName, '" �����ڣ��޷�ɾ����']);
        end

    
    
end
  

function  data_table=Azimuth_Angle_vector(root, satellite1_name, satellite2_name,starttime,endtime,timestep)
    % ������֤
    if nargin < 3
        error('��Ҫ�ṩ root ����������������ơ�');
    end
        unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    projection_vector_name = [unique_name_prefix, '_Projection_Vector'];
    azimuth_angle_name = [unique_name_prefix, '_Azimuth'];
    
    
    % ��ȡ���Ƕ���
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);
    
    % ��ȡ�������ǵ����ĵ�
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');
    
    % ��ȡ����1��Body XYƽ���Body X����ʸ��
    satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');
    satellite1_bodyY_vector = satellite1.vgt.Vector.Item('Body.Y');
    
    % ����������1������2��λ��ʸ��
%     displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
%         'Displacement_Vector', center_satellite1, center_satellite2);
%     
        displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
       displacement_vector_name, center_satellite1, center_satellite2);
    
    
    
    % ����λ��ʸ��������1 Body XYƽ���ϵ�ͶӰ
%     displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
%         'Displacement_Vector_Projection', '', 'eCrdnVectorTypeProjection');
%     
       displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
        projection_vector_name, '', 'eCrdnVectorTypeProjection');
    
    
    displacement_vector_projection.Source.SetVector(displacement_vector);
    displacement_vector_projection.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    
    % ���㷽λ�ǣ�Azimuth��
   % azimuth_angle = satellite1.vgt.Angles.Factory.Create( 'Azimuth', '', 'eCrdnAngleTypeBetweenVectors'  );
     
        azimuth_angle = satellite1.vgt.Angles.Factory.Create(azimuth_angle_name, '', 'eCrdnAngleTypeBetweenVectors'  );

    azimuth_angle.FromVector.SetVector(satellite1_bodyY_vector);
    azimuth_angle.ToVector.SetVector(displacement_vector_projection);
 
    % ��ʾ�������
    disp('��λ�ǹ�����ɣ�');
    
  
     
    angleAZ = satellite1.DataProviders.Item('Angles').Group.Item(azimuth_angle_name).Exec(starttime,endtime,timestep);

    angleAZData_AngleRate  = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues;

    angleAZData_Time  = angleAZ.DataSets.GetDataSetByName('Time').GetValues;

    % չ�����������ݣ��������ڵ�Ԫ���У�
    AngleRate = cell2mat(angleAZData_AngleRate);
    % ������table��������ʱ��Ϊ�ַ�����ʽ

    data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'AngleRate'});

 
    % and we need delete the vector
    
    % ����Ƿ����Ŀ��ʸ��
        vectorName =displacement_vector_name;
        if satellite1.vgt.Vectors.Contains(vectorName)
            
            % ɾ��ʸ��
            satellite1.vgt.Vectors.Remove(vectorName);
            disp(['ʸ�� "', vectorName, '" �ѳɹ�ɾ����']);
        else
            disp(['ʸ�� "', vectorName, '" �����ڣ��޷�ɾ����']);
        end

    
    
end
  