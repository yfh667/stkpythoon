function F = GetPosition
    F.GetPosition = @GetPosition;
      F.GetPositionxyz = @GetPositionxyz;
end

function  GetPositionxyz(root, satellite1_name,starttime,endtime,timestep,pwd)
    % 输入验证
    if nargin < 2
        error('需要提供 root 对象和1个卫星名称。');
    end
       % unique_name_prefix = [satellite1_name];
 
    
    
    % 获取卫星对象
    satellite1 = root.GetObjectFromPath(['Satellite/' satellite1_name]);
 
%  timestep = 1
position = satellite1.DataProviders.Item('Vectors(Fixed)').Group.Item('Position').Exec(starttime,endtime,timestep);


position_x  = position.DataSets.GetDataSetByName('x').GetValues;

position_y  = position.DataSets.GetDataSetByName('y').GetValues;
position_z  = position.DataSets.GetDataSetByName('z').GetValues;


 

position_time  = position.DataSets.GetDataSetByName('Time').GetValues;

 

data_table = table(position_time, position_x,position_y,position_z, 'VariableNames', {'Time', 'x','y','z'});

 
 
writetable(data_table, pwd, 'Delimiter', '\t');
    
    
     
    

    
    
end
  

