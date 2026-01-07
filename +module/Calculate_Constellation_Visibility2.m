


function Station_View_Result = Calculate_Constellation_Visibility2(root, stations, XYZ,filepath)
    % 输入:
    % root: 卫星数据文件夹路径
    % stations: 之前读好的 struct 数组 (包含 .position, .angle, .id)
    % scenario: 包含 StartTime, StopTime 等
    
    % ================= 1. 初始化存储容器 =================
    % 假设我们需要仿真 3600 秒
    % 我们先随便读一颗卫星来确定时间步数 (num_steps)
    % 这里假设你已知 num_steps，或者通过读取第一颗星获取
    % 暂时假设 num_steps 已知，或者先读第一颗星来初始化
    
    % 卫星总数 (你需要知道文件夹里有多少颗星，或者遍历文件夹)
    
 



    num_sats = length(XYZ)


    % timestep = 1

 

    
    % 获取地面站数量
    num_stations = length(stations);
    
 
    num_steps = length(XYZ(1).x)
    
    % [核心数据结构] Cell 数组
    % 行 = 时间步, 列 = 地面站
    % 每个单元格存放 = [可见的卫星ID列表]
    % Station_View_Result{t, s} 将返回一个数组，例如 [1, 5, 128]
    
    
    Station_View_Result = cell(num_steps, num_stations);
    
    fprintf('开始处理 %d 颗卫星与 %d 个地面站的可见性...\n', num_sats, num_stations);
    
    % ================= 2. 最外层循环：遍历每一颗卫星 =================
    for k = 1:num_sats
        
        % 2.1 获取卫星名称/ID
        % 假设文件名是 'qf_1.txt', 'qf_2.txt'...
 
        
%         satellite1_name = satellite_names{k};
        
        % 2.2 读取这颗卫星的所有时间步位置
        % 注意：GetPositionxyz_read 需要根据你的实际文件名逻辑修改
%         [x_m, y_m, z_m] = position.GetPositionxyz_read(root, satellite1_name, scenario.StartTime, scenario.StopTime, 1);
        
        % 构造一个复用的卫星对象
        
        satellite.angle = deg2rad(45); % 假设波束角固定
        
        
        % ================= 3. 中间层循环：遍历所有时间步 =================
        for t = 1:num_steps
            
            % 更新卫星当前位置
            satellite.position = [XYZ(k).x(t), XYZ(k).y(t), XYZ(k).z(t)];
            
            % ================= 4. 最内层循环：遍历所有地面站 =================
            for s = 1:num_stations
                
                curr_station = stations(s);
                
                % 计算可见性
                vis_ratio = module.Ground_Sat(curr_station, satellite);
                
                % ================= 5. “投递”结果 =================
                if vis_ratio > 0
                    % 如果可见，将 sat_id 加入到对应的 {时间, 站点} 列表里
                    % end+1 表示追加到数组末尾
%                fprintf('Visible @step=%d, ratio=%.4f, stations=%d\n', t, vis_ratio, s);
                    Station_View_Result{t, s}(end+1) = k;
                end
                
            end % End Station Loop
            
        end % End Time Loop
        
        
        
        
        % 打印进度 (每处理10颗星显示一次，防止刷屏)
        if mod(k, 10) == 0
            fprintf('已完成卫星: %d / %d\n', k, num_sats);
        end
        
    end % End Satellite Loop (处理完这颗星，内存释放，读取下一颗)
    
%     module.save_Station_View_Result_to_xml(filepath, Station_View_Result);

    disp('所有计算完成！');
    
end
