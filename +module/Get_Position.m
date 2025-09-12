function F = GetPosition
    F.GetPosition = @GetPosition;
      F.GetPositionxyz = @GetPositionxyz;
end
function GetPositionxyz(root, satellite1_name, starttime, endtime, timestep, file_path, line)
    % ������֤
    if nargin < 6
        error('�����ṩ root, ��������, ��ֹʱ��, ʱ�䲽�����ļ�·��.');
    end
    if nargin < 7
        line = false; % Ĭ�ϲ��ض�����
    end

    % ��ȡ���Ƕ���
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    
    % ��ѯλ������
   % position = satellite1.DataProviders.Item('Vectors(J2000)').Group.Item('Position').Exec(starttime, endtime, timestep);
     %   position = satellite1.DataProviders.Item('Vectors(J2000)').Group.Item('Position').Exec(starttime, endtime, timestep);
        position = satellite1.DataProviders.Item('Vectors(Fixed)').Group.Item('Position').Exec(starttime, endtime, timestep);

    % ��ȡ�����У�ȷ��Ϊ��������
    position_x = position.DataSets.GetDataSetByName('x').GetValues;
    position_y = position.DataSets.GetDataSetByName('y').GetValues;
    position_z = position.DataSets.GetDataSetByName('z').GetValues;
    position_time = position.DataSets.GetDataSetByName('Time').GetValues;
    
    % ȷ������Ϊ��������������Ԫ��������ת����
    if iscell(position_time)
        position_time = cell2mat(position_time);
        position_x = cell2mat(position_x);
        position_y = cell2mat(position_y);
        position_z = cell2mat(position_z);
    end
    
    % �������
    data_table = table(position_time, position_x, position_y, position_z, ...
        'VariableNames', {'Time', 'x', 'y', 'z'});
    
    % �������ݽض�
    if line
        if height(data_table) >= line
            selected_data = data_table(1:line, :);
            writetable(selected_data, file_path, 'Delimiter', '\t');
        else
            error('���ݲ���2000�У���ǰ������%d', height(data_table));
        end
    else
        writetable(data_table, file_path, 'Delimiter', '\t');
    end
end

