function F = calculateT()
    % PERIODANALYSIS 时间序列周期分析工具包（修正版）
    
    % ========================
    % 主函数容器
    % ========================
    F.Preprocess = @Preprocess;
    F.AutoCorr = @AutoCorr;
    F.FFTMethod = @FFTMethod;
    F.Visualize = @Visualize;
    F.DebugPlot = @DebugPlot; % 新增调试绘图
    
    % ========================
    % 子函数定义
    % ========================
    
    function [time_num, data_clean] = Preprocess(data_table)
        % 数据预处理（增强异常检测）
        try
            % 检查输入表结构
            if ~all(ismember({'Time','AngleRate'}, data_table.Properties.VariableNames))
                error('输入表缺少必要列');
            end
            
            % 转换时间格式
            time_cells = data_table.Time;
            time_vec = datetime(time_cells,...
                'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS',...
                'Locale', 'en_US');
            
            % 计算相对时间（秒）并检查采样间隔
            time_num = seconds(time_vec - time_vec(1));
            time_diff = diff(time_num);
            if std(time_diff) > 1e-3
                warning('非均匀采样，建议重采样');
                % 自动重采样到平均采样率
                Fs = 1/mean(time_diff);
                new_time = (0:1/Fs:time_num(end))';
                data_clean = interp1(time_num, data_table.AngleRate, new_time, 'spline');
                time_num = new_time;
            else
                data_clean = data_table.AngleRate;
            end
            
            % 数据清洗
            data_clean = fillmissing(data_clean, 'linear');
            data_clean = detrend(data_clean);
            
        catch ME
            error('预处理失败: %s', ME.message);
        end
    end

    function [period, lags, acf] = AutoCorr(data, Fs)
        % 自相关分析（修正版）
        N = length(data);
        data = data - mean(data);
        
        % 向量化自相关计算
        lags = (0:N-1)';
        acf = arrayfun(@(k) sum(data(1:N-k).*data(1+k:N))/(N-k), lags);
        acf = acf / acf(1); % 归一化
        
        % 改进峰值检测
        [pks,locs] = findpeaks(acf(2:end)); % 跳过零滞后
        if ~isempty(pks)
            valid = pks > 0.3*max(pks); % 过滤次要峰值
            if any(valid)
                [~,idx] = max(pks(valid));
                period = lags(locs(idx)+1)/Fs;
                return;
            end
        end
        period = NaN;
    end

    function [period, freqs, amp] = FFTMethod(data, Fs)
        % FFT分析（修正版）
        N = length(data);
        NFFT = 2^nextpow2(N); % 优化FFT长度
        
        fft_data = fft(data - mean(data), NFFT);
        freqs = Fs/2*linspace(0,1,NFFT/2+1);
        amp = 2*abs(fft_data(1:NFFT/2+1))/N;
        
        % 排除直流分量
        [~,idx] = max(amp(2:end));
        period = 1/freqs(idx+1);
    end

    function Visualize(time, data, period)
        % 可视化（增强版）
        figure('Position',[100 100 1000 800])
        
        % 原始数据
        subplot(3,1,1)
        plot(time, data)
        title(sprintf('预处理数据 (估计周期: %.1f秒)',period))
        xlabel('时间 (秒)')
        ylabel('AngleRate')
        grid on
        
        % 局部放大
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
        title('局部放大')
        grid on
        
        % 数据分布
        subplot(3,1,3)
        histogram(data, 50)
        title('数据分布')
        xlabel('AngleRate')
        ylabel('频次')
        grid on
    end

    function DebugPlot(data, Fs, acf, freqs, amp)
        % 调试绘图
        figure('Position',[200 200 1200 500])
        
        subplot(1,2,1)
        plot((0:length(acf)-1)/Fs, acf)
        title('自相关函数')
        xlabel('滞后 (秒)')
        ylabel('ACF')
        grid on
        
        subplot(1,2,2)
        plot(freqs, amp)
        set(gca, 'XScale', 'log')
        title('幅度谱')
        xlabel('频率 (Hz)')
        ylabel('幅度')
        grid on
    end
end
