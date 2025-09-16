


function F = paperfunction
    F.ab_vector_range = @ab_vector_range;
     F.ab_vector_range_file = @ab_vector_range_file;

 
 
   
end

function [t, mag] = ab_vector_range(root, satAName, satBName, timestep)
% AB_VECTOR_RANGE  ��ȡ�������Ǽ�λ������ AB ��ʱ�����ֵ�����룩
% �÷���
%   [t, mag] = ab_vector_range(root, 'QF_01_17', 'QF_02_17', 1);
% ������
%   root      : STK Application �� Personality2 ������� uiapp.Personality2��
%   satAName  : Դ�������ƣ��� 'QF_01_17'��
%   satBName  : Ŀ���������ƣ��� 'QF_02_17'��
%   timestep  : (��ѡ) ������������λ�룬Ĭ�� 1
% ���أ�
%   t   : ʱ���ᣨ���� UTC datetime���� Time Ϊ����룬���� StartTime ��Ϊ���� datetime��
%   mag : �����ֵ���� STK Vectors(Fixed) Magnitude ��λһ�£�����Ϊ km��

    if nargin < 4 || isempty(timestep), timestep = 1; end

    % ���� ȡ��������� ����
    scenario = root.CurrentScenario;
    satA = root.GetObjectFromPath(['Satellite/' char(satAName)]);
    satB = root.GetObjectFromPath(['Satellite/' char(satBName)]);
    pA   = satA.vgt.Points.Item('Center');
    pB   = satB.vgt.Points.Item('Center');

    % ���� �� A �ϴ���/����λ��������Ψһ���������ͻ������
    vecName = ['AB_' sanitizeName(satAName) '_to_' sanitizeName(satBName)];
    createdHere = false;
    try
        satA.vgt.Vectors.Item(vecName);          % ��������
    catch
        satA.vgt.Vectors.Factory.CreateDisplacementVector(vecName, pA, pB);
        createdHere = true;
    end

    % ���� �����ṩ����Fixed ����ϵ������
    dp  = satA.DataProviders.Item('Vectors(Fixed)').Group.Item(vecName);
    res = dp.Exec(scenario.StartTime, scenario.StopTime, timestep);

    % ���� ȡ Time �� Magnitude ���� 
    tRaw   = res.DataSets.GetDataSetByName('Time').GetValues;
    magRaw = res.DataSets.GetDataSetByName('Magnitude').GetValues;

    % Magnitude -> double ������
    if isnumeric(magRaw)
        mag = double(magRaw(:));
    elseif iscell(magRaw)
        mag = cellfun(@double, magRaw(:));
    else
        mag = double(magRaw(:));
    end

    % ���� ����ʱ���ᣨ�Զ�ʶ�� UTC �ַ���/����룩����
    fmt1 = 'dd MMM yyyy HH:mm:ss.SSS';
    fmt2 = 'dd MMM yyyy HH:mm:ss';

    if isnumeric(tRaw)
        % ��Գ����������
        secs = double(tRaw(:));
        t0   = tryParseDt(string(scenario.StartTime), fmt1, fmt2);
        t    = t0 + seconds(secs);                 % ����ʱ�䣨UTC��
    else
        % Ӣ�� UTC �ַ���
        if iscell(tRaw)
            tVals = string(tRaw(:));
        else
            tVals = string(tRaw(:));
        end
        t = tryParseDt(tVals, fmt1, fmt2);         % ����ʱ�䣨UTC��
    end

    % ���� ������ɾ���������½�����ʱʸ�� ���� 
    if createdHere
        try
            satA.vgt.Vectors.Remove(vecName);
        catch
            % ��������ʧ�ܣ�ͨ�����ᷢ����
        end
    end
end



% ====== ���ߣ���ȫ��������ϴ��ֻ����ĸ���ֺ��»��ߣ� ======
function s = sanitizeName(name)
    s = regexprep(char(name), '[^A-Za-z0-9_]', '_');
end

% ====== ���ߣ��Ƚ���Ӣ��ʱ���������ʽ Locale�� ======
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
function ab_vector_range_file(root, satAName, satBName, timestep, out_arg)
% AB_VECTOR_RANGE_FILE  �������Ǽ� AB λ��������ʱ��-���룬��д���ı��ļ�
% �÷���
%   ab_vector_range_file(root, 'QF_01_17','QF_02_17', 1, 'E:\�о���\data\stk')
%   ab_vector_range_file(root, 'QF_01_17','QF_02_17', 1, 'E:\�о���\data\stk\QF_01_17_QF_02_17_range.txt')

    if nargin < 4 || isempty(timestep), timestep = 1; end
    if nargin < 5 || isempty(out_arg)
        error('���ṩ���Ŀ¼�������ļ�����out_arg����');
    end

    % ���� �������·�����ȿɴ�Ŀ¼Ҳ�ɴ������ļ��� ����
    outfile = resolve_outfile(out_arg, satAName, satBName, 'range');

    % ���� ȡ��������� ����
    scenario = root.CurrentScenario;
    satA = root.GetObjectFromPath(['Satellite/' char(satAName)]);
    satB = root.GetObjectFromPath(['Satellite/' char(satBName)]);
    pA   = satA.vgt.Points.Item('Center');
    pB   = satB.vgt.Points.Item('Center');

    % ���� �� A �ϴ���/����λ��������Ψһ���������ͻ������
    vecName = ['AB_' sanitizeName(satAName) '_to_' sanitizeName(satBName)];
    createdHere = false;
    try
        satA.vgt.Vectors.Item(vecName);      % �Ѵ�������
    catch
        satA.vgt.Vectors.Factory.CreateDisplacementVector(vecName, pA, pB);
        createdHere = true;
    end

    % ���� �����ṩ����Fixed ����ϵ������
    dp  = satA.DataProviders.Item('Vectors(Fixed)').Group.Item(vecName);
    res = dp.Exec(scenario.StartTime, scenario.StopTime, timestep);

    % ���� ȡ Time �� Magnitude ���� 
    tRaw   = res.DataSets.GetDataSetByName('Time').GetValues;
    magRaw = res.DataSets.GetDataSetByName('Magnitude').GetValues;

    % Magnitude -> double ������
    if isnumeric(magRaw)
        mag = double(magRaw(:));
    elseif iscell(magRaw)
        mag = cellfun(@double, magRaw(:));
    else
        mag = double(magRaw(:));
    end

    % ���� ����ʱ���ᣨUTC datetime������
    fmt1 = 'dd MMM yyyy HH:mm:ss.SSS';
    fmt2 = 'dd MMM yyyy HH:mm:ss';
    if isnumeric(tRaw)
        % ����� -> ����ʱ��
        secs = double(tRaw(:));
        t0   = tryParseDt(string(scenario.StartTime), fmt1, fmt2);
        t    = t0 + seconds(secs);
    else
        % Ӣ�� UTC �ַ��� -> datetime
        tVals = string(tRaw(:));
        t     = tryParseDt(tVals, fmt1, fmt2);
    end

    % ���� ���д�����Ʊ���ָ�������ͷ������
    T = table(t(:), mag(:), 'VariableNames', {'Time','Range'});
    % ͳһ���ʱ���ʽ���ɰ���ģ�
    if isdatetime(T.Time)
        T.Time.Format = 'yyyy-MM-dd HH:mm:ss.SSS';
    end

    % ȷ��Ŀ¼����
    outdir = fileparts(outfile);
    if ~isempty(outdir) && ~exist(outdir,'dir'), mkdir(outdir); end

    % д�ļ�������ʽ��
    writetable(T, outfile, 'Delimiter', '\t', 'FileType', 'text', 'WriteVariableNames', true);

    fprintf('��д����%s  ��%d �У�\n', outfile, height(T));

    % ���� ������������½�����ʱʸ�� ���� 
    if createdHere
        try
            satA.vgt.Vectors.Remove(vecName);
        catch
            % ����
        end
    end
end

% ======= �������� =======

function outfile = resolve_outfile(out_arg, satAName, satBName, suffix)
    % ������Ŀ¼�����Զ�ƴ�� ����\satA_satB_suffix.txt��
    if isfolder(out_arg)
        outfile = fullfile(out_arg, sprintf('%s_%s_%s.txt', char(satAName), char(satBName), suffix));
    else
        [p,n,e] = fileparts(out_arg);
        if isempty(e), e = '.txt'; end
        if ~isempty(p) && ~exist(p,'dir'), mkdir(p); end
        outfile = fullfile(p, [n e]);
    end
end