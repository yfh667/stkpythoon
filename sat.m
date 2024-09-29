%% Call ALL Function

function F = sat
    F.createSatellite = @createSatellite;
    F.createWalkerConstellation=@createWalkerConstellation;
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
                      'argOfPerigee', 'ascNodeValue', 'locationValue'};
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
    keplerian.LocationType = 'eLocationTrueAnomaly';
    keplerian.Orientation.AscNodeType = 'eAscNodeLAN';

    % 设置轨道参数
    keplerian.SizeShape.PerigeeAltitude = params.perigeeAlt;
    keplerian.SizeShape.ApogeeAltitude = params.apogeeAlt;
    keplerian.Orientation.Inclination = params.inclination;
    keplerian.Orientation.ArgOfPerigee = params.argOfPerigee;
    keplerian.Orientation.AscNode.Value = params.ascNodeValue;
    keplerian.Location.Value = params.locationValue;

    % 应用初始状态
    satellite.Propagator.InitialState.Representation.Assign(keplerian);

    % 传播卫星
    satellite.Propagator.Propagate;
end


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

