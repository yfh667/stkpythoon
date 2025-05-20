 


function F = plot_angular
    F.GetAzimuth = @GetAzimuth;
  F.GetPitch = @GetPitch;
    
end


% ��ȡ��λ�ǣ�Azimuth���ٶ�
function GetAzimuth(root, sats1, sats2, starttime, endtime, timestep)
   
angular = module.stk_angular_velocity()
datatable = angular.GetAzimuth(root, sats1, sats2,starttime, endtime, timestep);
  varNames = datatable.Properties.VariableNames; 
   timeStr = datatable.(varNames{1});
    omega = datatable.(varNames{2});
time = datetime(datatable{:, varNames{1}}, ...
                'InputFormat', 'd MMM yyyy HH:mm:ss.SSSSSSSSS', ...
                'Locale', 'en_US');
    % ����Ǽ��ٶ�
    dt = seconds(diff(time));
alpha = diff(omega) ./ seconds(diff(time));     % �Ǽ��ٶ�
time_alpha = time(2:end);                        % ��Ӧ��ʱ�䣨��һ�㣩
    % ��ͼ
    figure;

    subplot(2,1,1);
    plot(time, omega, '-o');
    ylabel('���ٶ� (deg/s)');
 
    grid on;

    subplot(2,1,2);
    plot(time_alpha, alpha, '-o');
    ylabel('�Ǽ��ٶ� (deg/s?)');
    xlabel('ʱ��');
    title('�Ǽ��ٶȣ�����Ƶ���');
    grid on;
end

function GetPitch(root, sats1, sats2, starttime, endtime, timestep)
   
angular = module.stk_angular_velocity()
datatable = angular.GetPitch(root, sats1, sats2,starttime, endtime, timestep);
  varNames = datatable.Properties.VariableNames; 
   timeStr = datatable.(varNames{1});
    omega = datatable.(varNames{2});
time = datetime(datatable{:, varNames{1}}, ...
                'InputFormat', 'd MMM yyyy HH:mm:ss.SSSSSSSSS', ...
                'Locale', 'en_US');
    % ����Ǽ��ٶ�
    dt = seconds(diff(time));
alpha = diff(omega) ./ seconds(diff(time));     % �Ǽ��ٶ�
time_alpha = time(2:end);                        % ��Ӧ��ʱ�䣨��һ�㣩
    % ��ͼ
    figure;

    subplot(2,1,1);
    plot(time, omega, '-o');
    ylabel('���ٶ� (deg/s)');
 
    grid on;

    subplot(2,1,2);
    plot(time_alpha, alpha, '-o');
    ylabel('�Ǽ��ٶ� (deg/s?)');
    xlabel('ʱ��');
    title('�Ǽ��ٶȣ�����Ƶ���');
    grid on;
end

