function F = GetPosition
    F.GetPosition = @GetPosition;
      F.GetPositionxyz = @GetPositionxyz;
            F.GetPositionxyz_Station_Fixed = @GetPositionxyz_Station_Fixed;
 
      
end
function GetPositionxyz(root, satellite1_name, starttime, endtime, timestep, file_path, line)
    % 输入验证
    if nargin < 6
        error('必须提供 root, 卫星名称, 起止时间, 时间步长和文件路径.');
    end
    if nargin < 7
        line = false; % 默认不截断数据
    end

    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    
    % 查询位置数据
   % position = satellite1.DataProviders.Item('Vectors(J2000)').Group.Item('Position').Exec(starttime, endtime, timestep);
     %   position = satellite1.DataProviders.Item('Vectors(J2000)').Group.Item('Position').Exec(starttime, endtime, timestep);
        position = satellite1.DataProviders.Item('Vectors(Fixed)').Group.Item('Position').Exec(starttime, endtime, timestep);

    % 提取数据列（确保为列向量）
    position_x = position.DataSets.GetDataSetByName('x').GetValues;
    position_y = position.DataSets.GetDataSetByName('y').GetValues;
    position_z = position.DataSets.GetDataSetByName('z').GetValues;
    position_time = position.DataSets.GetDataSetByName('Time').GetValues;
    
    % 确保数据为列向量（若返回元胞数组则转换）
    if iscell(position_time)
        position_time = cell2mat(position_time);
        position_x = cell2mat(position_x);
        position_y = cell2mat(position_y);
        position_z = cell2mat(position_z);
    end
    
    % 创建表格
    data_table = table(position_time, position_x, position_y, position_z, ...
        'VariableNames', {'Time', 'x', 'y', 'z'});
    
    % 处理数据截断
    if line
        if height(data_table) >= line
            selected_data = data_table(1:line, :);
            writetable(selected_data, file_path, 'Delimiter', '\t');
        else
            error('数据不足2000行，当前行数：%d', height(data_table));
        end
    else
        writetable(data_table, file_path, 'Delimiter', '\t');
    end
end


function GetPositionxyz_Station_Fixed(root, station_name, starttime, endtime, timestep, file_path)
    % 获取对象
try
    % 尝试作为 Facility 获取
    obj = root.GetObjectFromPath(['Facility/' station_name]);
catch
    try
        % 如果失败，尝试作为 Place 获取
        obj = root.GetObjectFromPath(['Place/' station_name]);
    catch
        error('无法找到名为 %s 的对象，请检查对象类型是否为 Facility 或 Place', station_name);
    end
end

    % --- 查询位置数据 (Fixed) ---
    % 地固系下，地面站坐标是恒定的
    dataProvider = obj.DataProviders.Item('Vectors(Fixed)').Group.Item('Position');
    
    % 只需要取一个时间点即可，因为它是固定的
    result = dataProvider.Exec(starttime, starttime, timestep); 
% 提取原始数据（STK 默认通常是 km）
    x_raw = result.DataSets.GetDataSetByName('x').GetValues;
    y_raw = result.DataSets.GetDataSetByName('y').GetValues;
    z_raw = result.DataSets.GetDataSetByName('z').GetValues;
    t_raw = result.DataSets.GetDataSetByName('Time').GetValues;
% 1. 转换数值并统一单位为“米”(m)
    % 使用 cell2mat 确保转换为 double 矩阵，然后乘以 1000
    if iscell(x_raw)
        x = cell2mat(x_raw) * 1000;
        y = cell2mat(y_raw) * 1000;
        z = cell2mat(z_raw) * 1000;
    else
        x = x_raw * 1000;
        y = y_raw * 1000;
        z = z_raw * 1000;
    end

    % 2. 处理时间格式
    % 时间通常返回的是字符串元胞，存入 table 时建议保持 cell 或转为 string
    if iscell(t_raw)
        t = string(t_raw); 
    else
        t = t_raw;
    end
    
    % 创建表格
data_table = table( x, y, z);
writetable(data_table, file_path, 'Delimiter', '\t', 'WriteVariableNames', false);
end

