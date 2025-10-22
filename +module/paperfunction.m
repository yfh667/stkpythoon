


function F = paperfunction
    F.ab_vector_range = @ab_vector_range;
 
 
 
   
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
