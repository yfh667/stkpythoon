function F = calculateT()
    % PERIODANALYSIS ʱ���������ڷ������߰��������棩
    
    % ========================
    % ����������
    % ========================
    F.Preprocess = @Preprocess;
    F.AutoCorr = @AutoCorr;
    F.FFTMethod = @FFTMethod;
    F.Visualize = @Visualize;
    F.DebugPlot = @DebugPlot; % �������Ի�ͼ
    
    % ========================
    % �Ӻ�������
    % ========================
    
    function [time_num, data_clean] = Preprocess(data_table)
        % ����Ԥ������ǿ�쳣��⣩
        try
            % ��������ṹ
            if ~all(ismember({'Time','AngleRate'}, data_table.Properties.VariableNames))
                error('�����ȱ�ٱ�Ҫ��');
            end
            
            % ת��ʱ���ʽ
            time_cells = data_table.Time;
            time_vec = datetime(time_cells,...
                'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS',...
                'Locale', 'en_US');
            
            % �������ʱ�䣨�룩�����������
            time_num = seconds(time_vec - time_vec(1));
            time_diff = diff(time_num);
            if std(time_diff) > 1e-3
                warning('�Ǿ��Ȳ����������ز���');
                % �Զ��ز�����ƽ��������
                Fs = 1/mean(time_diff);
                new_time = (0:1/Fs:time_num(end))';
                data_clean = interp1(time_num, data_table.AngleRate, new_time, 'spline');
                time_num = new_time;
            else
                data_clean = data_table.AngleRate;
            end
            
            % ������ϴ
            data_clean = fillmissing(data_clean, 'linear');
            data_clean = detrend(data_clean);
            
        catch ME
            error('Ԥ����ʧ��: %s', ME.message);
        end
    end

    function [period, lags, acf] = AutoCorr(data, Fs)
        % ����ط����������棩
        N = length(data);
        data = data - mean(data);
        
        % ����������ؼ���
        lags = (0:N-1)';
        acf = arrayfun(@(k) sum(data(1:N-k).*data(1+k:N))/(N-k), lags);
        acf = acf / acf(1); % ��һ��
        
        % �Ľ���ֵ���
        [pks,locs] = findpeaks(acf(2:end)); % �������ͺ�
        if ~isempty(pks)
            valid = pks > 0.3*max(pks); % ���˴�Ҫ��ֵ
            if any(valid)
                [~,idx] = max(pks(valid));
                period = lags(locs(idx)+1)/Fs;
                return;
            end
        end
        period = NaN;
    end

    function [period, freqs, amp] = FFTMethod(data, Fs)
        % FFT�����������棩
        N = length(data);
        NFFT = 2^nextpow2(N); % �Ż�FFT����
        
        fft_data = fft(data - mean(data), NFFT);
        freqs = Fs/2*linspace(0,1,NFFT/2+1);
        amp = 2*abs(fft_data(1:NFFT/2+1))/N;
        
        % �ų�ֱ������
        [~,idx] = max(amp(2:end));
        period = 1/freqs(idx+1);
    end

    function Visualize(time, data, period)
        % ���ӻ�����ǿ�棩
        figure('Position',[100 100 1000 800])
        
        % ԭʼ����
        subplot(3,1,1)
        plot(time, data)
        title(sprintf('Ԥ�������� (��������: %.1f��)',period))
        xlabel('ʱ�� (��)')
        ylabel('AngleRate')
        grid on
        
        % �ֲ��Ŵ�
        subplot(3,1,2)
        if ~isnan(period) && period < max(time)
            xlim([0 3*period])
        else
            xlim([0 time(end)/10])
        end
        hold on
        plot(time, data)
        if ~isnan(period)
            xline(period, 'r--', 'LineWidth',1.5)
        end
        title('�ֲ��Ŵ�')
        grid on
        
        % ���ݷֲ�
        subplot(3,1,3)
        histogram(data, 50)
        title('���ݷֲ�')
        xlabel('AngleRate')
        ylabel('Ƶ��')
        grid on
    end

    function DebugPlot(data, Fs, acf, freqs, amp)
        % ���Ի�ͼ
        figure('Position',[200 200 1200 500])
        
        subplot(1,2,1)
        plot((0:length(acf)-1)/Fs, acf)
        title('����غ���')
        xlabel('�ͺ� (��)')
        ylabel('ACF')
        grid on
        
        subplot(1,2,2)
        plot(freqs, amp)
        set(gca, 'XScale', 'log')
        title('������')
        xlabel('Ƶ�� (Hz)')
        ylabel('����')
        grid on
    end
end
