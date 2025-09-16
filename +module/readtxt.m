function sats = readtxt(filename)
    % ���ļ�
    fid = fopen(filename, 'r');
    if fid == -1
        error('�޷����ļ�: %s', filename);
    end

    % ������ͷ�������һ���� "Time x y z"��
    header = fgetl(fid);

    % �����ȡ��ʽ���ַ��� + 3 ��������
    data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t');
    fclose(fid);

    % ��ȡ�ֶ�
    time_str = data{1};
    x = data{2};
    y = data{3};
    z = data{4};

    % �����ṹ����
    n = length(x);
    sats = struct('time', [], 'x', [], 'y', [], 'z', []);
    for i = 1:n
        sats(i).time = time_str{i};  % �ɱ����ַ�����ʽ������תΪ datetime �ɺ�������
        sats(i).x = x(i)*1000;
        sats(i).y = y(i)*1000;
        sats(i).z = z(i)*1000;
    end

%     ʾ�����ǰ����
%     disp('ǰ������¼��');
%     for i = 1:min(3, n)
%         fprintf('Time: %s, x: %.3f, y: %.3f, z: %.3f\n', sats(i).time, sats(i).x, sats(i).y, sats(i).z);
%     end
end
