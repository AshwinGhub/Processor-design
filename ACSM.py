#08 June
import time
import os
import re
import subprocess
from shutil import copyfile

DIR="C:/modeltech64_10.5/examples/SAC/Instructions"
PM_LOCATE="C:/modeltech64_10.5/examples/memory_files/pm_file.txt"
DM_LOCATE="C:/modeltech64_10.5/examples/memory_files/dm_file.txt"
DMrdfl_LOCATE="C:/modeltech64_10.5/examples/SAC/DMrd_files/"

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
def HextoBin(hnum):
    bnum = format(int(hnum,16),'016b')
    return bnum
def conditions(cond):
    switch = {
    "00000":"00000",
    "EQ":"00000",
    "LT":"00001",
    "LE":"00010",
    "AC":"00011",
    "AV":"00100",
    "MV":"01000",
    "MS":"01001",
    "SV":"01010",
    "SZ":"01011",
    "NE":"10000",
    "GE":"10001",
    "GT":"10010",
    "NOT AC":"10011",
    "NOT AV":"10100",
    "NOT MV":"11000",
    "NOT MS":"11001",
    "NOT SV":"11010",
    "NOT SZ":"11011",
    "FOREVER":"11111",
    }
    return switch.get(cond,"EROR")
def BinAdd(bnum1,bnum2):
    return (format(int(bnum1,2)+int(bnum2),'08b'))
def RegAddr(reg):
    if(reg[1:].isnumeric()):
        num=int(reg[1:])
    switch = {
        'R':"00000000",
        'I':"00010000",
        'M':"00100000"
    }
    if(re.match("[R,I,M,L,B][0-9]+",reg) and num<16):
        return BinAdd(switch.get(reg[0],"ERROR"),reg[1:])
    else:
        switch = {
            "FADDR":"01100000",
            "DADDR":"01100001",
            "PC":"01100011",
            "PCSTK":"01100100",
            "PCSTKP":"01100101",
            "LADDR":"01100110",
            "CURLCNTR":"01100111",
            "LCNTR":"01101000",
            "USTAT1":"01110000",
            "USTAT2":"01110001",
            "IRPTL":"01111001",
            "MODE2":"01111010",
            "MODE1":"01111011",
            "ASTAT":"01111100",
            "IMASK":"01111101",
            "STKY":"01111110",
            "IMASKP":"01111111"
        }
        return switch.get(reg,"0000EROR")
def register(reg):
    reg = reg.upper()
    if(reg[0]==" "):
        reg=reg[1:]
    if(reg[-1]==" "):
        reg=reg[0:-1]
    reg = RegAddr(reg)
    if("ERROR" in reg):
        return "0000EROR"
    else:
        return reg
def signed(x):
    switch={
        "S":"1",
        "U":"0",
        "I":"0",
        "F":"1",
        "R":"1"
    }
    sign="0000"
    if(("SR" in x) or ("UR" in x) or ("IR" in x)):
        return "EROR"
    if(re.match("[S,U][S,U]?[I,F][R]?",x)):
        if("R" in x):
            sign=sign[0:3]+switch.get("R")
        if(x[1]=="I" or x[1]=="F"):
            sign=sign[0]+switch.get(x[0])+switch.get(x[1])+sign[3]
        else:
            sign=switch.get(x[1])+switch.get(x[0])+switch.get(x[2])+sign[3]
    return sign
def compute(com):
    Comp_code=""
    R=["0000","0000","0000"]
    sign=signed(com.split(" ")[-1])
    if(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?[+][ ]?R[0-9]+[ ]?[+][ ]?CI[ ]?",com)):
        Comp_code = "000000010"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?-[ ]?R[0-9]+[ ]?[+][ ]?CI[ ]*-[ ]?1[ ]?",com)):
        Comp_code = "000000011"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?[+][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000000000"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?-[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000000001"
    elif(re.match("COMP[ ]?[(][ ]?R[0-9]+[ ]?,[ ]?R[0-9]+[ ]?[)][ ]?",com)):
        Comp_code = "000000101"
    elif(re.match("R[0-9]+[ ]?=[ ]?MIN[ ]?[(][ ]?R[0-9]+[ ]?,[ ]?R[0-9]+[ ]?[)][ ]?",com)):
        Comp_code = "000001001"
    elif(re.match("R[0-9]+[ ]?=[ ]?MAX[ ]?[(][ ]?R[0-9]+[ ]?,[ ]?R[0-9]+[ ]?[)][ ]?",com)):
        Comp_code = "000001011"
    elif(re.match("R[0-9]+[ ]?=[ ]?-[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000010001"
    elif(re.match("R[0-9]+[ ]?=[ ]?ABS[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000011001"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?AND[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000100000"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?OR[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000100001"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?XOR[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000100010"
    elif(re.match("R[0-9]+[ ]?=[ ]?REG_AND[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000110000"
    elif(re.match("R[0-9]+[ ]?=[ ]?REG_OR[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000110001"
    elif(re.match("R[0-9]+[ ]?=[ ]?NOT[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "000111000"
    elif(re.match("R[0-9]+[ ]?=[ ]?MR[0,1,2][ ]?",com)):
        Comp_code = "01000"+sign
        if("MR0" in com):
            R[2]="0000"
        elif("MR1" in com):
            R[2]="0001"
        else:
            R[2]="0010"
    elif(re.match("R[0-9]+[ ]?=[ ]?SAT MR",com)):
        Comp_code = "01000"+sign
        R[2]="0011"
    elif(re.match("MR[0,1,2][ ]?=[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01001"+sign
        if("MR0" in com):
            R[2]="0000"
        elif("MR1" in com):
            R[2]="0001"
        else:
            R[2]="0010"
    elif(re.match("MR[ ]?=[ ]?SAT MR",com)):
        Comp_code = "01001"+sign
        R[2]="0011"
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?[*][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01010"+sign
    elif(re.match("MR[ ]?=[ ]?R[0-9]+[ ]?[*][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01011"+sign
    elif(re.match("R[0-9]+[ ]?=[ ]?MR[ ]?[+][ ]?R[0-9]+[ ]?[*][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01100"+sign
    elif(re.match("MR[ ]?=[ ]?MR[ ]?[+][ ]?R[0-9]+[ ]?[*][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01101"+sign
    elif(re.match("R[0-9]+[ ]?=[ ]?MR[ ]?-[ ]?R[0-9]+[ ]?[*][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01110"+sign
    elif(re.match("MR[ ]?=[ ]?MR[ ]?-[ ]?R[0-9]+[ ]?[*][ ]?R[0-9]+[ ]?",com)):
        Comp_code = "01111"+sign
    elif(re.match("R[0-9]+[ ]?=[ ]?ASHIFT[ ]?R[0-9]+[ ]?BY[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "100000000"
    elif(re.match("R[0-9]+[ ]?=[ ]?ROT[ ]?R[0-9]+[ ]?BY[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "100001000"
    elif(re.match("R[0-9]+[ ]?=[ ]?LEFTZ[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "100010000"
    elif(re.match("R[0-9]+[ ]?=[ ]?LEFTO[ ]?R[0-9]+[ ]?",com)):
        Comp_code = "100011000"
    else:
        Comp_code = "EROR"
    reg=re.findall("R[0-9][0-9]?",com)
    if(Comp_code!="000000101" and Comp_code!="01111"+sign and Comp_code!="01011"+sign and Comp_code!="01101"+sign and Comp_code!="EROR"):
        for i in range(len(reg)):
            R[i]=register(reg[i])[4:]
    else:
        for i in range(len(reg)):
            R[i+1]=register(reg[i])[4:]
    if(Comp_code=="01000"+sign):
        R[1]="0000"
    if(Comp_code=="01001"+sign):
        R[0]="0000"
    Comp_code = Comp_code+R[0]+R[1]+R[2]
    if("EROR" in Comp_code):
        return "EROR"
    else:
        return Comp_code
ur1="^[ ]?[A,C,D,F,I,L,M,P,S,U][A,C,M,O,R,S,T,U][A,D,I,K,N,R,S,T]?[A,D,E,L,S,T,Y]?[C,K,L,R,T,1,2]?[N,P,1,2]?[T]?[R]?[ ]?$"
d="^[ ]?DM[ ]?[(][ ]?I[0-7][ ]?,[ ]?M[0-7][ ]?[)][ ]?$"
def Primary(x):
    OpCode = "00000000000000000000000000000000"
    x=x.upper()
    while(x[-1]==" " or x[-1]=="\t"):
        x=x[0:-1]
    if(x=="NOP"):
        OpCode = "00000000000000000000000000000000"
    elif(x=="IDLE"):
        OpCode = OpCode[:8]+"1"+OpCode[9:]
    elif(x=="RTS"):
        OpCode = OpCode[0:7]+"1"+OpCode[8:]
    elif(x=="FINISH"):
        OpCode = OpCode[0:9]+"1"+OpCode[10:]
    elif(re.match("^PUSH[ ]+PCSTK[ ]?$",x.split("=")[0])):
        OpCode = OpCode[:6]+"10"+register(x.split("=")[-1])+OpCode[16:]
    elif(re.match("^[ ]?POP[ ]+PCSTK[ ]?",x.split("=")[-1])):
        temp=x.split("=")[0]
        if(("FADDR" in temp) or ("DADDR" in temp) or (re.match("^[ ]?PC[ ]?$",temp)) or ("STKY" in temp) or ("PCSTKP" in temp)):
            OpCode="ERROR"
        else:
            OpCode = OpCode[:6]+"11"+register(x.split("=")[0])+OpCode[16:]
    elif(re.match("^[ ]?[0-9,A-F]?[0-9,A-F]?[0-9,A-F]?[0-9,A-F]?[ ]?$",x.split("=")[-1])):
        temp=x.split("=")[0]
        if(("FADDR" in temp) or ("DADDR" in temp) or (re.match("^[ ]?PC[ ]?$",temp)) or ("STKY" in temp) or ("PCSTKP" in temp)):
            OpCode="ERROR"
        else:
            OpCode = OpCode[:4]+"1100"+register(x.split("=")[0])+HextoBin(re.findall("[0-9,A-F]+",x.split("=")[-1])[0])
    else:
        condition="00000"
        if(re.match("^IF",x)):
            OpCode="1"+OpCode[1:]
            x=x[3:]
        if(re.match("^NOT [A-Z][A-Z]",x)):
            condition=x[0:6]
            x=x[7:]
        elif(re.match("^FOREVER",x)):
            condition=x[0:7]
            x=x[8:]
        elif(re.match("^[E,L,A,M,S,N,G][C,E,Q,S,T,V,Z]",x) and ("ASTAT" not in x) and ("STKY" not in x) and ("LCNTR" not in x)):
            condition=x[0:2]
            x=x[3:]
        if(re.match("[R,I,M][0-9]+[ ]?=[ ]?[R,I,M][0-9]+[ ]?$",x)):
            OpCode=OpCode[0]+"0000100"+register(re.findall("[R,I,M,L,B][0-9]+",x)[0])+register(re.findall("[R,I,M,L,B][0-9]+",x)[1])+"000"+conditions(condition)
        elif((re.match(ur1,x.split("=")[0]) or re.match(ur1,x.split("=")[-1])) and (not re.match("^MR[0,1,2]?[ ]?$",x.split("=")[0]))and (not re.match("^MR[0,1,2]?[ ]?$",x.split("=")[-1])) and (not re.match(d,x.split("=")[0])) and (not re.match(d,x.split("=")[-1]))):
            temp=x.split("=")[0]
            if(("FADDR" in temp) or ("DADDR" in temp) or (re.match("^[ ]?PC[ ]?$",temp)) or ("STKY" in temp) or ("PCSTKP" in temp)):
                OpCode="ERROR"
            else:
                OpCode=OpCode[0]+"0000100"+register(x.split("=")[0])+register(x.split("=")[-1])+"000"+conditions(condition)
        elif(re.match("^DM[ ]?[(][ ]?I[0-7][ ]?,[ ]?M[0-7][ ]?[)][ ]?$",x.split("=")[0])):
            OpCode=OpCode[0]+"0100100"+register(x.split("=")[-1])+"000"+register(re.findall("I[0-7]",x.split("=")[0])[0])[5:]+register(re.findall("M[0-7]",x.split("=")[0])[0])[5:]+"10"+conditions(condition)
        elif(re.match("^[ ]?DM[ ]?[(][ ]?I[0-7][ ]?,[ ]?M[0-7][ ]?[)][ ]?$",x.split("=")[-1])):
            temp=x.split("=")[0]
            if(("FADDR" in temp) or ("DADDR" in temp) or (re.match("^[ ]?PC[ ]?$",temp)) or ("STKY" in temp) or ("PCSTKP" in temp)):
                OpCode="ERROR"
            else:
                OpCode=OpCode[0]+"0100100"+register(x.split("=")[0])+"000"+register(re.findall("I[0-7]",x.split("=")[-1])[0])[5:]+register(re.findall("M[0-7]",x.split("=")[-1])[0])[5:]+"00"+conditions(condition)
        elif(re.match("MODIFY[ ]?[(][ ]?I[0-7][ ]?,[ ]?M[0-7][ ]?[)][ ]?$",x)):
            OpCode=OpCode[0]+"01000"+OpCode[6:19]+register(re.findall("I[0-7]",x)[0])[5:]+register(re.findall("M[0-7]",x)[0])[5:]+"00"+conditions(condition)
        elif(re.match("JUMP[ ]?[(][ ]?M[1,8,9][0-5]*[ ]?,[ ]?I[1,8,9][0-5]*[ ]?[)][ ]?$",x)):
            OpCode=OpCode[0]+"01100"+OpCode[6:19]+register(re.findall("I[1,8,9][0-5]*",x)[0])[5:]+register(re.findall("M[1,8,9][0-5]*",x)[0])[5:]+"00"+conditions(condition)
        elif(re.match("CALL[ ]?[(][ ]?M[1,8,9][0-5]*[ ]?,[ ]?I[1,8,9][0-5]*[ ]?[)][ ]?$",x)):
            OpCode=OpCode[0]+"01101"+OpCode[6:19]+register(re.findall("I[1,8,9][0-5]*",x)[0])[5:]+register(re.findall("M[1,8,9][0-5]*",x)[0])[5:]+"00"+conditions(condition)
        else:
            OpCode=OpCode[0]+"10000"+compute(x)+conditions(condition)
    if("EROR" in OpCode):
        return "ERROR"
    else:
        return OpCode
def assembler(INST_LOCATE):
    print(INST_LOCATE+"\n")
    g=open(INST_LOCATE,"rt")
    f=open(PM_LOCATE,"wt")
    f.write(16*"1"+16*"0"+"\n")
    l=[]
    for i in g:
        l.append(i.strip("\n"))
    i=0
    while(i<len(l)):
        instr=l[i]
        i=i+1
        if(instr!=" " and instr!="\n" and instr!="\t" and instr!=""):
            if(re.match(".memcheck[ ]?",instr.lower())):
                break
            if(re.match(".CALL[ ]?[(][ ]?[0-9,A-F]+[ ]?[)][ ]?",instr.upper())):
                f.write(16*"1"+format(int(re.findall("[0-9,A-F]+",instr)[1],16),"016b")+"\n")
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
            if(len(instr)>2):
                OpCode=Primary(inst)
            else:
                continue
            if("ERROR" in OpCode):
                print("Faulty instruction : {}\nAt location: {}\n".format(instr,INST_LOCATE))
                f.close()
                g.close()
                return 0
                
            else:
                f.write(OpCode)
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
                    if memchk(os.path.join(root,name)): fail_mfile.append(os.path.join(root,name))
                    if(name[0]==idntfr):
                        flmdfy("file=$fopen(DM_LOCATE,\"w\");\n			$fclose(file);","MEM_top.v",bck,47,0)
                        flmdfy("file=$fopen(DM_LOCATE,\"w\");\n			$fclose(file);","MEM_top.v",frd,0,0)
                        comple()
                else:
                    fail_afile.append(os.path.join(root,name))
    print("{} No. out of {} files ran successfully".format(valid_count,file_count))
else:
    print("Compilation Error, bye bye!!")
if(file_count!=valid_count): print("\n\nFailed Files due to faulty instructions : ", *fail_afile, sep="\n")
if(len(fail_mfile)): 
    print("\n\nFailed Files due to memcheck data mismatch : ", *fail_mfile, sep="\n")
else:
    print("\n\nAll tests successfully passed in MEMCHECK\n")
flmdfy("$system","test_core.v",cmnt,0,0)
os.system('pause')

