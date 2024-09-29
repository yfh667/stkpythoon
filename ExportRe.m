%% Call ALL Function
function F = ExportRe
    F.RePort = @RePort;
  F.MultilRePort = @MultilRePort;
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
    file_path

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



