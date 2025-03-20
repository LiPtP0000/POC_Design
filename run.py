import subprocess
import os

# 定义 Verilog 源文件
verilog_files = ["poc.v", "printer.v", "processor.v", "top.v", "tb.v"]
iverilog_output = "tb.out"
vcd_file = "poc.vcd"

def run_command(command):
    """执行 shell 命令，并输出执行结果"""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}")
        exit(1)

# 1. 编译 Verilog 代码
compile_cmd = f"iverilog -o {iverilog_output} " + " ".join(verilog_files)
print(f"Compiling Verilog files: {compile_cmd}")
run_command(compile_cmd)

# 2. 运行仿真
sim_cmd = f"vvp {iverilog_output}"
print(f"Running simulation: {sim_cmd}")
run_command(sim_cmd)

# 3. 检查 VCD 文件是否生成
if not os.path.exists(vcd_file):
    print(f"Error: {vcd_file} not found. Ensure your testbench generates waveform output.")
    exit(1)

# 4. 打开 GTKWave 查看波形
gtkwave_cmd = f"gtkwave {vcd_file}"
print(f"Opening GTKWave: {gtkwave_cmd}")
subprocess.Popen(gtkwave_cmd, shell=True)  # 非阻塞调用
