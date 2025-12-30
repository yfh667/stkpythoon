try
    % 1. 获取当前正在运行的 STK 应用程序实例
    % 注意：如果你使用的是 STK 11，请将 'STK12.Application' 改为 'STK11.Application'
    app = actxGetRunningServer('STK11.Application');
    
    % 2. 获取根对象 (Root Object)
    % 这一步至关重要，因为所有的指令（如获取场景、添加卫星）都是通过 root 操作的
    root = app.Personality2;
    
    % 3. 检查连接是否成功
    checkScenario = root.CurrentScenario;
    
    if ~isempty(checkScenario)
        fprintf('成功连接到 STK！当前场景名称: %s\n', checkScenario.InstanceName);
        scenario = root.CurrentScenario
    else
        fprintf('成功连接到 STK，但当前没有打开任何场景 (Scenario)。\n');
    end
    
catch err
    fprintf('连接失败。\n');
    fprintf('错误信息: %s\n', err.message);
    fprintf('请确保 STK 已经打开，且版本号（STK11/12）填写正确。\n');
end

  

% open a already opened stk file 