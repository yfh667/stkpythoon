
function F = Read_All_E_Files_XYZ
    F.Read_All_E_Files_XYZ = @Read_All_E_Files_XYZ;
  F.Read_All_E_Files_XYZ_Serial = @Read_All_E_Files_XYZ_Serial;
%     F.Read_All_E_Files_XYZ_Par = @Read_All_E_Files_XYZ_Par;

 
  
end



function XYZ = Read_All_E_Files_XYZ_Serial(folder)
% 读取 folder 下所有 .e 文件
    % 输出：XYZ 结构体数组 (1 x 卫星数)
    % 结构：XYZ(k).x 是一个列向量 [x_t0; x_t1; ...; x_tn]
    % 用法：
    %   获取第1颗星，第6秒的X坐标： val = XYZ(1).x(6);
    %   获取第5颗星，所有时间的Y坐标： vec = XYZ(5).y;

    files = dir(fullfile(folder, '*.e'));
    nS = numel(files);
    if nS == 0
        error('目录 %s 里没有 .e 文件', folder);
    end

    % ---- 1) 按数字排序 ----
    ids = zeros(nS,1);
    for k = 1:nS
        [~, nameNoExt, ~] = fileparts(files(k).name);
        tok = regexp(nameNoExt, '\d+', 'match', 'once');
        v = str2double(tok);
        if isnan(v), v = k; end
        ids(k) = v;
    end
    [~, idx] = sort(ids);
    sortedFiles = files(idx);

    % ---- 2) 预分配结构体数组 (关键!) ----
    % 我们不分配 (nS, nT)，而是分配 (nS, 1)
    % 直接定义最后一个元素，MATLAB 会自动分配前面的
    XYZ(nS).id = '';
    XYZ(nS).x = []; 
    XYZ(nS).y = []; 
    XYZ(nS).z = [];

    % ---- 3) 循环读取并填充向量 ----
    fprintf('开始读取 %d 个卫星文件...\n', nS);
    
    for k = 1:nS
        fn = fullfile(folder, sortedFiles(k).name);
        
        % 读取该卫星所有时刻的数据 (返回的是向量)
        [x, y, z] = Read_Stk_E_File_XYZ_Only(fn);
        
        % === 直接存入整个向量 ===
        XYZ(k).id = sortedFiles(k).name;
        XYZ(k).x = x; % x 是一个 Nx1 的 double 向量
        XYZ(k).y = y;
        XYZ(k).z = z;

        if mod(k, 50) == 0
            fprintf('已读取 %d/%d\n', k, nS);
        end
    end

    fprintf('读取完成。\n');
end

 
% function XYZ = Read_All_E_Files_XYZ_Par(folder)
%     files = dir(fullfile(folder, '*.e'));
%     n = numel(files);
%     if n == 0, error('目录里没有 .e 文件'); end
% 
%     XYZ.files = string({files.name});
%     XYZ.X = cell(n,1); XYZ.Y = cell(n,1); XYZ.Z = cell(n,1);
% 
%     parfor k = 1:n
%         fn = fullfile(folder, files(k).name);
%         [x,y,z] = Read_Stk_E_File_XYZ_Only(fn);
%         XYZ.X{k} = x; XYZ.Y{k} = y; XYZ.Z{k} = z;
%     end
% end
% 



function [x, y, z] = Read_Stk_E_File_XYZ_Only(filename)
    % 打开文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件: %s', filename); 
    end
    
    % 1. 快速跳过头部 (Header)
    % 寻找包含 "EphemerisTimePosVel" 的行，这通常标志着数据块的开始
    foundData = false;
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, 'EphemerisTimePosVel')
            foundData = true;
            break; 
        end
    end
    
    if ~foundData
        fclose(fid);
        warning('文件 %s 中未找到 EphemerisTimePosVel 标记，可能文件为空或格式错误', filename);
        x = []; y = []; z = [];
        return;
    end
    
    % 2. 读取数据
    % .e 文件标准格式是 7 列: [Time, X, Y, Z, Vx, Vy, Vz]
    % 只读取前 4 列，忽略后 3 列速度信息 (%*f)
    block = textscan(fid, '%f %f %f %f %*f %*f %*f');
    fclose(fid);
    
    % 3. 获取坐标并【强制保留1位小数】
    % block{2}=X, block{3}=Y, block{4}=Z
    
    if isempty(block{2})
        x = []; y = []; z = [];
    else
        % 这里直接做四舍五入，保留1位小数
        x = round(block{2}, 1);
        y = round(block{3}, 1);
        z = round(block{4}, 1);
    end
    
end
% 
% function [x, y, z] = Read_Stk_E_File_XYZ_Only(filename)
%     % 打开文件
%     fid = fopen(filename, 'r');
%     if fid == -1, error('无法打开文件'); end
%     
%     % 1. 快速跳过头部 (Header)
%     % 我们利用 STK .e 文件的特征：数据块之前最后一行通常包含 "EphemerisTimePosVel"
%     while ~feof(fid)
%         line = fgetl(fid);
%         if contains(line, 'EphemerisTimePosVel')
%             break; 
%         end
%     end
%     
%     % 2. 读取数据 (核心优化)
%     % .e 文件标准格式是 7 列: [Time, X, Y, Z, Vx, Vy, Vz]
%     % 我们使用 textscan 只读前 4 列，忽略后 3 列 (使用 %*f 跳过)
%     % %f = 读浮点数, %*f = 读了但丢弃(不占内存)
%     
%     block = textscan(fid, '%f %f %f %f %*f %*f %*f');
%     fclose(fid);
%     
%     % textscan 返回的是 cell array
%     % block{1}=Time, block{2}=X, block{3}=Y, block{4}=Z
%     
%     % 3. 直接获取坐标
%     x = block{2};
%     y = block{3};
%     z = block{4};
%     
%     % x, y, z 现在就是 N x 1 的列向量，且不包含任何速度数据
% end

% [x, y, z] = module.Read_Stk_E_File_XYZ_Only('C:\usrspace\stkfile\position\test\11.e')