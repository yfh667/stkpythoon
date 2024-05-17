from comtypes.gen import STKObjects, STKUtil, AgStkGatorLib  # 从生成的库中获取STK的相关函数
from comtypes.client import CreateObject, GetActiveObject, GetEvents, CoGetObject, ShowEvents # 导入生成和获取物体的库

uiApplication = CreateObject("STK11.Application")

uiApplication.Visible = True

uiApplication.UserControl = True

root = uiApplication.Personality2

root.NewScenario("python_star")

scenario = root.CurrentScenario

scenario2 = scenario.QueryInterface(STKObjects.IAgScenario)


from datetime import datetime, timedelta
import win32com.client


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
 



root.Rewind()


target = scenario.Children.New(STKObjects.eTarget , "GroundTarget");
target2 = target.QueryInterface(STKObjects.IAgTarget)

target2.Position.AssignGeodetic(50,-100,0)


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
raan = "0.0"
mean_anom = "60.0"
coord_epoch = None  # 如果需要，添加此参数

command_str = create_set_state_command(object_path, propagator, start_time1, end_time1, step_size, coord_system, orbit_epoch, semi_major_axis, eccentricity, inclination, arg_of_perigee, raan, mean_anom, coord_epoch)

#command_str = f'SetState */Satellite/LeoSat Classical TwoBody "{start_time}" "{end_time}" 60 ICRF "{start_time}" 7200008.0 0.0 90 0.0 0.0 0.0'
root.ExecuteCommand(command_str)







def create_report_for_satellite(satellite, report_style, file_path, start_time, stop_time, time_step):
    """
    为指定卫星创建报告。
    :param satellite: 卫星对象，自动从中提取实例名来构建路径
    :param report_style: 报告样式
    :param file_path: 报告文件保存路径
    :param start_time: 报告开始时间
    :param stop_time: 报告结束时间
    :param time_step: 时间步长
    """
    # 获取卫星的完整路径
    satellite_path = f"*/Satellite/{satellite.InstanceName}"

    # 构建ReportCreate命令
    command = f'ReportCreate {satellite_path} Type Save Style "{report_style}" File "{file_path}" TimePeriod "{start_time}" "{stop_time}" TimeStep {time_step}'

    # 执行命令
    root.ExecuteCommand(command)

# 示例调用
sat_list = root.CurrentScenario.Children.GetElements(STKObjects.eSatellite)
satellite = sat_list[0]

create_report_for_satellite(
    satellite=satellite,
    report_style="My Styles/fixed",
    file_path=r"E:\\STK_file\\python\\newsats\\newsats.txt",  # 使用原始字符串或双反斜杠
    start_time="1 Nov 2024 01:02:00.00",
    stop_time="2 Nov 2024 03:04:00.00",
    time_step="60.0"
)
