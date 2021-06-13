#10th June
import time
import os
import re
import configparser
import subprocess
import sys
from datetime import datetime
import shutil
from shutil import copyfile
from Assembler import* 

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
    try:
        g=open(INST_LOCATE,"rt")
    except Exception as e:
        print(e)
        return 0
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
    try:
        slines=list(filter(None,[x.lower() for x in tlines[[line.lower() for line in tlines].index(find)+1:]]))
        if not len(set(slines)-set(dlines)):
            return 0
        else:
            return 1
    except Exception as e:
        return 1
startTime = datetime.now()
file_count=0
valid_count=0
fail_afile=[]
fail_mfile=[]
cmnt="//"
frd="/*"
bck="*/"
cnfg = configparser.ConfigParser()
cnfg.optionxform = str
cnfg.read('Path.ini')
if cnfg.has_section('PATHS'):
    DIR=cnfg.get('PATHS','DIR',raw=True)
    PM_LOCATE=cnfg.get('PATHS','PM_LOCATE',raw=True)
    DM_LOCATE=cnfg.get('PATHS','DM_LOCATE',raw=True)
    DMrdfl_LOCATE=cnfg.get('PATHS','DMrdfl_LOCATE',raw=True)
    MEMfail_LOCATE=cnfg.get('PATHS','MEMfail_LOCATE',raw=True)
else:
    print("Error! PATHS configurations not found. Run Confiqure_Path.py.")
    os.system('pause')
    sys.exit()
if cnfg.has_section('IDENTIFIER'):
    idntfr=cnfg.get('IDENTIFIER','idntfr',raw=True)
else:
    print("Error! IDENTIFIER configurations not found. Run Confiqure_Path.py.")
    os.system('pause')
    sys.exit()
if cnfg.has_section('AVOID'):
    avoid=cnfg.options('AVOID')
else:
    print("Error! AVOID configurations not found. Run Confiqure_Path.py.")
    os.system('pause')
    sys.exit()
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
                        try:
                            copyfile(os.path.join(DMrdfl_LOCATE,name),DM_LOCATE)
                        except Exception as e:
                            print(e)
                    subprocess.run("vsim -novopt -c -do \"run -all ; quit\" test_core")
                    if memchk(os.path.join(root,name)):
                        fail_mfile.append(os.path.join(root,name))
                        copyfile(DM_LOCATE,os.path.join(MEMfail_LOCATE,"DMfail_"+re.split(r'/|\\',os.path.join(root,name))[-2]+"_"+name))
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
print("\n\nTime Analysis:\nStart time: {}\nStop Time: {}\nTime taken to execute the script: {}".format(startTime,datetime.now(),(datetime.now() - startTime)))
os.system('pause')

