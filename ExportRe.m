%% Call ALL Function
function F = ExportRe
    F.RePort = @RePort;
  F.MultilRePort = @MultilRePort;
end
function RePort(root,  type, name,params)
    % ����ָ������ı��沢���浽ָ���ļ�
    % ������
    %   - root: STK �ĸ�����AgStkObjectRoot��
    %   - name: ��������
    %   - type: �������ͣ��ַ��������� 'Satellite'��'Facility' ��
    %   - params: ������������Ľṹ�壬������������ֶΣ�
    %       - reportStyle: ������ʽ����
    %       - filePath: �����ļ��ı���·��
    %       - startTime: ����Ŀ�ʼʱ�䣬��ʽΪ 'DD MMM YYYY HH:MM:SS.SSS'
    %       - stopTime: ����Ľ���ʱ�䣬��ʽͬ��
    %       - timeStep: ʱ�䲽������λΪ��

    % ������֤
    requiredFields = {'reportStyle', 'filePath', 'startTime', 'stopTime', 'timeStep'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('�����ṹ��ȱ�ٱ�����ֶΣ�%s', requiredFields{i});
        end
    end

    % �Ӳ����ṹ���л�ȡ����
    object_name = name;
    report_style = params.reportStyle;
    file_path = params.filePath;
    start_time = params.startTime;
    stop_time = params.stopTime;
    time_step = params.timeStep;

    if ~exist(file_path, 'dir')
        mkdir(file_path);
    end

    % Ϊ�ļ�����·�������ļ�����·������
    full_file_path = fullfile(file_path, [object_name, '.txt']);

    % ���������ַ�����ʹ�ñ��� 'type'
    command = ['ReportCreate */' type '/' object_name ...
        ' Type Save' ...
        ' Style "' report_style '"' ...
        ' File "' full_file_path '"' ...
        ' TimePeriod "' start_time '" "' stop_time '"' ...
        ' TimeStep ' num2str(time_step)];

    % ��ӡ�����Լ��
    disp('ִ�е����');
    disp(command);

    % ִ������������
    try
        root.ExecuteCommand(command);
        disp(['�����ѳɹ����ɣ�', full_file_path]);
    catch ME
        disp('ִ������ʱ��������');
        disp(ME.message);
    end
end


function MultilRePort(root, type, names, params)
    % ����ָ������ı��沢���浽ָ���ļ�
    %
    % ������
    %   - root: STK �ĸ�����AgStkObjectRoot��
    %   - type: �������ͣ��ַ��������� 'Satellite'��'Facility' ��
    %   - names: ��������������Ƶĵ�Ԫ����
    %   - params: ������������Ľṹ�壬������������ֶΣ�
    %       - reportStyle: ������ʽ����
    %       - filePath: �����ļ��ı���·��
    %       - startTime: ����Ŀ�ʼʱ�䣬��ʽΪ 'DD MMM YYYY HH:MM:SS.SSS'
    %       - stopTime: ����Ľ���ʱ�䣬��ʽͬ��
    %       - timeStep: ʱ�䲽������λΪ��

    % ������֤
    requiredFields = {'reportStyle', 'filePath', 'startTime', 'stopTime', 'timeStep'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('�����ṹ��ȱ�ٱ�����ֶΣ�%s', requiredFields{i});
        end
    end

    % �Ӳ����ṹ���л�ȡ����
    report_style = params.reportStyle;
    file_path = params.filePath;
    start_time = params.startTime;
    stop_time = params.stopTime;
    time_step = params.timeStep;
    file_path

    % ȷ��Ŀ¼����

    if ~exist(file_path, 'dir')
        mkdir(file_path);
    end

    % ���������б�
    for i = 1:length(names)
        object_name = names{i};  % ��ȡ��ǰ�Ķ�������
    RePort(root, type, object_name, params)
 
    end
end



