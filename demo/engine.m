STKXApplication = actxserver('STKX11.application');
root = actxserver('AgStkObjects11.AgStkObjectRoot');

scenario = root.Children.New('eScenario','MATLAB_PredatorMission');
scenario.SetTimePeriod('24 Feb 2012 16:00:00.000','25 Feb 2012 16:00:00.000');
scenario.StartTime = '24 Feb 2012 16:00:00.000';
scenario.StopTime = '25 Feb 2012 16:00:00.000';
root.ExecuteCommand('Animate * Reset');

facility = scenario.Children.New('eFacility','GroundStation');
facility.Position.AssignGeodetic(36.1457,-114.5946,0);

% �������ǲ���
params = struct();
params.satelliteName = 'Satellite1';
params.perigeeAlt = 35788.1;
params.apogeeAlt = 35788.1;
params.inclination = 0;
params.argOfPerigee = 0;
params.ascNodeValue = 245;
params.locationValue = 180;
sat().createSatellite(root, scenario, params);

% 
% 
% satellite = scenario.Children.New('eSatellite','Satellite1');
% keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');   
% keplerian.SizeShapeType = 'eSizeShapeAltitude';
% 
% 
% keplerian.LocationType = 'eLocationTrueAnomaly';
% keplerian.Orientation.AscNodeType = 'eAscNodeLAN';
% 
% 
% keplerian.SizeShape.PerigeeAltitude = 35788.1;
% keplerian.SizeShape.ApogeeAltitude = 35788.1;
% keplerian.Orientation.Inclination = 0;
% keplerian.Orientation.ArgOfPerigee = 0;
% keplerian.Orientation.AscNode.Value = 245;
% keplerian.Location.Value = 180;
% satellite.Propagator.InitialState.Representation.Assign(keplerian);
% satellite.Propagator.Propagate;



% �������
satellite_name = 'Satellite1';
report_style = 'fixed';  % ʹ����Ч�ı�����ʽ
file_path = 'E:/STK_file/stations/test.txt';  % ʹ����б��
start_time = '24 Feb 2012 16:00:00.000';
stop_time = '25 Feb 2012 16:00:00.000';
time_step = 60;

% ȷ��Ŀ¼����
folder_path = 'E:/STK_file/stations';
if ~exist(folder_path, 'dir')
    mkdir(folder_path);
end

% ���������ַ���
command = ['ReportCreate */Satellite/' satellite_name ...
    ' Type Save' ...
    ' Style "' report_style '"' ...
    ' File "' file_path '"' ...
    ' TimePeriod "' start_time '" "' stop_time '"' ...
    ' TimeStep ' num2str(time_step)];

% ��ӡ�����Լ��
disp('ִ�е����');
disp(command);

% ִ������������
try
    root.ExecuteCommand(command);
    disp('�����ѳɹ����ɡ�');
catch ME
    disp('ִ������ʱ��������');
    disp(ME.message);
end


%------% �ر�engine
% 1. �ͷŸ�����AgStkObjectRoot��
delete(root);
clear root;
% 3. �ͷ� STKXApplication ����
delete(STKXApplication);
clear STKXApplication;

