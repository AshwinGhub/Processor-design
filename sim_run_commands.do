vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/BUSCONNECT_top.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_alu.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_mul.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_mul_rnd.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_mul_sat.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_rf.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_shf.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/cu_xb.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/CU_top.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/DAG_top.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/MEM_top.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/PS_top.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/ps_bc_select_control.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/ps_cmpt_decode.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/ps_cond_decode.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/ps_ureg_inst_dcd.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/CORE_top.v
vlog -work work C:/Users/Ashwin-Pradeep/Desktop/Project-Final-Year/GIT-repo/Processor-design/Processor-design/test_core.v
vsim -novopt work.test_core
run 1000
quit -f