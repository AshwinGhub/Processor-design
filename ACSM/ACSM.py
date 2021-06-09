#08 June
import time
import os
import re
import subprocess
import shutil
from shutil import copyfile
from Assembler import* 

DIR="C:/modeltech64_10.5/examples/SAC/Instructions"
PM_LOCATE="C:/modeltech64_10.5/examples/memory_files/pm_file.txt"
DM_LOCATE="C:/modeltech64_10.5/examples/memory_files/dm_file.txt"
DMrdfl_LOCATE="C:/modeltech64_10.5/examples/SAC/DMrd_files/"
MEMfail_LOCATE="C:/modeltech64_10.5/examples/SAC/MEMfail_files/"

idntfr="_"
avoid=['dm_file.txt','pm_file.txt']

def flmdfy(idnt,floc,xtr,ofst,choice):
    with open(floc, "r+") as f:
        data = f.read()
        if choice:
            n_data=data[:data.index(idnt)+ofst]+xtr+data[data.index(idnt)+ofst:]
        else:
            n_data=data[:data.index(idnt)+ofst-2]+data[data.index(idnt)+ofst:]
        f.seek(0)
        f.write(n_data)
        f.truncate()
def assembler(INST_LOCATE):
    print(INST_LOCATE+"\n")
    g=open(INST_LOCATE,"rt")
    f=open(PM_LOCATE,"wt")
    f.write(format(int(16*"1"+16*"0",2),"08X")+"\n")
    l=[]
    for i in g:
        l.append(i.strip("\n"))
    i=0
    while(i<len(l)):
        instr=l[i]
        i=i+1
        if(re.match(".memcheck[ ]?",instr.lower())):
            break
        if(re.match(".CALL[ ]?[(][ ]?[0-9,A-F]+[ ]?[)][ ]?",instr.upper())):
            f.write(format(int(16*"1"+format(int(re.findall("[0-9,A-F]+",instr)[1],16),"016b"),2),"08X")+"\n")
            instr=l[i]
            i=i+1
            if(re.match(".memcheck[ ]?",instr.lower())):
                break
        if("#" in instr):
            inst = re.split("#",instr)[0]
            if(re.match("^[ ]*#",instr)):
                continue
        elif("/*" in instr):
            inst = instr.split("/")[0]
            if(re.match("^[/][*]",instr)):
                while("*/" not in instr):
                    instr=l[i]
                    i=i+1
                continue
        else:
            inst = instr
        if(len(inst)>2 and inst!=" " and inst!="\n" and inst!="\t" and inst!=""):
            OpCode=Primary(inst)
        else:
            continue
        if("ERROR" in OpCode):
            print("Faulty instruction : {}\nAt location: {}\n".format(instr,INST_LOCATE))
            f.close()
            g.close()
            return 0   
        else:
            f.write(format(int(OpCode,2),"08X"))
            f.write("\n")
        if("/*" in instr):
            while("*/" not in instr):
                instr=l[i]
                i=i+1
    f.close()
    g.close()
    return 1
def comple():
    comp= subprocess.run("vlog BUSCONNECT_top.v CORE_top.v cu_alu.v cu_mul.v cu_mul_rnd.v cu_mul_sat.v cu_rf.v cu_shf.v CU_top.v cu_xb.v DAG_top.v MEM_top.v ps_bc_select_control.v ps_cmpt_decode.v ps_cond_decode.v PS_top.v ps_ureg_inst_dcd.v test_core.v", capture_output=True, text=True)
    error=(comp.stdout).replace(' ', '').replace('\t','').replace('\n','').strip()
    if(error.find('Errors:0')==-1):
        return 0
    else:
        return 1
def memchk(MEM_LOCATE):
    find=".memcheck"
    mem_file=open(MEM_LOCATE,'r')
    dm_file=open(DM_LOCATE,'r')
    tlines = [line.replace(' ', '').replace('\t','').strip() for line in mem_file.readlines()]
    dlines = [line.replace(' ', '').replace('\t','').strip() for line in dm_file.readlines()]
    slines=list(filter(None,[x.lower() for x in tlines[[line.lower() for line in tlines].index(find)+1:]]))
    if not len(set(slines)-set(dlines)):
        return 0
    else:
        return 1
file_count=0
valid_count=0
fail_afile=[]
fail_mfile=[]
cmnt="//"
frd="/*"
bck="*/"
flmdfy("$system","test_core.v",cmnt,0,1)
try:
    shutil.rmtree(MEMfail_LOCATE)
except Exception as e:
    print(e)
os.makedirs(MEMfail_LOCATE)
if(comple()):
    for root,directories,files in os.walk(DIR):	
        for name in files:	    
            if not name in avoid:
                file_count+=1
                if assembler(os.path.join(root,name)):
                    valid_count+=1
                    print("File No. "+ str(file_count))
                    if(name[0]==idntfr):
                        flmdfy("file=$fopen(DM_LOCATE,\"w\");\n			$fclose(file);","MEM_top.v",frd,0,1)
                        flmdfy("file=$fopen(DM_LOCATE,\"w\");\n			$fclose(file);","MEM_top.v",bck,45,1)
                        comple()
                        copyfile(DMrdfl_LOCATE+name,DM_LOCATE)
                    subprocess.run("vsim -novopt -c -do \"run -all ; quit\" test_core")
                    if memchk(os.path.join(root,name)):
                        fail_mfile.append(os.path.join(root,name))
                        copyfile(DM_LOCATE,MEMfail_LOCATE+"DMfail_"+re.split(r'/|\\',os.path.join(root,name))[-2]+"_"+name)
                    if(name[0]==idntfr):
                        flmdfy("file=$fopen(DM_LOCATE,\"w\");\n			$fclose(file);","MEM_top.v",bck,47,0)
                        flmdfy("file=$fopen(DM_LOCATE,\"w\");\n			$fclose(file);","MEM_top.v",frd,0,0)
                        comple()
                else:
                    fail_afile.append(os.path.join(root,name))
    print("{} No. out of {} files ran successfully".format(valid_count,file_count))
    if(file_count!=valid_count): print("\n\nFailed Files due to faulty instructions : ", *fail_afile, sep="\n")
    if(len(fail_mfile)): 
        print("\n\nFailed Files due to memcheck data mismatch : ", *fail_mfile, sep="\n")
    else:
        print("\n\nAll tests successfully passed in MEMCHECK\n")
else:
    print("Compilation Error, bye bye!!")
flmdfy("$system","test_core.v",cmnt,0,0)
os.system('pause')

