


function Station_View_Result = Calculate_Constellation_Visibility_para2(  stations, XYZ,filepath)
% 1. 获取基础信息
    num_sats = length(XYZ);
    num_stations = length(stations);
    
    % 检查数据完整性
    if num_sats == 0, error('没有卫星数据'); end
    if isempty(XYZ(1).x), error('卫星数据为空'); end
    
    num_steps = length(XYZ(1).x);
    
    fprintf('=== 开始高速并行计算 ===\n');
    fprintf('规模: %d 卫星 x %d 地面站 x %d 时间步\n', num_sats, num_stations, num_steps);
    
    % 开启并行池 (如果没有开启)
    % pool = gcp('nocreate');
    % if isempty(pool), parpool; end

    % =======================================================
    % Phase 1: Map 阶段 (并行计算)
    % 每颗卫星独立计算它对所有地面站的可见性
    % 结果存入 All_Sat_Events，避免竞争写入 Cell
    % =======================================================
    
    % =======================================================
    % 1. 设置进度条监听 (DataQueue)
    % =======================================================
    Q = parallel.pool.DataQueue;       % 创建数据队列
    afterEach(Q, @updateProgress);     % 设置回调函数：每收到一个信号，就调用 updateProgress
    
    p = 0;   % 进度计数器 (主线程变量)
    N = num_sats;
    
    % 嵌套函数：专门负责打印进度
    % 注意：这个函数是在主线程运行的，所以可以安全地累加 p
    function updateProgress(~)
        p = p + 1;
        % 每完成 1% 或者每 50 个打印一次，避免刷屏太快
        if mod(p, 50) == 0 || p == N
            percent = (p / N) * 100;
            % \b 是退格符，但在并行输出中有时会乱，建议直接换行打印
            fprintf('[Map] 进度: %d / %d (%.1f%%)\n', p, N, percent);
        end
    end
    % =======================================================
    
    
    All_Sat_Events = cell(num_sats, 1);
    
 


    parfor k = 1:num_sats
        % --- 1. 预提取向量 (减少结构体访问开销) ---
        % 将这颗卫星的所有坐标一次性提取出来，变成普通向量
        vec_x = XYZ(k).x;
        vec_y = XYZ(k).y;
        vec_z = XYZ(k).z;
        
        % 构造一个临时的事件列表 [Time, StationID]
        % 预估大小：假设50%时间可见，避免频繁扩展
        % (如果内存紧张，可以不预分配，直接用 [])
        my_events = []; 
        
        % 构造卫星对象 (只变位置，角度不变)
        sat_angle = deg2rad(45);
        satellite = struct('position', [0,0,0], 'angle', sat_angle);
        
        % --- 2. 循环计算 ---
        % 提示：如果想更快，可以将 Ground_Sat 内部逻辑提取出来做向量化运算
        % 这里为了保持逻辑兼容，保留循环，但数据访问已加速
        for t = 1:num_steps
            % 更新位置 (直接从向量取值，极快)
            satellite.position = [vec_x(t), vec_y(t), vec_z(t)];
            
            for s = 1:num_stations
                % 调用可见性判断
                % 注意：stations(s) 在 parfor 中会自动分发
                vis = module.Ground_Sat(stations(s), satellite);
                
                if vis > 0
                    % 记录可见事件: [时间步, 地面站ID]
                    % 注意：这里不记录 sat_id，因为 sat_id 就是 k (已知)
                    my_events = [my_events; t, s]; 
                end
            end
        end
        
        % 将本卫星的所有结果存入临时 cell
        All_Sat_Events{k} = my_events;
        
        % =======================================================
        % 2. 发送进度信号
        % =======================================================
        % 告诉主线程：“我做完了一个”
        % 参数可以是任意值，这里发个空值就行，反正只是为了触发回调
        send(Q, []);
          
%         if mod(k,10)==0 || k==num_sats
%                 fprintf('[Map] 已完成 %d/%d 颗卫星 (%.1f%%)\n', k, num_sats, 100*k/num_sats);
%             end
    
    end
    
    fprintf('并行计算完成，正在汇总数据...\n');

    % =======================================================
    % Phase 2: Reduce 阶段 (汇总填表)
    % 将所有卫星的事件表，填入最终的 Cell 数组
    % =======================================================
    Station_View_Result = cell(num_steps, num_stations);
    
    for k = 1:num_sats
        events = All_Sat_Events{k};
        
        if isempty(events)
            continue; 
        end
        
        % 遍历这颗卫星的所有可见记录
        % events 是 N x 2 矩阵: [Time, Station]
        for i = 1:size(events, 1)
            t = events(i, 1);
            s = events(i, 2);
            
            % 将卫星ID (k) 填入大表
            % 这一步虽然也有 end+1，但是在单线程中纯内存操作，且此时数据量已过滤，速度很快
            Station_View_Result{t, s}(end+1) = k;
        end
        
        if mod(k, 100) == 0
            fprintf('已汇总 %d / %d 颗卫星\n', k, num_sats);
        end
    end
    
    % (可选) 保存
    if ~isempty(filepath)
         module.save_Station_View_Result_to_xml(filepath, Station_View_Result);
    end

    disp('所有处理完成！');
    
    
end
