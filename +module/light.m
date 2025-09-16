function F = light
    F.light = @light;
   
end

function light(root, sats1, starttime, endtime, timestep, file_path)
    % ������֤
    if nargin < 6
        error('�����ṩ root, ��������, ��ֹʱ��, ʱ�䲽�����ļ�·��.');
    end
    if nargin < 7
        line = false; % Ĭ�ϲ��ض�����
    end

    % ��ȡ���Ƕ���
    satellite1 = root.GetObjectFromPath(['Satellite/' sats1]);
    
    % sunlight
 
    lighting_data_provider = satellite1.DataProviders.Item('Lighting Times').Group.Item('Sunlight')
t = {'Start Time'}
        
        % ��ȡ Lighting Times ����
lighting_start_time = lighting_data_provider.ExecElements( starttime, endtime,t);

lighting_start_time = lighting_start_time.DataSets.GetDataSetByName('Start Time').GetValues;


 
t = {'Stop Time'}
        
        % ��ȡ Lighting Times ����
lighting_stop_time = lighting_data_provider.ExecElements( starttime, endtime,t);

lighting_stop_time = lighting_stop_time.DataSets.GetDataSetByName('Stop Time').GetValues;
 



%


  
end
