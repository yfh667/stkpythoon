 


function F = stk_angular_velocity
    F.GetAzimuth = @GetAzimuth;
    F.GetPitch = @GetPitch;
    F.GetAngularVelocity = @GetAngularVelocity;
end

% 获取方位角（Azimuth）速度
function data_table = GetAzimuth(root, satellite1_name, satellite2_name, starttime, endtime, timestep)
    % 输入验证
    if nargin < 3
        error('需要提供 root 对象和两个卫星名称。');
    end
    
    % 唯一前缀
    unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    azimuth_angle_name = [unique_name_prefix, '_Azimuth'];
projection_vector_name =  [unique_name_prefix, '_Projection_Vector'];
    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);

    % 获取卫星中心点
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');

    % 创建位移矢量（只创建一次）
    displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(displacement_vector_name, center_satellite1, center_satellite2);
    
    % 获取卫星1的Body Y向量（用于计算方位角）
    satellite1_bodyY_vector = satellite1.vgt.Vector.Item('Body.Y');
        satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');
        
    %创建投影向量
        displacement_vector_projection = satellite1.vgt.Vectors.Factory.Create(...
        projection_vector_name, '', 'eCrdnVectorTypeProjection');

    
    displacement_vector_projection.Source.SetVector(displacement_vector);
    displacement_vector_projection.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    

    % 创建方位角对象
    azimuth_angle = satellite1.vgt.Angles.Factory.Create(azimuth_angle_name, '', 'eCrdnAngleTypeBetweenVectors');
    azimuth_angle.FromVector.SetVector(satellite1_bodyY_vector);
    azimuth_angle.ToVector.SetVector(displacement_vector_projection);

    % 提示计算完成
    disp('方位角构建完成！');

    % 获取方位角数据并计算角速度
    angleAZ = satellite1.DataProviders.Item('Angles').Group.Item(azimuth_angle_name).Exec(starttime, endtime, timestep);
    angleAZData_AngleRate = angleAZ.DataSets.GetDataSetByName('AngleRate').GetValues;
    angleAZData_Time = angleAZ.DataSets.GetDataSetByName('Time').GetValues;

    % 展开角速率数据
    AngleRate = cell2mat(angleAZData_AngleRate);

    % 创建表格
    data_table = table(angleAZData_Time, AngleRate, 'VariableNames', {'Time', 'Azimuth_AngleRate'});

    % 删除矢量（清理工作）
    if satellite1.vgt.Vectors.Contains(displacement_vector_name)
        satellite1.vgt.Vectors.Remove(displacement_vector_name);
        disp(['矢量 "', displacement_vector_name, '" 已成功删除。']);
    else
        disp(['矢量 "', displacement_vector_name, '" 不存在，无法删除。']);
    end
end

% 获取俯仰角（Pitch）速度
function data_table = GetPitch(root, satellite1_name, satellite2_name, starttime, endtime, timestep)
    % 输入验证
    if nargin < 3
        error('需要提供 root 对象和两个卫星名称。');
    end
    
    % 唯一前缀
    unique_name_prefix = [satellite1_name, '_', satellite2_name];
    displacement_vector_name = [unique_name_prefix, '_Displacement_Vector'];
    pitch_angle_name = [unique_name_prefix, '_Pitch'];

    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    satellite2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);

    % 获取卫星中心点
    center_satellite1 = satellite1.vgt.Points.Item('Center');
    center_satellite2 = satellite2.vgt.Points.Item('Center');

    % 创建位移矢量（只创建一次）
    displacement_vector = satellite1.vgt.Vectors.Factory.CreateDisplacementVector(displacement_vector_name, center_satellite1, center_satellite2);

    % 获取卫星1的Body XY平面（用于计算俯仰角）
    satellite1_bodyXY_plane = satellite1.vgt.Plane.Item('Body.XY');

    % 创建俯仰角对象
    pitch_angle = satellite1.vgt.Angles.Factory.Create(pitch_angle_name, '', 'eCrdnAngleTypeToPlane');
    pitch_angle.ReferencePlane.SetPlane(satellite1_bodyXY_plane);
    pitch_angle.ReferenceVector.SetVector(displacement_vector);

    % 提示计算完成
    disp('俯仰角构建完成！');

    % 获取俯仰角数据并计算角速度
    anglePit = satellite1.DataProviders.Item('Angles').Group.Item(pitch_angle_name).Exec(starttime, endtime, timestep);
    anglePitData_AngleRate = anglePit.DataSets.GetDataSetByName('AngleRate').GetValues;
    anglePitData_Time = anglePit.DataSets.GetDataSetByName('Time').GetValues;

    % 展开角速率数据
    AngleRate = cell2mat(anglePitData_AngleRate);

    % 创建表格
    data_table = table(anglePitData_Time, AngleRate, 'VariableNames', {'Time', 'Pitch_AngleRate'});

    % 删除矢量（清理工作）
    if satellite1.vgt.Vectors.Contains(displacement_vector_name)
        satellite1.vgt.Vectors.Remove(displacement_vector_name);
        disp(['矢量 "', displacement_vector_name, '" 已成功删除。']);
    else
        disp(['矢量 "', displacement_vector_name, '" 不存在，无法删除。']);
    end
end




function data_table = GetAngularVelocity(root, satellite1_name, satellite2_name, starttime, endtime, timestep, pwd)
    % 输入验证
    if nargin < 3
        error('需要提供 root 对象和两个卫星名称。');
    end
    
    % 获取方位角数据（Azimuth）
    Az = GetAzimuth(root, satellite1_name, satellite2_name, starttime, endtime, timestep);
    
    % 获取俯仰角数据（Pitch）
    Pit = GetPitch(root, satellite1_name, satellite2_name, starttime, endtime, timestep);
    
    % 提取 Azimuth 和 Pitch 的时间和角度数据
    Az_Time = Az.Time;
    Az_AngleRate = Az.Azimuth_AngleRate;
    
    Pit_Time = Pit.Time;
    Pit_AngleRate = Pit.Pitch_AngleRate;
    
    % 确保时间对齐（取共同时间点的交集）
    [common_time, Az_idx, Pit_idx] = intersect(Az_Time, Pit_Time);  % 找到共同的时间点
    
    % 从 Az 和 Pit 中提取对齐后的角度数据
    Az_AngleRate_Common = Az_AngleRate(Az_idx);
    Pit_AngleRate_Common = Pit_AngleRate(Pit_idx);
    
    % 创建合并的表格
    data_table = table(common_time, Az_AngleRate_Common, Pit_AngleRate_Common, ...
        'VariableNames', {'Time', 'Azimuth_AngleRate_deg', 'Pitch_AngleRate_deg'});
    
    % 将表格写入到文件
    writetable(data_table, pwd, 'Delimiter', '\t');
    
    % 提示文件已保存
    disp(['数据已保存到文件: ', pwd]);
end


