import os
from datetime import datetime
import locale
def convert_file(input_file, output_file):
    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        lines = fin.readlines()
        current_locale = locale.getlocale()
        locale.setlocale(locale.LC_TIME, 'en_US.UTF-8')
        # 跳过前7行，从第8行开始处理
        data_lines = lines[1:]

        # 处理第一行以获取初始时间（这里的第一行是数据行的第一行）
        first_line_parts = data_lines[0].split()
        start_datetime_str = ' '.join(first_line_parts[:4])
        # 分割整数秒和小数部分
        if '.' in start_datetime_str:
            date_part, microsecond_part = start_datetime_str.split('.')
            microsecond_part = microsecond_part[:6]  # 截取前6位
            adjusted_str = f"{date_part}.{microsecond_part}"
        else:
            adjusted_str = start_datetime_str

        # 解析调整后的字符串
        start_time = datetime.strptime(adjusted_str, "%d %b %Y %H:%M:%S.%f")


        # 遍历每一行数据
        for line in data_lines:
            parts = line.strip().split()
            if len(parts) < 4:  # 确保行包含足够的数据
                continue

            # 合并日期和时间字符串，并转换为 datetime 对象
            current_datetime_str = ' '.join(parts[:4])

            if '.' in current_datetime_str:
                date_part, microsecond_part = current_datetime_str.split('.')
                microsecond_part = microsecond_part[:6]  # 截取前6位
                adjusted_str = f"{date_part}.{microsecond_part}"
            else:
                adjusted_str = current_datetime_str

            current_time =  datetime.strptime(adjusted_str, "%d %b %Y %H:%M:%S.%f")



            time_diff = current_time - start_time
            seconds_since_start = time_diff.total_seconds()

            # 提取坐标数据并进行单位转换（千米到米）
            coords = [float(part) * 1000 for part in parts[4:7]]
            coords_str = ' '.join(f'{coord:.3f}' for coord in coords)

            # 写入输出文件
            fout.write(f"{int(seconds_since_start)} {coords_str}\n")

folder_path = "E:\\STK_file\\sats"
folder_path_out = "E:\\STK_file\\sats\\modify"

# 调用函数，输入和输出文件路径按需要修改
#convert_file("chidao_fixed.txt", "chidao_fixed_modify.txt")
# for filename in os.listdir(folder_path):
#     if filename.endswith(".txt"):  # 确保处理的是文本文件
#         print(f"filename is {filename}")
#         input_file_path = os.path.join(folder_path, filename)
#         output_file_path = os.path.join(folder_path_out, filename.replace(".txt", "_modify.txt"))

#         # 对每个文件应用转换函数
#         convert_file(input_file_path, output_file_path)
        
        
# 获取文件夹中的所有文件
files = [f for f in os.listdir(folder_path) if f.endswith('.txt')]

# 遍历文件并重新命名
for index, filename in enumerate(files):
  #  new_filename = f"{index + 1}.txt"
    input_file_path = os.path.join(folder_path, filename)
    output_file_path = os.path.join(folder_path_out, filename)
    print(f"finish {filename} ")
    convert_file(input_file_path, output_file_path)
   # os.rename(input_file_path, output_file_path)