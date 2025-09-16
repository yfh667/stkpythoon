uiap = actxserver('STK11.application');
root = uiap.Personality2;
root.NewScenario('exam');
sc = root.CurrentScenario;
sat = sc.Children.New(18,'mysat');
sat.Propagator.Propagate;

centerptsat = sat.vgt.Points.Item('Center');
centerptsun = root.CentralBodies.Sun.vgt.Points.Item('Center');
centerptearth = root.CentralBodies.Earth.vgt.Points.Item('Center');

sat2sun_v = sat.vgt.Vectors.Factory.CreateDisplacementVector('sat2sun_v',centerptsat,centerptsun);
sat2earth_v = sat.vgt.Vectors.Factory.CreateDisplacementVector('sat2earth_v',centerptsat,centerptearth);

bw_angle = sat.vgt.Angles.Factory.Create('sunsatearth_a','','eCrdnAngleTypeBetweenVectors');
bw_angle.FromVector.SetVector(sat2sun_v);
bw_angle.ToVector.SetVector(sat2earth_v);



%�����ȡ�½��Ƕ�sunsatearth������
angleDP = sat.DataProviders.Item('Angles').Group.Item('sunsatearth_a').Exec(sc.StartTime,sc.StopTime,60);
angledata = cell2mat(angleDP.DataSets.GetDataSetByName('Angle').GetValues);
 
 
dp = sat.DataProviders.Item('Angles');

satelliteDP3 = dp.Group.Item('sunsatearth_a')


% ���� "AZ_QF" �� TimeVar
 

startTime = sc.StartTime;
stopTime  = sc.StopTime;
timeStep  = 60;  % 60��

% ��Ҫ���У����磺Time��Angle��AngleRate
 

% ִ�в�ѯ
drResult = satelliteDP3.Exec(startTime, stopTime, timeStep);
da = drResult.DataSets.GetDataSetByName('Angle').GetValues


