function F = task_linshi_code
    F.cal = @cal;
   
end



function  cal(root, scenario,sats1, sats2,folder_base,FILENAME,timestep)

 

% ƴ��Ŀ���ļ���·��
folder_target = fullfile(folder_base, FILENAME);

% �����ļ��У���������ڣ�
if ~isfolder(folder_target)
    mkdir(folder_target);
end

% �����ļ�·��
filepath1 = fullfile(folder_target, "angular_velocity.txt");
filepath2 = fullfile(folder_target, "s1_position.txt");
filepath3 = fullfile(folder_target, "s2_position.txt");
filepath4 = fullfile(folder_target, "s1_lighttime.txt");
filepath5 = fullfile(folder_target, "s2_lighttime.txt");
filepath6 = fullfile(folder_target, "range.txt");
position = module.Get_Position()
position.GetPositionxyz(root, sats1,scenario.StartTime,scenario.StopTime,timestep,filepath2)
position.GetPositionxyz(root, sats2,scenario.StartTime,scenario.StopTime,timestep,filepath3)

angular = module.stk_angular_velocity()
angular.GetAngularVelocity(root, sats1, sats2, scenario.StartTime, scenario.StopTime, timestep,filepath1);


 
cmd = sprintf([ ...
    'ReportCreate */Satellite/%s ' ...
    'Type Save ' ...  % <-- ǰ��Ҫ�ո�
    'Style "Installed Styles/Lighting Times" ' ...
    'File "%s" ' ...
    'TimePeriod "%s" "%s"'], ...
    sats1, filepath4,scenario.StartTime, scenario.StopTime);

root.ExecuteCommand(cmd);                         % ����ֱ��д�� CSV

cmd = sprintf([ ...
    'ReportCreate */Satellite/%s ' ...
    'Type Save ' ...  % <-- ǰ��Ҫ�ո�
    'Style "Installed Styles/Lighting Times" ' ...
    'File "%s" ' ...
    'TimePeriod "%s" "%s"'], ...
    sats2, filepath5,scenario.StartTime, scenario.StopTime );

root.ExecuteCommand(cmd);                         % ����ֱ��д�� CSV



acess  = module.access_range()
acess.cal_range(root, sats1, sats2,scenario.StartTime,scenario.StopTime,timestep,filepath6)

    
    
end
  