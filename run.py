import os
os.system('python assembler.py')
os.system('vsim -batch -do sim_run_commands.do')