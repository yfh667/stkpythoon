


function F = paperfunction
    F.ab_vector_range = @ab_vector_range;
 
 
 
   
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
