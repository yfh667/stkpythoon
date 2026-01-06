
function save_Station_View_Result_to_xml(filename, Station_View_Result)

    [num_steps, num_stations] = size(Station_View_Result);

    % 1. 创建 XML 文档
    doc = com.mathworks.xml.XMLUtils.createDocument('snapshots');
    root = doc.getDocumentElement;

    % 2. 遍历时间步
    for t = 1:num_steps

        % <time step="t-1">
        timeElem = doc.createElement('time');
        timeElem.setAttribute('step', num2str(t-1));   % 如果你是从 0 开始
        root.appendChild(timeElem);

        % <stations>
        stationsElem = doc.createElement('stations');
        timeElem.appendChild(stationsElem);

        % 3. 遍历站点
        for s = 1:num_stations

            sats = Station_View_Result{t, s};

            if isempty(sats)
                continue
            end

            % <station id="s-1">
            stationElem = doc.createElement('station');
            stationElem.setAttribute('id', num2str(s-1));
            stationsElem.appendChild(stationElem);

            % 4. 遍历可见卫星
            for i = 1:numel(sats)
                satElem = doc.createElement('satellite');
                    sat_id_xml = sats(i) - 1;
                        satElem.setAttribute('id', sprintf('%.1f', double(sat_id_xml)));

    
                stationElem.appendChild(satElem);
            end
        end
    end

    % 5. 写文件
    xmlwrite(filename, doc);
    fprintf('XML 已保存到: %s\n', filename);
end