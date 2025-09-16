


function F = paperfunction
    F.ab_vector_range = @ab_vector_range;
     F.ab_vector_range_file = @ab_vector_range_file;

 
 
   
end

function [t, mag] = ab_vector_range(root, satAName, satBName, timestep)
% AB_VECTOR_RANGE  获取两颗卫星间位移向量 AB 的时间与幅值（距离）
% 用法：
%   [t, mag] = ab_vector_range(root, 'QF_01_17', 'QF_02_17', 1);
% 参数：
%   root      : STK Application 的 Personality2 句柄（如 uiapp.Personality2）
%   satAName  : 源卫星名称（如 'QF_01_17'）
%   satBName  : 目标卫星名称（如 'QF_02_17'）
%   timestep  : (可选) 采样步长，单位秒，默认 1
% 返回：
%   t   : 时间轴（优先 UTC datetime；若 Time 为相对秒，则由 StartTime 推为绝对 datetime）
%   mag : 距离幅值（与 STK Vectors(Fixed) Magnitude 单位一致，常见为 km）

    if nargin < 4 || isempty(timestep), timestep = 1; end

    % —— 取场景与对象 ——
    scenario = root.CurrentScenario;
    satA = root.GetObjectFromPath(['Satellite/' char(satAName)]);
    satB = root.GetObjectFromPath(['Satellite/' char(satBName)]);
    pA   = satA.vgt.Points.Item('Center');
    pB   = satB.vgt.Points.Item('Center');

    % —— 在 A 上创建/复用位移向量（唯一名，避免冲突）——
    vecName = ['AB_' sanitizeName(satAName) '_to_' sanitizeName(satBName)];
    createdHere = false;
    try
        satA.vgt.Vectors.Item(vecName);          % 存在则复用
    catch
        satA.vgt.Vectors.Factory.CreateDisplacementVector(vecName, pA, pB);
        createdHere = true;
    end

    % —— 数据提供器（Fixed 坐标系）——
    dp  = satA.DataProviders.Item('Vectors(Fixed)').Group.Item(vecName);
    res = dp.Exec(scenario.StartTime, scenario.StopTime, timestep);

    % —— 取 Time 与 Magnitude —— 
    tRaw   = res.DataSets.GetDataSetByName('Time').GetValues;
    magRaw = res.DataSets.GetDataSetByName('Magnitude').GetValues;

    % Magnitude -> double 列向量
    if isnumeric(magRaw)
        mag = double(magRaw(:));
    elseif iscell(magRaw)
        mag = cellfun(@double, magRaw(:));
    else
        mag = double(magRaw(:));
    end

    % —— 构造时间轴（自动识别 UTC 字符串/相对秒）——
    fmt1 = 'dd MMM yyyy HH:mm:ss.SSS';
    fmt2 = 'dd MMM yyyy HH:mm:ss';

    if isnumeric(tRaw)
        % 相对场景起点秒数
        secs = double(tRaw(:));
        t0   = tryParseDt(string(scenario.StartTime), fmt1, fmt2);
        t    = t0 + seconds(secs);                 % 绝对时间（UTC）
    else
        % 英文 UTC 字符串
        if iscell(tRaw)
            tVals = string(tRaw(:));
        else
            tVals = string(tRaw(:));
        end
        t = tryParseDt(tVals, fmt1, fmt2);         % 绝对时间（UTC）
    end

    % —— 清理：仅删除本函数新建的临时矢量 —— 
    if createdHere
        try
            satA.vgt.Vectors.Remove(vecName);
        catch
            % 忽略清理失败（通常不会发生）
        end
    end
end



% ====== 工具：安全的名称清洗（只留字母数字和下划线） ======
function s = sanitizeName(name)
    s = regexprep(char(name), '[^A-Za-z0-9_]', '_');
end

% ====== 工具：稳健的英文时间解析（显式 Locale） ======
function dt = tryParseDt(strVals, fmt1, fmt2)
    try
        dt = datetime(strVals, 'InputFormat', fmt1, 'TimeZone','UTC', 'Locale','en_US');
    catch
        try
            dt = datetime(strVals, 'InputFormat', fmt2, 'TimeZone','UTC', 'Locale','en_US');
        catch
            try
                dt = datetime(strVals, 'InputFormat', fmt1, 'TimeZone','UTC', 'Locale','en_GB');
            catch
                dt = datetime(strVals, 'InputFormat', fmt2, 'TimeZone','UTC', 'Locale','en_GB');
            end
        end
    end
end
function ab_vector_range_file(root, satAName, satBName, timestep, out_arg)
% AB_VECTOR_RANGE_FILE  计算两星间 AB 位移向量的时间-距离，并写入文本文件
% 用法：
%   ab_vector_range_file(root, 'QF_01_17','QF_02_17', 1, 'E:\研究生\data\stk')
%   ab_vector_range_file(root, 'QF_01_17','QF_02_17', 1, 'E:\研究生\data\stk\QF_01_17_QF_02_17_range.txt')

    if nargin < 4 || isempty(timestep), timestep = 1; end
    if nargin < 5 || isempty(out_arg)
        error('请提供输出目录或完整文件名（out_arg）。');
    end

    % —— 解析输出路径：既可传目录也可传完整文件名 ——
    outfile = resolve_outfile(out_arg, satAName, satBName, 'range');

    % —— 取场景与对象 ——
    scenario = root.CurrentScenario;
    satA = root.GetObjectFromPath(['Satellite/' char(satAName)]);
    satB = root.GetObjectFromPath(['Satellite/' char(satBName)]);
    pA   = satA.vgt.Points.Item('Center');
    pB   = satB.vgt.Points.Item('Center');

    % —— 在 A 上创建/复用位移向量（唯一名，避免冲突）——
    vecName = ['AB_' sanitizeName(satAName) '_to_' sanitizeName(satBName)];
    createdHere = false;
    try
        satA.vgt.Vectors.Item(vecName);      % 已存在则复用
    catch
        satA.vgt.Vectors.Factory.CreateDisplacementVector(vecName, pA, pB);
        createdHere = true;
    end

    % —— 数据提供器（Fixed 坐标系）——
    dp  = satA.DataProviders.Item('Vectors(Fixed)').Group.Item(vecName);
    res = dp.Exec(scenario.StartTime, scenario.StopTime, timestep);

    % —— 取 Time 与 Magnitude —— 
    tRaw   = res.DataSets.GetDataSetByName('Time').GetValues;
    magRaw = res.DataSets.GetDataSetByName('Magnitude').GetValues;

    % Magnitude -> double 列向量
    if isnumeric(magRaw)
        mag = double(magRaw(:));
    elseif iscell(magRaw)
        mag = cellfun(@double, magRaw(:));
    else
        mag = double(magRaw(:));
    end

    % —— 构造时间轴（UTC datetime）——
    fmt1 = 'dd MMM yyyy HH:mm:ss.SSS';
    fmt2 = 'dd MMM yyyy HH:mm:ss';
    if isnumeric(tRaw)
        % 相对秒 -> 绝对时间
        secs = double(tRaw(:));
        t0   = tryParseDt(string(scenario.StartTime), fmt1, fmt2);
        t    = t0 + seconds(secs);
    else
        % 英文 UTC 字符串 -> datetime
        tVals = string(tRaw(:));
        t     = tryParseDt(tVals, fmt1, fmt2);
    end

    % —— 组表并写出（制表符分隔，含表头）——
    T = table(t(:), mag(:), 'VariableNames', {'Time','Range'});
    % 统一输出时间格式（可按需改）
    if isdatetime(T.Time)
        T.Time.Format = 'yyyy-MM-dd HH:mm:ss.SSS';
    end

    % 确保目录存在
    outdir = fileparts(outfile);
    if ~isempty(outdir) && ~exist(outdir,'dir'), mkdir(outdir); end

    % 写文件（覆盖式）
    writetable(T, outfile, 'Delimiter', '\t', 'FileType', 'text', 'WriteVariableNames', true);

    fprintf('已写出：%s  （%d 行）\n', outfile, height(T));

    % —— 清理仅本函数新建的临时矢量 —— 
    if createdHere
        try
            satA.vgt.Vectors.Remove(vecName);
        catch
            % 忽略
        end
    end
end

% ======= 辅助函数 =======

function outfile = resolve_outfile(out_arg, satAName, satBName, suffix)
    % 若传入目录，则自动拼出 “…\satA_satB_suffix.txt”
    if isfolder(out_arg)
        outfile = fullfile(out_arg, sprintf('%s_%s_%s.txt', char(satAName), char(satBName), suffix));
    else
        [p,n,e] = fileparts(out_arg);
        if isempty(e), e = '.txt'; end
        if ~isempty(p) && ~exist(p,'dir'), mkdir(p); end
        outfile = fullfile(p, [n e]);
    end
end