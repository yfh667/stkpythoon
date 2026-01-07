% 
% function save_Station_View_Result_to_xml(filename, Station_View_Result)
% 
%     [num_steps, num_stations] = size(Station_View_Result);
% 
%     % 1. 创建 XML 文档
%     doc = com.mathworks.xml.XMLUtils.createDocument('snapshots');
%     root = doc.getDocumentElement;
% 
%     % 2. 遍历时间步
%     for t = 1:num_steps
% 
%         % <time step="t-1">
%         timeElem = doc.createElement('time');
%         timeElem.setAttribute('step', num2str(t-1));   % 如果你是从 0 开始
%         root.appendChild(timeElem);
% 
%         % <stations>
%         stationsElem = doc.createElement('stations');
%         timeElem.appendChild(stationsElem);
% 
%         % 3. 遍历站点
%         for s = 1:num_stations
% 
%             sats = Station_View_Result{t, s};
% 
%             if isempty(sats)
%                 continue
%             end
% 
%             % <station id="s-1">
%             stationElem = doc.createElement('station');
%             stationElem.setAttribute('id', num2str(s-1));
%             stationsElem.appendChild(stationElem);
% 
%             % 4. 遍历可见卫星
%             for i = 1:numel(sats)
%                 satElem = doc.createElement('satellite');
%                     sat_id_xml = sats(i) - 1;
%                         satElem.setAttribute('id', sprintf('%.1f', double(sat_id_xml)));
% 
%     
%                 stationElem.appendChild(satElem);
%             end
%         end
%     end
% 
%     % 5. 写文件
%     xmlwrite(filename, doc);
%     fprintf('XML 已保存到: %s\n', filename);
% end


function save_Station_View_Result_to_xml(filename, Station_View_Result)
%SAVE_STATION_VIEW_RESULT_TO_XML Stream-write XML to avoid Java heap OOM.
%
% Station_View_Result: cell array {num_steps, num_stations}
%   each cell contains visible satellite ids (numeric vector)

    [num_steps, num_stations] = size(Station_View_Result);

    % 1) 打开文件（UTF-8）
    fid = fopen(filename, 'w', 'n', 'UTF-8');
    if fid < 0
        error('Cannot open file for writing: %s', filename);
    end

    % 确保异常时也能关闭文件
    c = onCleanup(@() fclose(fid));

    % 2) 写 XML 头与根节点
    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid, '<snapshots>\n');

    % 3) 遍历时间步
    for t = 1:num_steps
        fprintf(fid, '  <time step="%d">\n', t-1);
        fprintf(fid, '    <stations>\n');

        % 4) 遍历站点
        for s = 1:num_stations
            sats = Station_View_Result{t, s};

            if isempty(sats)
                continue;
            end

            % 可选：去重 + 排序（能明显减小 XML 体积，且更稳定）
            % 如果你明确保证 sats 已经是唯一且有序，可以注释掉这两行
            sats = unique(sats(:).');  % 行向量
            % sats = sort(sats);

            fprintf(fid, '      <station id="%d">\n', s-1);

            % 5) 遍历可见卫星
            for i = 1:numel(sats)
                sat_id_xml = sats(i) - 1;

                % 如果 sat_id_xml 可能不是整数，保留原始的 double，但尽量写成无小数
                if isfinite(sat_id_xml) && abs(sat_id_xml - round(sat_id_xml)) < 1e-9
                    satStr = sprintf('%d', round(sat_id_xml));
                else
                    satStr = sprintf('%.15g', double(sat_id_xml));
                end

                fprintf(fid, '        <satellite id="%s"/>\n', xml_escape(satStr));
            end

            fprintf(fid, '      </station>\n');
        end

        fprintf(fid, '    </stations>\n');
        fprintf(fid, '  </time>\n');
    end

    fprintf(fid, '</snapshots>\n');

    % onCleanup 会 fclose
    fprintf('XML 已保存到: %s\n', filename);
end

function s = xml_escape(s)
%XML_ESCAPE Escape XML attribute special chars.
    if ~isstring(s) && ~ischar(s)
        s = string(s);
    end
    s = char(s);
    s = strrep(s, '&', '&amp;');
    s = strrep(s, '"', '&quot;');
    s = strrep(s, '''', '&apos;');
    s = strrep(s, '<', '&lt;');
    s = strrep(s, '>', '&gt;');
end
