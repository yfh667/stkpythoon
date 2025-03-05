function F = GetAzimuth
    F.GetAzimuth = @GetAzimuth;
      F.Azimuth_Angle = @Azimuth_Angle;
            F.Azimuth_Angle_vector = @Azimuth_Angle_vector;

      
end

function  Azimuth_Angle(root, satellite1_name, satellite2_name,starttime,endtime,timestep,pwd)
    % 输入验证
    if nargin < 3
        error('需要提供 root 对象和两个卫星名称。');
    end
        unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    projection_vector_name = [unique_name_prefix, '_Projection_Vector'];
    azimuth_angle_name = [unique_name_prefix, '_Azimuth'];
    
    
    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);
    
    % 获取两个卫星的中心点
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');
    
    % 获取卫星1的Body XY平面和Body X方向矢量
    satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');
    satellite1_bodyY_vector = satellite1.vgt.Vector.Item('Body.Y');
    
    % 创建从卫星1到卫星2的位移矢量
%     displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
%         'Displacement_Vector', center_satellite1, center_satellite2);
%     
        displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
       displacement_vector_name, center_satellite1, center_satellite2);
    
    
    
    % 创建位移矢量在卫星1 Body XY平面上的投影
%     displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
%         'Displacement_Vector_Projection', '', 'eCrdnVectorTypeProjection');
%     
       displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
        projection_vector_name, '', 'eCrdnVectorTypeProjection');
    
    
    displacement_vector_projection.Source.SetVector(displacement_vector);
    displacement_vector_projection.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    
    % 计算方位角（Azimuth）
   % azimuth_angle = satellite1.vgt.Angles.Factory.Create( 'Azimuth', '', 'eCrdnAngleTypeBetweenVectors'  );
     
        azimuth_angle = satellite1.vgt.Angles.Factory.Create(azimuth_angle_name, '', 'eCrdnAngleTypeBetweenVectors'  );

    azimuth_angle.FromVector.SetVector(satellite1_bodyY_vector);
    azimuth_angle.ToVector.SetVector(displacement_vector_projection);
 
    % 提示计算完成
    disp('方位角构建完成！');
    
  
     
    angleAZ = satellite1.DataProviders.Item('Angles').Group.Item(azimuth_angle_name).Exec(starttime,endtime,timestep);

    angleAZData_AngleRate  = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues;

    angleAZData_Time  = angleAZ.DataSets.GetDataSetByName('Time').GetValues;

    % 展开角速率数据（如数据在单元格中）
    AngleRate = cell2mat(angleAZData_AngleRate);
    % 创建表（table），保持时间为字符串格式

    data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'AngleRate'});

    % 将表写入到一个文本文件
    writetable(data_table, pwd, 'Delimiter', '\t');
    
    % and we need delete the vector
    
    % 检查是否存在目标矢量
        vectorName =displacement_vector_name;
        if satellite1.vgt.Vectors.Contains(vectorName)
            % 删除矢量
            satellite1.vgt.Vectors.Remove(vectorName);
            disp(['矢量 "', vectorName, '" 已成功删除。']);
        else
            disp(['矢量 "', vectorName, '" 不存在，无法删除。']);
        end

    
    
end
  

function  data_table=Azimuth_Angle_vector(root, satellite1_name, satellite2_name,starttime,endtime,timestep)
    % 输入验证
    if nargin < 3
        error('需要提供 root 对象和两个卫星名称。');
    end
        unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    projection_vector_name = [unique_name_prefix, '_Projection_Vector'];
    azimuth_angle_name = [unique_name_prefix, '_Azimuth'];
    
    
    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);
    
    % 获取两个卫星的中心点
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');
    
    % 获取卫星1的Body XY平面和Body X方向矢量
    satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');
    satellite1_bodyY_vector = satellite1.vgt.Vector.Item('Body.Y');
    
    % 创建从卫星1到卫星2的位移矢量
%     displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
%         'Displacement_Vector', center_satellite1, center_satellite2);
%     
        displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(...
       displacement_vector_name, center_satellite1, center_satellite2);
    
    
    
    % 创建位移矢量在卫星1 Body XY平面上的投影
%     displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
%         'Displacement_Vector_Projection', '', 'eCrdnVectorTypeProjection');
%     
       displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
        projection_vector_name, '', 'eCrdnVectorTypeProjection');
    
    
    displacement_vector_projection.Source.SetVector(displacement_vector);
    displacement_vector_projection.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    
    % 计算方位角（Azimuth）
   % azimuth_angle = satellite1.vgt.Angles.Factory.Create( 'Azimuth', '', 'eCrdnAngleTypeBetweenVectors'  );
     
        azimuth_angle = satellite1.vgt.Angles.Factory.Create(azimuth_angle_name, '', 'eCrdnAngleTypeBetweenVectors'  );

    azimuth_angle.FromVector.SetVector(satellite1_bodyY_vector);
    azimuth_angle.ToVector.SetVector(displacement_vector_projection);
 
    % 提示计算完成
    disp('方位角构建完成！');
    
  
     
    angleAZ = satellite1.DataProviders.Item('Angles').Group.Item(azimuth_angle_name).Exec(starttime,endtime,timestep);

    angleAZData_AngleRate  = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues;

    angleAZData_Time  = angleAZ.DataSets.GetDataSetByName('Time').GetValues;

    % 展开角速率数据（如数据在单元格中）
    AngleRate = cell2mat(angleAZData_AngleRate);
    % 创建表（table），保持时间为字符串格式

    data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'AngleRate'});

 
    % and we need delete the vector
    
    % 检查是否存在目标矢量
        vectorName =displacement_vector_name;
        if satellite1.vgt.Vectors.Contains(vectorName)
            
            % 删除矢量
            satellite1.vgt.Vectors.Remove(vectorName);
            disp(['矢量 "', vectorName, '" 已成功删除。']);
        else
            disp(['矢量 "', vectorName, '" 不存在，无法删除。']);
        end

    
    
end
  