%% Call ALL Function

function F = sat
    F.createSatellite = @createSatellite;
    F.createWalkerConstellation=@createWalkerConstellation;
    F.createWalkerConstellation_Delta=@createWalkerConstellation_Delta;
    F.getSatelliteNames = @getSatelliteNames;
end

function createSatellite(root, scenario, params)
    % �������ǽڵ㲢������������
    %
    % ������
    %   - root: STK �ĸ�����AgStkObjectRoot��
    %   - scenario: ��������
    %   - params: �������ǲ����Ľṹ��

    % ������֤
    requiredFields = {'satelliteName', 'perigeeAlt', 'apogeeAlt', 'inclination', ...
                      'argOfPerigee', 'RAAN', 'Anomaly'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('�����ṹ��ȱ�ٱ�����ֶΣ�%s', requiredFields{i});
        end
    end

    % �Ӳ����ṹ���л�ȡ��������
    satelliteName = params.satelliteName;

    % ��������
    satellite = scenario.Children.New('eSatellite', satelliteName);

    % ��ȡ��ʼ״̬��ת��Ϊ������Ԫ��
    keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');

    % ���ù����������
    keplerian.SizeShapeType = 'eSizeShapeAltitude';
    keplerian.LocationType = 'eLocationMeanAnomaly';
    keplerian.Orientation.AscNodeType = 'eAscNodeRAAN';

    % ���ù������
% ���ù������
keplerian.SizeShape.PerigeeAltitude = params.perigeeAlt;    % ���ص�߶ȣ����ǹ����ӽ�����ĵ�ĸ߶ȣ���λͨ��Ϊ���
keplerian.SizeShape.ApogeeAltitude = params.apogeeAlt;      % Զ�ص�߶ȣ����ǹ����Զ�����ĵ�ĸ߶ȣ���λͨ��Ϊ���
keplerian.Orientation.Inclination = params.inclination;    % �����ǣ����ǹ��ƽ���������ƽ��֮��ļнǣ���λΪ�ȡ�
keplerian.Orientation.ArgOfPerigee = params.argOfPerigee;  % ���ص���ǣ��������������ص�ĽǾ��룬��λΪ�ȡ�
keplerian.Orientation.AscNode.Value = params.RAAN; % ������ྭ�򾭶ȣ��������ڳ���ϵ�λ�ã���λΪ�ȡ�
keplerian.Location.Value = params.Anomaly;           % ƽ����ǣ���������ڽ��ص��ƽ����λ�ã���λΪ�ȡ�


    % Ӧ�ó�ʼ״̬
    satellite.Propagator.InitialState.Representation.Assign(keplerian);

    % ��������
    satellite.Propagator.Propagate;
end

%walker����Ҳ�ж�����ͣ��������custom����
function createWalkerConstellation(root, params)
    % ���� Walker ����
    %
    % ������
    %   - root: STK �ĸ�����AgStkObjectRoot��
    %   - params: ���� Walker ���������Ľṹ�壬������������ֶΣ�
    %       - seedSatelliteName: ������������
    %       - numPlanes: ���ƽ������
    %       - numSatsPerPlane: ÿ��ƽ�����������
    %       - interPlaneTrueAnomalyIncrement: ƽ������������������λ���ȣ�
    %       - raanIncrement: RAAN ��������λ���ȣ�

    % ������֤
    requiredFields = {'seedSatelliteName', 'numPlanes', 'numSatsPerPlane', 'interPlaneTrueAnomalyIncrement', 'raanIncrement'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('�����ṹ��ȱ�ٱ�����ֶΣ�%s', requiredFields{i});
        end
    end

    % �Ӳ����ṹ���л�ȡ����
    seed_satellite_path = ['*/Satellite/' params.seedSatelliteName];
    num_planes = params.numPlanes;
    num_sats_per_plane = params.numSatsPerPlane;
    inter_plane_ta_increment = params.interPlaneTrueAnomalyIncrement;
    raan_increment = params.raanIncrement;

    % ���� Walker �����ַ���
    command = ['Walker ' seed_satellite_path ...
        ' Type Custom ' ...
        ' NumPlanes ' num2str(num_planes) ...
        ' NumSatsPerPlane ' num2str(num_sats_per_plane) ...
        ' InterPlaneTrueAnomalyIncrement ' num2str(inter_plane_ta_increment) ...
        ' RAANIncrement ' num2str(raan_increment)];
    
    % ��ӡ�����Թ�����
    disp('ִ�е����');
    disp(command);
    
    % ִ�� Walker ����
    try
        root.ExecuteCommand(command);
        disp('Walker ���������ɹ���');
    catch ME
        disp('ִ�� Walker ����ʱ��������');
        disp(ME.message);
    end
end
%������delta����
function createWalkerConstellation_Delta(root, params)
    % ���� Walker ������Delta ���ͣ�
    %
    % ������
    %   - root: STK �ĸ�����AgStkObjectRoot��
    %   - params: ���� Walker ���������Ľṹ�壬������������ֶΣ�
    %       - seedSatelliteName: ������������
    %       - numPlanes: ���ƽ������
    %       - numSatsPerPlane: ÿ��ƽ�����������
    %       - interPlanePhaseIncrement: ƽ������λ�������Թ����Ϊ��λ��
    
    % ������֤
    requiredFields = {'seedSatelliteName', 'numPlanes', 'numSatsPerPlane', 'interPlanePhaseIncrement'};
    for i = 1:length(requiredFields)
        if ~isfield(params, requiredFields{i})
            error('�����ṹ��ȱ�ٱ�����ֶΣ�%s', requiredFields{i});
        end
    end

    % �Ӳ����ṹ���л�ȡ����
    seed_satellite_path = ['*/Satellite/' params.seedSatelliteName];
    num_planes = params.numPlanes;
    num_sats_per_plane = params.numSatsPerPlane;
    inter_plane_phase_increment = params.interPlanePhaseIncrement;

    % ��֤ interPlanePhaseIncrement ֵ�Ƿ�Ϸ�
    if inter_plane_phase_increment >= num_planes
        error('InterPlanePhaseIncrement ����С�� NumPlanes��');
    end

    % ���� Walker �����ַ���
    command = ['Walker ' seed_satellite_path ...
        ' Type Delta ' ...
        ' NumPlanes ' num2str(num_planes) ...
        ' NumSatsPerPlane ' num2str(num_sats_per_plane) ...
        ' InterPlanePhaseIncrement ' num2str(inter_plane_phase_increment)];
    
    % ��ӡ�����Թ�����
    disp('ִ�е����');
    disp(command);
    
    % ִ�� Walker ����
    try
        root.ExecuteCommand(command);
        disp('Walker ���������ɹ���');
    catch ME
        disp('ִ�� Walker ����ʱ��������');
        disp(ME.message);
    end
end

function satellite_names = getSatelliteNames(scenario)
    % ��ȡ���������е�������������
    %
    % ������
    %   scenario - STK ��������
    %
    % ���أ�
    %   satellite_names - �������Ƶĵ�Ԫ������

    % ��ȡ���Ǽ���
    satellites = scenario.Children.GetElements('eSatellite');

    % ��ȡ��������
    numSats = satellites.Count;

    % ��ʼ�����������б�
    satellite_names = {};

    % �������Ǽ���
    for idx = 0:(numSats - 1)  % ������ 0 ��ʼ
        % ������ת��Ϊ��������,����ط��ر���ˣ�Ҫ����
        idx_int = int32(idx);

        % ʹ�� invoke �������� 'Item' ����
        satellite = invoke(satellites, 'Item', idx_int);

        % ��ȡ��������
        satName = satellite.InstanceName;

        % ������������ӵ������б���
        satellite_names{end + 1} = satName;
    end

    % ��ʾ��������
    disp('���������б�');
    disp(satellite_names);
end

