function F = access_range
    F.cal_range = @cal_range;
   
end



function  cal_range(root, satellite1_name, satellite2_name,starttime,endtime,timestep,pwd)

  
    
    
    % ��ȡ���Ƕ���
    sat1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
    sat2 = root.GetObjectFromPath(['Satellite/' satellite2_name]);
    
    
    
 
% access = sat1.GetAccessToObject(sat2);   % ��ȡ���ʶ���
% access.ComputeAccess();                  % ���� Access
% dp = access.DataProviders.Item('AER Data');       % IAgDataProvider
%  
% Bodifixed = dp.Group.Item('BodyFixed')
%  
%  
% 
% lighting_start_time = Bodifixed.Exec(starttime, endtime, timestep);
% range = lighting_start_time.DataSets.GetDataSetByName('Range').GetValues;
%      
% Time  = lighting_start_time.DataSets.GetDataSetByName('Time').GetValues;
% 
%     % չ�����������ݣ��������ڵ�Ԫ���У�
%     range_data = cell2mat(range);
%     % ������table��������ʱ��Ϊ�ַ�����ʽ
% 
%     data_table = table(Time, range_data, 'VariableNames', {'Time', 'Range'});
% 
%    
%     
%  
    
    
    
    
    % ��ȡ Access ����
access = sat1.GetAccessToObject(sat2);
access.ComputeAccess();

% ��ȡ Access ʱ���
interval_dp = access.DataProviders.Item('Access Data')
intervals = interval_dp.Exec(starttime, endtime);

% AER Data��BodyFixed���ӿ�
aer_dp = access.DataProviders.Item('AER Data');
Bodifixed = aer_dp.Group.Item('BodyFixed');

startTimes = intervals.DataSets.GetDataSetByName('Start Time').GetValues;
stopTimes  = intervals.DataSets.GetDataSetByName('Stop Time').GetValues;

all_range = [];
all_time  = [];

for i = 1:numel(startTimes)
    res = Bodifixed.Exec(startTimes{i}, stopTimes{i}, timestep);
    all_range = [all_range; res.DataSets.GetDataSetByName('Range').GetValues];
    all_time  = [all_time;  res.DataSets.GetDataSetByName('Time').GetValues];
end

    data_table = table(all_time, all_range, 'VariableNames', {'Time', 'Range'});

    % ����д�뵽һ���ı��ļ�
    writetable(data_table, pwd, 'Delimiter', '\t');
    
    
end
  