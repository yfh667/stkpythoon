function F = GetPosition
    F.GetPosition = @GetPosition;
      F.GetPositionxyz = @GetPositionxyz;
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
    position = satellite1.DataProviders.Item('Vectors(ICRF)').Group.Item('Position').Exec(starttime, endtime, timestep);
    
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

