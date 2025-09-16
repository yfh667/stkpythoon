function F = SensorModule
    F.SensorModule = @SensorModule;
    F.CreateSatSensor  = @CreateSatSensor;
    F.CreateGndSensor  = @CreateGndSensor;
    F.LosCalculate = @LosCalculate;
    
    
end


function  LosCalculate(root, satelliteName, facilityName,startTimes,stopTimes, filepath)

% 1. 获取对象
% satelliteName = 'QF_02_01';
% facilityName = 'Facility1';
satellite = root.GetObjectFromPath(['Satellite/' satelliteName]);
facility = root.GetObjectFromPath(['Facility/' facilityName]);
% 2. 获取传感器对象
satelliteSensor = satellite.Children.Item(satelliteName); % 获取卫星的传感器
facilitySensor = facility.Children.Item(facilityName); % 获取地面站的传感器
% 3. 创建访问分析
access = satelliteSensor.GetAccessToObject(facilitySensor);

% 4. 计算访问
access.ComputeAccess();


% 5. 获取访问结果
results = access.DataProviders.Item('Access Data');

% 6. 提取访问时间段
% startTimes =scenario.StartTime;
% stopTimes =scenario.StopTime;
resInfo = results.Exec(startTimes, stopTimes);


 % 假设 resInfo 是 Access 结果对象
try
    % 检查 DataSets 是否包含 'Start Time'
    if ~isempty(resInfo.DataSets.GetDataSetByName('Start Time'))
        % 获取开始和结束时间

            Access_Start_Time  = resInfo.DataSets.GetDataSetByName('Start Time').GetValues;

            Access_Stop_Time  = resInfo.DataSets.GetDataSetByName('Stop Time').GetValues;
            %Access_Duration_Time  = resInfo.DataSets.GetDataSetByName('Duration').GetValues;

            % 初始化普通数组存储合并结果
            access_time = strings(length(Access_Start_Time), 2);

            % 循环合并开始和结束时间
            for i = 1:length(Access_Start_Time)
                access_time(i, 1) = Access_Start_Time{i}; % 开始时间
                access_time(i, 2) = Access_Stop_Time{i}; % 结束时间
            end

            access_time
 
            % 将字符串数组转换为表格
            access_time_table = array2table(access_time, ...
                'VariableNames', {'Start_Time', 'Stop_Time'}); % 添加列标题
            % 定义保存路径
            % filepath = 'C:\usrspace\stkfile\sats\access_time.txt';
            disp('Access time dimensions:');
        disp(size(access_time));
            % 保存表格到文件
            disp('Before displaying fullFilePath...');

        %    fullFilePath = filepath + satelliteName + "to" + facilityName + ".txt"
fullFilePath = strcat(filepath, '\',satelliteName, 'to', facilityName, '.txt')    ;        
            disp(fullFilePath);

             disp(fullFilePath)
             % 检查维度


             writetable(access_time_table, fullFilePath, 'Delimiter', '\t');

            disp(['数据已保存到文件：', filepath]);

 
    else
        disp('No Access times found.');
    end
    
    catch ME
        % 捕获可能的错误并输出消息
        disp('No accesss :');
       disp(ME.message);
end




end


function CreateSatSensor(root,name,angle)
% 3. 为卫星添加传感器
%name  =  'QF_02_01'
satellite = root.GetObjectFromPath(['Satellite/' name]);
sensor = satellite.Children.New('eSensor',name); % 创建传感器
%设置角度为
sensor.CommonTasks.SetPatternSimpleConic(angle, 0.1)

end

function CreateGndSensor(root,facilityName,angle)
% 3. 为卫星添加传感器
%name  =  'QF_02_01'
 

facilityName = 'Facility1';
facility = root.GetObjectFromPath(['Facility/' facilityName]);
sensor = facility.Children.New('eSensor',facilityName); % 创建传感器
%设置角度为
sensor.CommonTasks.SetPatternSimpleConic(angle, 0.1)


end
