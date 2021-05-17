#Script to test o/p
import time

dm_loc="C:/modeltech64_10.5/examples/memory_files/dm_file.txt"                        #Location of dm file - ../ indicates the folder "memory_files" where "dm_file.txt" is, is one folder up the current folder of script
memck_loc="C:/modeltech64_10.5/examples/SAC/Instructions/"                                   #Location of Instruction folder - file with instructions is in folder "Instructions" in the current folder of script
find=".memcheck"
file_name="inst.txt"                                        #Name of instruction file - default name "inst.txt"

#file_name=input("Enter name of Instruction file : ")       #Uncomment for option allowing manual entering of Instruction file name
tst_file=open(memck_loc+file_name,'r')
dm_file=open(dm_loc,'r')

tlines = [line.replace(' ', '').replace('\t','').strip() for line in tst_file.readlines()]
dlines = [line.replace(' ', '').replace('\t','').strip() for line in dm_file.readlines()]
slines=list(filter(None,tlines[[line.lower() for line in tlines].index(find)+1:]))

def dsply(txt,flines):
    count=0
    print(txt)
    for line in flines:
        count=count+1
        print("Line{}: {}".format(count, line.strip()))
    print('\n')

dsply(find+' data',slines)

[print("Address {}: {}".format(dl[:4], "pass")) if dl in dlines else print("Address {}: {}".format(dl[:4], "fail")) for dl in slines]

time.sleep(5)
