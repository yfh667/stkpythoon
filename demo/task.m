%����Ϊ���Դ��룬����
% �����Ƿ�ʹ�� STK Engine
USE_ENGINE = 0;

% ��ʼ�� STK
if USE_ENGINE
    % ��ʼ�� STK Engine
    app = actxserver('STKX11.application');
    root = actxserver('AgStkObjects11.AgStkObjectRoot');
else
    % ��ʼ�� STK Ӧ�ó���
    app = actxserver('STK11.application');
    root = app.Personality2; 
end
%����senario��ʱ��
StartTime  =  '1 Jan 2025 06:00:00.000';
StopTime =  '2 Jan 2025 06:00:00.000';
scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod(StartTime,StopTime);
scenario.StartTime = StartTime;
scenario.StopTime = StopTime;

if USE_ENGINE
    % �� USE_ENGINE Ϊ true �������ִ�е��߼�
    % �������߼�����
else
    % �� USE_ENGINE Ϊ false ʱ��ִ�и�λ��������
    try
        root.ExecuteCommand('Animate * Reset');
        disp('�����Ѹ�λ�ɹ�');
    catch ME
        disp('������λʧ��:');
        disp(ME.message);
    end
end

folder_base = "C:\usrspace\stkfile\task3";

timestep = 1
sats1 = 'C1_2101';
sats2 = 'C4_1101';
% �������·����������

FILENAME = "C1_C4"; % ����FILENAME���ַ�������
task=module.task_linshi_code()
task.cal(root,scenario, sats1, sats2,folder_base,FILENAME,timestep)
