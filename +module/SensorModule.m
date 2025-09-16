function F = SensorModule
    F.SensorModule = @SensorModule;
    F.CreateSatSensor  = @CreateSatSensor;
    F.CreateGndSensor  = @CreateGndSensor;
    F.LosCalculate = @LosCalculate;
    
    
end


function  LosCalculate(root, satelliteName, facilityName,startTimes,stopTimes, filepath)

% 1. ��ȡ����
% satelliteName = 'QF_02_01';
% facilityName = 'Facility1';
satellite = root.GetObjectFromPath(['Satellite/' satelliteName]);
facility = root.GetObjectFromPath(['Facility/' facilityName]);
% 2. ��ȡ����������
satelliteSensor = satellite.Children.Item(satelliteName); % ��ȡ���ǵĴ�����
facilitySensor = facility.Children.Item(facilityName); % ��ȡ����վ�Ĵ�����
% 3. �������ʷ���
access = satelliteSensor.GetAccessToObject(facilitySensor);

% 4. �������
access.ComputeAccess();


% 5. ��ȡ���ʽ��
results = access.DataProviders.Item('Access Data');

% 6. ��ȡ����ʱ���
% startTimes =scenario.StartTime;
% stopTimes =scenario.StopTime;
resInfo = results.Exec(startTimes, stopTimes);


 % ���� resInfo �� Access �������
try
    % ��� DataSets �Ƿ���� 'Start Time'
    if ~isempty(resInfo.DataSets.GetDataSetByName('Start Time'))
        % ��ȡ��ʼ�ͽ���ʱ��

            Access_Start_Time  = resInfo.DataSets.GetDataSetByName('Start Time').GetValues;

            Access_Stop_Time  = resInfo.DataSets.GetDataSetByName('Stop Time').GetValues;
            %Access_Duration_Time  = resInfo.DataSets.GetDataSetByName('Duration').GetValues;

            % ��ʼ����ͨ����洢�ϲ����
            access_time = strings(length(Access_Start_Time), 2);

            % ѭ���ϲ���ʼ�ͽ���ʱ��
            for i = 1:length(Access_Start_Time)
                access_time(i, 1) = Access_Start_Time{i}; % ��ʼʱ��
                access_time(i, 2) = Access_Stop_Time{i}; % ����ʱ��
            end

            access_time
 
            % ���ַ�������ת��Ϊ���
            access_time_table = array2table(access_time, ...
                'VariableNames', {'Start_Time', 'Stop_Time'}); % ����б���
            % ���屣��·��
            % filepath = 'C:\usrspace\stkfile\sats\access_time.txt';
            disp('Access time dimensions:');
        disp(size(access_time));
            % �������ļ�
            disp('Before displaying fullFilePath...');

        %    fullFilePath = filepath + satelliteName + "to" + facilityName + ".txt"
fullFilePath = strcat(filepath, '\',satelliteName, 'to', facilityName, '.txt')    ;        
            disp(fullFilePath);

             disp(fullFilePath)
             % ���ά��


             writetable(access_time_table, fullFilePath, 'Delimiter', '\t');

            disp(['�����ѱ��浽�ļ���', filepath]);

 
    else
        disp('No Access times found.');
    end
    
    catch ME
        % ������ܵĴ��������Ϣ
        disp('No accesss :');
       disp(ME.message);
end




end


function CreateSatSensor(root,name,angle)
% 3. Ϊ������Ӵ�����
%name  =  'QF_02_01'
satellite = root.GetObjectFromPath(['Satellite/' name]);
sensor = satellite.Children.New('eSensor',name); % ����������
%���ýǶ�Ϊ
sensor.CommonTasks.SetPatternSimpleConic(angle, 0.1)

end

function CreateGndSensor(root,facilityName,angle)
% 3. Ϊ������Ӵ�����
%name  =  'QF_02_01'
 

facilityName = 'Facility1';
facility = root.GetObjectFromPath(['Facility/' facilityName]);
sensor = facility.Children.New('eSensor',facilityName); % ����������
%���ýǶ�Ϊ
sensor.CommonTasks.SetPatternSimpleConic(angle, 0.1)


end
