function F = light
    F.light = @light;
   
end

function light(root, sats1, starttime, endtime, timestep, file_path)
    % 输入验证
    if nargin < 6
        error('必须提供 root, 卫星名称, 起止时间, 时间步长和文件路径.');
    end
    if nargin < 7
        line = false; % 默认不截断数据
    end

    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' sats1]);
    
    % sunlight
 
    lighting_data_provider = satellite1.DataProviders.Item('Lighting Times').Group.Item('Sunlight')
t = {'Start Time'}
        
        % 获取 Lighting Times 数据
lighting_start_time = lighting_data_provider.ExecElements( starttime, endtime,t);

lighting_start_time = lighting_start_time.DataSets.GetDataSetByName('Start Time').GetValues;


 
t = {'Stop Time'}
        
        % 获取 Lighting Times 数据
lighting_stop_time = lighting_data_provider.ExecElements( starttime, endtime,t);

lighting_stop_time = lighting_stop_time.DataSets.GetDataSetByName('Stop Time').GetValues;
 



%


  
end
