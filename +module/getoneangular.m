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
x = cell2mat(AB_vector_data_x); % 将 {[627.3107]} 转换为 [627.3107; ...]
y = cell2mat(AB_vector_data_y);
z = cell2mat(AB_vector_data_z);
AB_vector_data_vector = [x, y, z]; % 得到 N×3 的矩阵，每行代表一个向量 [x, y, z]


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
  
 x = cell2mat(AB_vector_D_data_x); % 将 {[627.3107]} 转换为 [627.3107; ...]
y = cell2mat(AB_vector_D_data_y);
z = cell2mat(AB_vector_D_data_z);

 AB_vector_D_data_vector =  [x, y, z];

% 计算叉乘
cross_product = cross(AB_vector_data_vector, AB_vector_D_data_vector, 2);

% 计算模长平方
r_norm_sq = sum(AB_vector_data_vector.^2, 2);

% 处理极小值
epsilon = 1e-10;
r_norm_sq = max(r_norm_sq, epsilon);

% 计算角速度
omega = cross_product ./ r_norm_sq;
% 定义弧度到角度的转换因子
rad2deg = 180 / pi;

% 将整个矩阵转换为度/秒
omega_deg_per_sec = omega * rad2deg;

% 将时间单元格数组转换为字符串向量
time_str = cellfun(@(x) char(x), AB_vector_D_data_Time, 'UniformOutput', false);
time_str = string(time_str); % 转换为字符串数组

omega_x = omega_deg_per_sec(:,1);
omega_y = omega_deg_per_sec(:,2);
omega_z = omega_deg_per_sec(:,3);


% 创建表格
result_table = table(...
    time_str, omega_x, omega_y, omega_z, ...
    'VariableNames', {'Time', 'Omega_X_deg_s', 'Omega_Y_deg_s', 'Omega_Z_deg_s'});
%folder = "C:\usrspace\stkfile\angularvelocity"; % 或使用正斜杠避免转义
%filename = "text.txt";

% 合并路径
 

% 写入表格
writetable(result_table, filepath, 'Delimiter', '\t');
 vectorName ='AB_vector';
    if QF0101.vgt.Vectors.Contains(vectorName)
        % 删除矢量
        QF0101.vgt.Vectors.Remove(vectorName);
        disp(['矢量 "', vectorName, '" 已成功删除。']);
    else
        disp(['矢量 "', vectorName, '" 不存在，无法删除。']);
    end

 
end
