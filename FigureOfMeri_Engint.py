# -*- coding: utf-8 -*-
"""
Created on Fri May 24 20:01:29 2024

@author: yfh
"""

from comtypes.gen import STKObjects, STKUtil, AgStkGatorLib  # 从生成的库中获取STK的相关函数
from comtypes.client import CreateObject, GetActiveObject, GetEvents, CoGetObject, ShowEvents # 导入生成和获取物体的库

from datetime import datetime, timedelta
import win32com.client



useStkEngine = True  # 是否需要使用STK Engine
Read_Scenario = False # 是否需要读场景？若为False则新建一个场景

if useStkEngine:  # 如果使用STK Engine
    # Launch STK Engine
    print("Launching STK Engine...")
    uiApplication = CreateObject("STKX11.Application")

    # Disable graphics. The NoGraphics property must be set to true before the root object is created.
    uiApplication.NoGraphics = True

    # Create root object
    root = CreateObject('AgStkObjects11.AgStkObjectRoot')

else:  # 使用STK GUI界面
    # Launch GUI
    print("Launching STK...")
    if not Read_Scenario:  # 如果需要新建场景
        uiApplication = CreateObject("STK11.Application")
    else:  # 获取当前场景
        uiApplication = GetActiveObject("STK11.Application")
    uiApplication.Visible = True # 可以看到GUI见面
    uiApplication.UserControl = True  # 可以用鼠标和STK GUI交互

    # Get root object
    root = uiApplication.Personality2  # 获取root物体，很重要，所有的物体都是root的子物体





#uiApplication = CreateObject("STK11.Application")

# uiApplication.Visible = True

# uiApplication.UserControl = True

# root = uiApplication.Personality2

root.NewScenario("python_star")

scenario = root.CurrentScenario

scenario2 = scenario.QueryInterface(STKObjects.IAgScenario)




def create_set_state_command(object_path, propagator, start_time, end_time, step_size, coord_system, orbit_epoch, semi_major_axis, eccentricity, inclination, arg_of_perigee, raan, mean_anom, coord_epoch=None):
    # 构建基础命令
    command = f'SetState {object_path} {propagator} "{start_time}" "{end_time}" {step_size} {coord_system} "{orbit_epoch}"'
    # 添加轨道参数
    orbit_params = f'{semi_major_axis} {eccentricity} {inclination} {arg_of_perigee} {raan} {mean_anom}'
    # 检查是否需要添加坐标轴纪元
    if coord_epoch:
        command += f' "{coord_epoch}"'
    # 完整命令
    command += f' {orbit_params}'
    return command




# 定义时间
start_time = "1 Nov 2024 01:02:00.00"
end_time = "2 Nov 2024 03:04:00.00"

# 使用ExecuteCommand方法执行Connect命令
command_str = f'SetAnalysisTimePeriod * "{start_time}" "{end_time}"'
root.ExecuteCommand(command_str)
 



#root.Rewind()


target = scenario.Children.New(STKObjects.eTarget , "GroundTarget");
target2 = target.QueryInterface(STKObjects.IAgTarget)


# weidu jindu  gaodu 
target2.Position.AssignGeodetic(29.57,106.529,0)


satellite = scenario.Children.New(STKObjects.eSatellite,"LeoSat")

object_path = "*/Satellite/LeoSat"
propagator = "Classical TwoBody"

# 卫星仿真的时间，与场景时间没关系，
start_time1 =start_time
end_time1 = end_time

#卫星的轨迹计算步长
step_size = "60"
coord_system = "ICRF"
orbit_epoch = "1 Nov 2024 02:02:00.00"
semi_major_axis = "7200008.0"
eccentricity = "0.0"
inclination = "50"
arg_of_perigee = "0.0"
raan = "10.0"
mean_anom = "320.0"
coord_epoch = None  # 如果需要，添加此参数

command_str = create_set_state_command(object_path, propagator, start_time1, end_time1, step_size, coord_system, orbit_epoch, semi_major_axis, eccentricity, inclination, arg_of_perigee, raan, mean_anom, coord_epoch)

#command_str = f'SetState */Satellite/LeoSat Classical TwoBody "{start_time}" "{end_time}" 60 ICRF "{start_time}" 7200008.0 0.0 90 0.0 0.0 0.0'
root.ExecuteCommand(command_str)



 

constellation = scenario.Children.New(STKObjects.eConstellation, "test")


constellation_interface = constellation.QueryInterface(STKObjects.IAgConstellation)

#constellation_interface.Objects.Add("Satellite/LeoSat")


sensor = satellite.Children.New(STKObjects.eSensor, "Mysensor")
sensor2 = sensor.QueryInterface(STKObjects.IAgSensor)


sensor2.SetPatternType(STKObjects.eSnSimpleConic)
sensor2.CommonTasks.SetPatternSimpleConic(15.0, 5.0)  


# add sensor to constellation
command_str = 'Chains */Constellation/test Add */Satellite/LeoSat/Sensor/Mysensor'

root.ExecuteCommand(command_str)


# walker_command = 'Walker */Satellite/LeoSat Type Custom NumPlanes 2 NumSatsPerPlane 2 InterPlaneTrueAnomalyIncrement 0.0 RAANIncrement 60.0'
# root.ExecuteCommand(walker_command)
def create_walker_constellation(root, seed_satellite_path, num_planes, num_sats_per_plane, true_anomaly_increment, raan_increment):
    # 构建Walker星座命令
    walker_command = (
        f'Walker {seed_satellite_path} Type Custom NumPlanes {num_planes} '
        f'NumSatsPerPlane {num_sats_per_plane} '
        f'InterPlaneTrueAnomalyIncrement {true_anomaly_increment} '
        f'RAANIncrement {raan_increment}'
    )
    # 执行Walker星座命令
    root.ExecuteCommand(walker_command)
    print("Walker constellation created successfully.")
    
create_walker_constellation(root, "*/Satellite/LeoSat", 6, 18, 0.0, 30.0)





def get_satellite_names(scenario):
    """
    获取场景中的卫星名称列表。

    参数：
    - scenario: 场景对象

    返回值：
    - 卫星名称列表
    """
    satellite_names = []
    for child in scenario.Children:
        if child.ClassName == 'Satellite':
            satellite_names.append(child.InstanceName)
    return satellite_names


def add_sensors_to_constellation(root, satellite_names, constellation):
    """
    根据给定的卫星名称列表，将传感器添加到指定星座中。
    
    参数：
    - root: STK根对象
    - satellite_names: 卫星名称列表，不包括第一个卫星
    - constellation: 要添加传感器的星座对象
    
    返回值：
    无
    """
    # 构建命令并添加传感器到星座中
    for name in satellite_names:  # 遍历卫星名称列表
        command_str = f'Chains */Constellation/{constellation.InstanceName} Add */Satellite/{name}/Sensor/Mysensor'
        root.ExecuteCommand(command_str)
    
    print(f"All satellite sensors have been added to the '{constellation.InstanceName}' constellation.")
    
satellite_names = get_satellite_names(scenario)

processed_satellite_names = satellite_names[1:]


add_sensors_to_constellation(root,processed_satellite_names,constellation)


coverage_name = "MyCoverage"

#覆盖的定义，
coverage_definition = scenario.Children.New(STKObjects.eCoverageDefinition,coverage_name)

coverage_definition2 = coverage_definition.QueryInterface(STKObjects.IAgCoverageDefinition)

grid = coverage_definition2.Grid

grid.BoundsType = STKObjects.eBoundsLatLonRegion  # 设置边界类型为经纬度

bounds = grid.Bounds.QueryInterface(STKObjects.IAgCvBoundsLatLonRegion)
bounds.MinLatitude = 24  # 设置最小纬度
bounds.MaxLatitude = 46  # 设置最大纬度
bounds.MinLongitude = 75  # 设置最小经度
bounds.MaxLongitude = 127  # 设置最大经度


grid.ResolutionType = STKObjects.eResolutionLatLon

Resolution = grid.Resolution.QueryInterface(STKObjects.IAgCvResolutionLatLon)
Resolution.LatLon = 1



assets = coverage_definition2.AssetList.QueryInterface(STKObjects.IAgCvAssetListCollection)
assets.Add("Constellation/test")


coverage_definition2.ComputeAccesses()

fom_name =  "MyFOM"
figure_of_merit = coverage_definition.Children.New(STKObjects.eFigureOfMerit,fom_name)


figure_of_merit2 = figure_of_merit.QueryInterface(STKObjects.IAgFigureOfMerit)

figure_of_merit2.SetDefinitionType(STKObjects.eFmNumberOfAccesses)

command_str = f'Cov  */CoverageDefinition/{coverage_name}/FigureOfMerit/{fom_name} FOMDefine   Satisfaction GreaterThan 0  '

root.ExecuteCommand(command_str)
grid_inspector = figure_of_merit2.GridInspector.QueryInterface(STKObjects.IAgFmGridInspector)
grid_inspector.SelectPoint(29.57, 106.529)



point_fom_provider = grid_inspector.PointFOM.QueryInterface(STKObjects.IAgDataPrvTimeVar)

point_fom_result = point_fom_provider.ExecSingle(start_time)




# root.ExecuteCommand('Cov */CoverageDefinition/MyCoverage Grid PointGranularity LatLon 5')

# root.ExecuteCommand('Cov */CoverageDefinition/MyCoverage Grid AreaOfInterest LatBounds 20 33')


## 下述代码成功生成相应的文件
fom_name = "MyFOM"
report_style = "My Styles/mystyle"
file_path = "E:/STK_file/python/newsats/Report.txt"  # 使用正斜杠而不是反斜杠


time_step = 60  # 单位：秒

# 构建ReportCreate命令
command = (f'ReportCreate */CoverageDefinition/{coverage_name}/FigureOfMerit/{fom_name} Type Save '
           f'Style "{report_style}" File "{file_path}" '
           f'TimePeriod "{start_time}" "{end_time}" '
           f'TimeStep {time_step}')


root.ExecuteCommand(command)



if useStkEngine: 

     uiApplication.Terminate()
     uiApplication=None
     root=None
    

else:
    print()

   


