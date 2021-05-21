# 18th may
# -------------------------------------------------------------------------------------------------------------------------------------

PM_LOCATE="../memory_files/pm_file.txt"                         # Provide path to PM file and instructions here
INST_LOCATE="../test_instructions/"

#-------------------------------------------------------------------------------------------------------------------------------------

from os import system,name
import re
import time
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
    elif(re.match("R[0-9]+[ ]?=[ ]?R[0-9]+[ ]?-[ ]?R[0-9]+[ ]?[+][ ]?CI[]*-[ ]?1[ ]?",com)):
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
def Assembler(x):
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
            OpCode=OpCode[0]+"0100100"+register(x.split("=")[-1])+"000"+register(re.findall("I[0-7]",x)[0])[5:]+register(re.findall("M[0-7]",x)[0])[5:]+"10"+conditions(condition)
        elif(re.match("^[ ]?DM[ ]?[(][ ]?I[0-7][ ]?,[ ]?M[0-7][ ]?[)][ ]?$",x.split("=")[-1])):
            temp=x.split("=")[0]
            if(("FADDR" in temp) or ("DADDR" in temp) or (re.match("^[ ]?PC[ ]?$",temp)) or ("STKY" in temp) or ("PCSTKP" in temp)):
                OpCode="ERROR"
            else:
                OpCode=OpCode[0]+"0100100"+register(x.split("=")[0])+"000"+register(re.findall("I[0-7]",x)[0])[5:]+register(re.findall("M[0-7]",x)[0])[5:]+"00"+conditions(condition)
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
def display(l):
    for i in range(len(l)):
        print(l[i])
def clear():
    if name=="nt":
        _=system('cls')
    else:
        _=system("clear")
a=input("Enter name of file containing instructions:")
g=open(INST_LOCATE+a,"rt")                                  #Changed
#b=input("Enter name of OpCode Destination file:")
f=open(PM_LOCATE,"wt")                                      #Changed
l=[]
rewrite=False
instr_list=[]
for i in g:
    l.append(i.strip("\n"))
i=0
while(i<len(l)):
    time.sleep(.1)
    instr=l[i]
    i=i+1
    if(instr!=" " or instr!="\n" or instr!="\t" or instr!=""):
        if(re.match(".memcheck[ ]?",instr.lower())):
            break
        print(instr)
        instr_list.append(instr)
        if("#" in instr):
            inst = re.split("#",instr)[0]
            if(re.match("^[ ]*#",instr)):
                continue
        elif("/*" in instr):
            inst = instr.split("/")[0]
            if(re.match("^[/][*]",instr)):
                while("*/" not in instr):
                    time.sleep(.5)
                    instr=l[i]
                    instr_list.append(instr)
                    print(instr,end='')
                    i=i+1
                continue
        else:
            inst = instr
        if(len(instr)>2):
            OpCode=Assembler(inst)
        else:
            continue
        if("ERROR" in OpCode):
            clear()
            instr_list.pop()
            for z in range(3,0,-1):
                display(instr_list)
                print(instr)
                print(instr,end=" ")
                print("contains error. Please re-enter")
                print("You can re-enter in {} seconds".format(z))
                time.sleep(1)
                clear()
            display(instr_list)
            print("Faulty instruction : {}".format(instr))
            instr = input()
            clear()
            display(instr_list)
            i=i-1
            l[i]=instr
            rewrite=True
        else:
            f.write(OpCode)
            f.write("\n")
        if("/*" in instr):
            while("*/" not in instr):
                time.sleep(.5)
                instr=l[i]
                instr_list.append(instr)
                print(instr,end='')
                i=i+1
print("\nOpcodes saved in "+ PM_LOCATE)                     #Changed
f.close()
g.close()
if(rewrite==True):
    g=open(INST_LOCATE+a,"wt")                              #Changed
    for i in range(len(l)):
        g.write(l[i])
        g.write('\n')
    g.close()
time.sleep(2)
