%% Call ALL Function
function F = ExportRe
    F.RePort = @RePort;
  F.MultilRePort = @MultilRePort;
    F.ModifyReport = @ModifyReport;
  F.MultiModifyReport = @MultiModifyReport;
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


function MultiModifyReport(type, path)
    % ���ʹ�����Ŀ¼
    savePath = fullfile(path, 'modify');
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
    % ��ȡָ��·��������ָ�����͵��ļ�
    files = dir(fullfile(path, ['*.', txt]));
    
end



function ModifyReport(input_file,output_file)
     % �����������ļ�
     
     
    fin = fopen(input_file, 'r');
    fout = fopen(output_file, 'w');

    % ��ȡ�����ļ���һ��cell������
    data_lines = textscan(fin, '%s', 'Delimiter', '\n');
    data_lines = data_lines{1};
    fclose(fin);  % �ر������ļ�

    % ������һ������������ȡ��ʼʱ��
    first_line_parts = strsplit(data_lines{8}, ' ');
    start_datetime_str = strjoin(first_line_parts(1:4), ' ');

    % ת����ʼʱ��Ϊdatetime����
    start_time = datetime(start_datetime_str, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');

    % �����ļ�ͷ��7�У�����ʣ��������
    for i = 8:length(data_lines)
        parts = strsplit(strtrim(data_lines{i}), ' ');
        if length(parts) < 7  % ȷ���а����㹻������
            continue;
        end

        % �ϲ����ں�ʱ���ַ�������ת��Ϊdatetime����
        current_datetime_str = strjoin(parts(1:4), ' ');
        current_time = datetime(current_datetime_str, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');
        time_diff = current_time - start_time;
        seconds_since_start = seconds(time_diff);

        % ��ȡ�������ݲ����е�λת����ǧ�׵��ף�
        coords = str2double(parts(5:7)) * 1000;
        coords_str = sprintf('%.3f %.3f %.3f', coords);

        % д������ļ�
        fprintf(fout, '%d %s\n', seconds_since_start, coords_str);
    end

    fclose(fout);  % �ر�����ļ�


   
   
end