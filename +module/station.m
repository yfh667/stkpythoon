function F = Station
   F.Station = @Station;
   F.getStation_names = @getStation_names;
   F.SetStation = @SetStation
end

function station_names = getStation_names(scenario)
    % 获取给定场景中的所有卫星名称
    %
    % 参数：
    %   scenario - STK 场景对象
    %
    % 返回：
    %   satellite_names - 卫星名称的单元格数组

    % 获取卫星集合
     stations = scenario.Children.GetElements('eFacility');

    % 获取卫星数量
    numStation = stations.Count;

    % 初始化卫星名称列表
    station_names = {};

    % 遍历卫星集合
    for idx = 0:(numStation - 1)  % 索引从 0 开始
        % 将索引转换为整数类型,这个地方特别坑人，要留意
        idx_int = int32(idx);

        % 使用 invoke 函数调用 'Item' 方法
         station = invoke(stations, 'Item', idx_int);

        % 获取卫星名称
        staName = station.InstanceName;

        % 将卫星名称添加到名称列表中
        station_names{end + 1} = staName;
    end

    % 显示卫星名称
    disp('地面站名称列表：');
    disp(station_names);
end

function SetStation(root,scenario,name)

%设置地面设施
facility =  scenario.Children.New('eFacility',name);

facility.Position.AssignGeodetic(0.75,101,0);

end
 


