function sats = readtxt(filename)
    % 打开文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件: %s', filename);
    end

    % 跳过表头（假设第一行是 "Time x y z"）
    header = fgetl(fid);

    % 定义读取格式：字符串 + 3 个浮点数
    data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t');
    fclose(fid);

    % 获取字段
    time_str = data{1};
    x = data{2};
    y = data{3};
    z = data{4};

    % 创建结构数组
    n = length(x);
    sats = struct('time', [], 'x', [], 'y', [], 'z', []);
    for i = 1:n
        sats(i).time = time_str{i};  % 可保留字符串形式，如需转为 datetime 可后续处理
        sats(i).x = x(i)*1000;
        sats(i).y = y(i)*1000;
        sats(i).z = z(i)*1000;
    end

%     示例输出前几个
%     disp('前几条记录：');
%     for i = 1:min(3, n)
%         fprintf('Time: %s, x: %.3f, y: %.3f, z: %.3f\n', sats(i).time, sats(i).x, sats(i).y, sats(i).z);
%     end
end
