%% Call ALL Function
function F = ExportRe
    F.RePort = @RePort;
  F.MultilRePort = @MultilRePort;
    F.MultilRePort_Para = @MultilRePort_Para;

    F.ModifyReport = @ModifyReport;
  F.MultiModifyReport = @MultiModifyReport;
  
  
end
function RePort(root,  type, name,params)
    % 生成指定对象的报告并保存到指定文件
    % 参数：
    %   - root: STK 的根对象（AgStkObjectRoot）
    %   - name: 对象名称
    %   - type: 对象类型，字符串，例如 'Satellite'、'Facility' 等
    %   - params: 包含报告参数的结构体，必须包含以下字段：
    %       - reportStyle: 报告样式名称
    %       - filePath: 报告文件的保存路径
    %       - startTime: 报告的开始时间，格式为 'DD MMM YYYY HH:MM:SS.SSS'
    %       - stopTime: 报告的结束时间，格式同上
    %       - timeStep: 时间步长，单位为秒

    % 参数验证
    requiredFields = {'reportStyle', 'filePath', 'startTime', 'stopTime', 'timeStep'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('参数结构体缺少必需的字段：%s', requiredFields{i});
        end
    end

    % 从参数结构体中获取参数
    object_name = name;
    report_style = params.reportStyle;
    file_path = params.filePath;
    start_time = params.startTime;
    stop_time = params.stopTime;
    time_step = params.timeStep;

    if ~exist(file_path, 'dir')
        mkdir(file_path);
    end

    % 为文件生成路径，将文件名与路径连接
    full_file_path = fullfile(file_path, [object_name, '.txt']);

    % 构建命令字符串，使用变量 'type'
    command = ['ReportCreate */' type '/' object_name ...
        ' Type Save' ...
        ' Style "' report_style '"' ...
        ' File "' full_file_path '"' ...
        ' TimePeriod "' start_time '" "' stop_time '"' ...
        ' TimeStep ' num2str(time_step)];

    % 打印命令以检查
    disp('执行的命令：');
    disp(command);

    % 执行命令并捕获错误
    try
        root.ExecuteCommand(command);
        disp(['报告已成功生成：', full_file_path]);
    catch ME
        disp('执行命令时发生错误：');
        disp(ME.message);
    end
end

function MultilRePort_Para(root, type, names, params)
    % 并行生成指定对象的报告并保存到指定文件
    %
    % 参数：
    %   - root: STK 的根对象（AgStkObjectRoot）
    %   - type: 对象类型，字符串，例如 'Satellite'、'Facility' 等
    %   - names: 包含多个对象名称的单元数组
    %   - params: 包含报告参数的结构体，必须包含以下字段：
    %       - reportStyle: 报告样式名称
    %       - filePath: 报告文件的保存路径
    %       - startTime: 报告的开始时间，格式为 'DD MMM YYYY HH:MM:SS.SSS'
    %       - stopTime: 报告的结束时间，格式同上
    %       - timeStep: 时间步长，单位为秒

    % 参数验证
    requiredFields = {'reportStyle', 'filePath', 'startTime', 'stopTime', 'timeStep'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('参数结构体缺少必需的字段：%s', requiredFields{i});
        end
    end

    % 确保目录存在
    if ~exist(params.filePath, 'dir')
        mkdir(params.filePath);
    end

    % 使用 parfor 并行处理每个对象
    parfor i = 1:length(names)
        try
            object_name = names{i};  % 获取当前的对象名称
            RePort(root, type, object_name, params);
        catch ME
            disp(['生成报告时发生错误，目标对象：', names{i}]);
            disp(ME.message);
        end
    end
end
function MultilRePort(root, type, names, params)
    % 生成指定对象的报告并保存到指定文件
    %
    % 参数：
    %   - root: STK 的根对象（AgStkObjectRoot）
    %   - type: 对象类型，字符串，例如 'Satellite'、'Facility' 等
    %   - names: 包含多个对象名称的单元数组
    %   - params: 包含报告参数的结构体，必须包含以下字段：
    %       - reportStyle: 报告样式名称
    %       - filePath: 报告文件的保存路径
    %       - startTime: 报告的开始时间，格式为 'DD MMM YYYY HH:MM:SS.SSS'
    %       - stopTime: 报告的结束时间，格式同上
    %       - timeStep: 时间步长，单位为秒

    % 参数验证
    requiredFields = {'reportStyle', 'filePath', 'startTime', 'stopTime', 'timeStep'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('参数结构体缺少必需的字段：%s', requiredFields{i});
        end
    end

    % 从参数结构体中获取参数
    report_style = params.reportStyle;
    file_path = params.filePath;
    start_time = params.startTime;
    stop_time = params.stopTime;
    time_step = params.timeStep;
    

    % 确保目录存在

    if ~exist(file_path, 'dir')
        mkdir(file_path);
    end

    % 遍历名称列表
    for i = 1:length(names)
        object_name = names{i};  % 获取当前的对象名称
    RePort(root, type, object_name, params)
 
    end
end


function MultiModifyReport(type, path)
    % 检查和创建子目录
    savePath = fullfile(path, 'modify');
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
 % 检查和创建子目录

    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
    % 获取指定路径下所有指定类型的文件
    files = dir(fullfile(path, ['*.', 'txt']));
    
    % 循环处理每个文件
    for k = 1:length(files)
        input_file = fullfile(path, files(k).name);
        output_file = fullfile(savePath, files(k).name);
        input_file
        output_file
        ModifyReport(type,input_file, output_file);
    end
    
end


function ModifyReport(type, input_file, output_file)
    % 打开输入和输出文件
    fin = fopen(input_file, 'r');
    if fin == -1
        error('Failed to open the input file.');
    end
    
    fout = fopen(output_file, 'w');
    if fout == -1
        fclose(fin);  % 确保在退出前关闭已打开的输入文件
        error('Failed to open the output file.');
    end

    if strcmp(type, 'Satellite')
        % 读取整个文件到一个cell数组中
        data_lines = textscan(fin, '%s', 'Delimiter', '\n');
        data_lines = data_lines{1};
        fclose(fin);  % 处理完毕，关闭输入文件

        % 解析第一条数据行来获取起始时间
        first_line_parts = strsplit(data_lines{8}, ' ');
        start_datetime_str = strjoin(first_line_parts(1:4), ' ');

        % 转换起始时间为datetime类型
        start_time = datetime(start_datetime_str, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');

        % 跳过文件头部7行，处理剩余数据行
        for i = 8:length(data_lines)
            parts = strsplit(strtrim(data_lines{i}), ' ');
            if length(parts) < 7  % 确保行包含足够的数据
                continue;
            end

            % 合并日期和时间字符串，并转换为datetime对象
            current_datetime_str = strjoin(parts(1:4), ' ');
            current_time = datetime(current_datetime_str, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');
            time_diff = current_time - start_time;
            seconds_since_start = seconds(time_diff);

            % 提取坐标数据并进行单位转换（千米到米）
            coords = str2double(parts(5:7)) * 1000;
            coords_str = sprintf('%.3f %.3f %.3f', coords);

            % 写入输出文件
            fprintf(fout, '%d %s\n', seconds_since_start, coords_str);
        end
    elseif strcmp(type, 'Station')
        % 读取并跳过头部行
        for i = 1:7
            fgetl(fin);
        end
        
        % 读取第一条数据行
        first_data_line = fgetl(fin);
        fclose(fin);  % 处理完毕，关闭输入文件

        % 分割第一条数据行以提取坐标数据
        parts = strsplit(strtrim(first_data_line));
        
        % 提取x, y, z坐标
        x = str2double(parts{5}) * 1000;
        y = str2double(parts{6}) * 1000;
        z = str2double(parts{7}) * 1000;

        % 将数据写入输出文件，以空格分隔，所有数据在一行
        fprintf(fout, '%.6f %.6f %.6f', x, y, z);
    end
    
    fclose(fout);  % 关闭输出文件
    disp('Data has been written to the output file.');
end
