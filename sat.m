%% Call ALL Function

function F = sat
    F.createSatellite = @createSatellite;
    F.createWalkerConstellation=@createWalkerConstellation;
    F.createWalkerConstellation_Delta=@createWalkerConstellation_Delta;
    F.getSatelliteNames = @getSatelliteNames;
end

function createSatellite(root, scenario, params)
    % 创建卫星节点并设置其轨道参数
    %
    % 参数：
    %   - root: STK 的根对象（AgStkObjectRoot）
    %   - scenario: 场景对象
    %   - params: 包含卫星参数的结构体

    % 参数验证
    requiredFields = {'satelliteName', 'perigeeAlt', 'apogeeAlt', 'inclination', ...
                      'argOfPerigee', 'RAAN', 'Anomaly'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('参数结构体缺少必需的字段：%s', requiredFields{i});
        end
    end

    % 从参数结构体中获取卫星名称
    satelliteName = params.satelliteName;

    % 创建卫星
    satellite = scenario.Children.New('eSatellite', satelliteName);

    % 获取初始状态并转换为经典轨道元素
    keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');

    % 设置轨道参数类型
    keplerian.SizeShapeType = 'eSizeShapeAltitude';
    keplerian.LocationType = 'eLocationMeanAnomaly';
    keplerian.Orientation.AscNodeType = 'eAscNodeRAAN';

    % 设置轨道参数
% 设置轨道参数
keplerian.SizeShape.PerigeeAltitude = params.perigeeAlt;    % 近地点高度：卫星轨道最接近地球的点的高度，单位通常为公里。
keplerian.SizeShape.ApogeeAltitude = params.apogeeAlt;      % 远地点高度：卫星轨道最远离地球的点的高度，单位通常为公里。
keplerian.Orientation.Inclination = params.inclination;    % 轨道倾角：卫星轨道平面与地球赤道平面之间的夹角，单位为度。
keplerian.Orientation.ArgOfPerigee = params.argOfPerigee;  % 近地点幅角：从升交点至近地点的角距离，单位为度。
keplerian.Orientation.AscNode.Value = params.RAAN; % 升交点赤经或经度：升交点在赤道上的位置，单位为度。
keplerian.Location.Value = params.Anomaly;           % 平近点角：卫星相对于近地点的平均角位置，单位为度。


    % 应用初始状态
    satellite.Propagator.InitialState.Representation.Assign(keplerian);

    % 传播卫星
    satellite.Propagator.Propagate;
end

%walker星座也有多个类型，下面的是custom类型
function createWalkerConstellation(root, params)
    % 创建 Walker 星座
    %
    % 参数：
    %   - root: STK 的根对象（AgStkObjectRoot）
    %   - params: 包含 Walker 星座参数的结构体，必须包含以下字段：
    %       - seedSatelliteName: 种子卫星名称
    %       - numPlanes: 轨道平面数量
    %       - numSatsPerPlane: 每个平面的卫星数量
    %       - interPlaneTrueAnomalyIncrement: 平面间的真近点角增量（单位：度）
    %       - raanIncrement: RAAN 增量（单位：度）

    % 参数验证
    requiredFields = {'seedSatelliteName', 'numPlanes', 'numSatsPerPlane', 'interPlaneTrueAnomalyIncrement', 'raanIncrement'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('参数结构体缺少必需的字段：%s', requiredFields{i});
        end
    end

    % 从参数结构体中获取参数
    seed_satellite_path = ['*/Satellite/' params.seedSatelliteName];
    num_planes = params.numPlanes;
    num_sats_per_plane = params.numSatsPerPlane;
    inter_plane_ta_increment = params.interPlaneTrueAnomalyIncrement;
    raan_increment = params.raanIncrement;

    % 构建 Walker 命令字符串
    command = ['Walker ' seed_satellite_path ...
        ' Type Custom ' ...
        ' NumPlanes ' num2str(num_planes) ...
        ' NumSatsPerPlane ' num2str(num_sats_per_plane) ...
        ' InterPlaneTrueAnomalyIncrement ' num2str(inter_plane_ta_increment) ...
        ' RAANIncrement ' num2str(raan_increment)];
    
    % 打印命令以供调试
    disp('执行的命令：');
    disp(command);
    
    % 执行 Walker 命令
    try
        root.ExecuteCommand(command);
        disp('Walker 星座创建成功。');
    catch ME
        disp('执行 Walker 命令时发生错误：');
        disp(ME.message);
    end
end
%下面是delta类型
function createWalkerConstellation_Delta(root, params)
    % 创建 Walker 星座（Delta 类型）
    %
    % 参数：
    %   - root: STK 的根对象（AgStkObjectRoot）
    %   - params: 包含 Walker 星座参数的结构体，必须包含以下字段：
    %       - seedSatelliteName: 种子卫星名称
    %       - numPlanes: 轨道平面数量
    %       - numSatsPerPlane: 每个平面的卫星数量
    %       - interPlanePhaseIncrement: 平面间的相位增量（以轨道槽为单位）
    
    % 参数验证
    requiredFields = {'seedSatelliteName', 'numPlanes', 'numSatsPerPlane', 'interPlanePhaseIncrement'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('参数结构体缺少必需的字段：%s', requiredFields{i});
        end
    end

    % 从参数结构体中获取参数
    seed_satellite_path = ['*/Satellite/' params.seedSatelliteName];
    num_planes = params.numPlanes;
    num_sats_per_plane = params.numSatsPerPlane;
    inter_plane_phase_increment = params.interPlanePhaseIncrement;

    % 验证 interPlanePhaseIncrement 值是否合法
    if inter_plane_phase_increment >= num_planes
        error('InterPlanePhaseIncrement 必须小于 NumPlanes。');
    end

    % 构建 Walker 命令字符串
    command = ['Walker ' seed_satellite_path ...
        ' Type Delta ' ...
        ' NumPlanes ' num2str(num_planes) ...
        ' NumSatsPerPlane ' num2str(num_sats_per_plane) ...
        ' InterPlanePhaseIncrement ' num2str(inter_plane_phase_increment)];
    
    % 打印命令以供调试
    disp('执行的命令：');
    disp(command);
    
    % 执行 Walker 命令
    try
        root.ExecuteCommand(command);
        disp('Walker 星座创建成功。');
    catch ME
        disp('执行 Walker 命令时发生错误：');
        disp(ME.message);
    end
end

function satellite_names = getSatelliteNames(scenario)
    % 获取给定场景中的所有卫星名称
    %
    % 参数：
    %   scenario - STK 场景对象
    %
    % 返回：
    %   satellite_names - 卫星名称的单元格数组

    % 获取卫星集合
    satellites = scenario.Children.GetElements('eSatellite');

    % 获取卫星数量
    numSats = satellites.Count;

    % 初始化卫星名称列表
    satellite_names = {};

    % 遍历卫星集合
    for idx = 0:(numSats - 1)  % 索引从 0 开始
        % 将索引转换为整数类型,这个地方特别坑人，要留意
        idx_int = int32(idx);

        % 使用 invoke 函数调用 'Item' 方法
        satellite = invoke(satellites, 'Item', idx_int);

        % 获取卫星名称
        satName = satellite.InstanceName;

        % 将卫星名称添加到名称列表中
        satellite_names{end + 1} = satName;
    end

    % 显示卫星名称
    disp('卫星名称列表：');
    disp(satellite_names);
end

