

function F = Export_Position_STK
    F.Export_Position_STK = @Export_Position_STK;
  F.Export_Pos_Line = @Export_Pos_Line;
    F.Export_Pos_para = @Export_Pos_para;

 
  
end
%  单纯用stk的数据导出功能，会比较快一点，只要用Export_Pos_Line这个即可。

function Export_Pos_Line(root,scenario,  output_folder)

%  output_folder = 'C:\usrspace\stkfile\position\test'

sat = module.sat();

satellite_names =sat.getSatelliteNames(scenario);



num_sats = length(satellite_names)


    if ~exist(output_folder, 'dir'), mkdir(output_folder); end
    
 
    fprintf('正在导出 %d 颗卫星 (间隔1秒, ECEF坐标)...\n', num_sats);
    
    tic;
    for k = 1:num_sats
        satName = satellite_names{k};
        satID = regexp(satName, '\d+', 'match', 'once');
        
        filePath = fullfile(output_folder, [satID '.e']);
        
        % === 核心命令修改 ===
        % 1. Type STK: 速度最快
        % 2. CoordSys Fixed: 确保是固连坐标(ECEF)，直接用于算距离
        % 3. TimeSteps 1.0: 强制 1秒 输出一次
        cmd = sprintf('ExportDataFile */Satellite/%s Ephemeris "%s" Type STK CoordSys Fixed TimeSteps 1.0', ...
                      satName, filePath);
        
        try
            root.ExecuteCommand(cmd);
        catch ME
            fprintf('Error exporting %s: %s\n', satName, ME.message);
        end
        
        if mod(k, 100) == 0, fprintf('  已完成 %d / %d\n', k, num_sats); end
    end
    toc;
end




function Export_Pos_para(root, scenario, output_folder)
% 1. 获取卫星名称
    sat = module.sat();
    satellite_names = sat.getSatelliteNames(scenario);
    num_sats = length(satellite_names);

    % 2. 确保输出文件夹存在
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % 定义批处理脚本的路径 (临时文件)
    batch_script_file = fullfile(output_folder, 'batch_export_cmds.stk');
    
    fprintf('正在生成批处理脚本: %s ...\n', batch_script_file);

    % ==========================================
    % 第一步：在 MATLAB 本地把所有命令写入 .stk 文件
    % ==========================================
    fid = fopen(batch_script_file, 'w');
    if fid == -1
        error('无法创建批处理文件，请检查路径权限');
    end
    
    % 写入 36 条导出命令到文件中
    for k = 1:num_sats
        satName = satellite_names{k};
        
        % 提取 ID
        satID = regexp(satName, '\d+', 'match', 'once');
        if isempty(satID), satID = satName; end
        
        filePath = fullfile(output_folder, [satID '.e']);
        
        % 构造命令字符串
        cmd = sprintf('ExportDataFile */Satellite/%s Ephemeris "%s" Type STK CoordSys Fixed TimeSteps 1.0', ...
                      satName, filePath);
        
        % 写入文件 (加换行符)
        fprintf(fid, '%s\n', cmd);
    end
    
    fclose(fid); % 关闭文件，此时硬盘上已经有了包含所有命令的 txt
    
    % ==========================================
    % 第二步：发送唯一的一条指令给 STK
    % ==========================================
    fprintf('发送 Batch 指令给 STK，开始极速导出 %d 颗卫星...\n', num_sats);
    
    tic;
    
    % 使用 "Batch" 命令让 STK 执行该脚本文件
    % 注意：路径最好加引号，防止有空格
stk_cmd = sprintf('ConFile / "%s"', batch_script_file);
    
    try
        root.ExecuteCommand(stk_cmd);
    catch ME
        fprintf('[错误] STK 执行批处理失败: %s\n', ME.message);
    end
    
    total_time = toc;
    
    % ==========================================
    % 第三步：清理
    % ==========================================
    % delete(batch_script_file); % 如果想保留脚本查看，注释掉这行
    
    fprintf('---------------------------------------\n');
    fprintf('全部完成！\n');
    fprintf('卫星数量: %d\n', num_sats);
    fprintf('总耗时  : %.2f 秒 (平均 %.4f 秒/颗)\n', total_time, total_time/num_sats);
    fprintf('---------------------------------------\n');
end