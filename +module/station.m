function F = Station
   F.Station = @Station;
   F.getStation_names = @getStation_names;
   F.SetStation = @SetStation
end

function station_names = getStation_names(scenario)
    % ��ȡ���������е�������������
    %
    % ������
    %   scenario - STK ��������
    %
    % ���أ�
    %   satellite_names - �������Ƶĵ�Ԫ������

    % ��ȡ���Ǽ���
     stations = scenario.Children.GetElements('eFacility');

    % ��ȡ��������
    numStation = stations.Count;

    % ��ʼ�����������б�
    station_names = {};

    % �������Ǽ���
    for idx = 0:(numStation - 1)  % ������ 0 ��ʼ
        % ������ת��Ϊ��������,����ط��ر���ˣ�Ҫ����
        idx_int = int32(idx);

        % ʹ�� invoke �������� 'Item' ����
         station = invoke(stations, 'Item', idx_int);

        % ��ȡ��������
        staName = station.InstanceName;

        % ������������ӵ������б���
        station_names{end + 1} = staName;
    end

    % ��ʾ��������
    disp('����վ�����б�');
    disp(station_names);
end

function SetStation(root,scenario,name)

%���õ�����ʩ
facility =  scenario.Children.New('eFacility',name);

facility.Position.AssignGeodetic(0.75,101,0);

end
 


