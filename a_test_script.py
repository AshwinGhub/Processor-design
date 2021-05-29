#Script to test o/p
import time

dm_loc="C:/Users/arund/Desktop/TKM-Docs/Final-Year-Project/memory_files/dm_file"                          #Location of dm file - ../ indicates the folder "memory_files" where "dm_file.txt" is, is one folder up the current folder of script
memck_loc="C:/Users/arund/Desktop/TKM-Docs/Final-Year-Project/test_instructions/"                              #Location of Instruction folder - file with instructions is in folder "Instructions" in the current folder of script
find=".memcheck"
file_name="o_p4.txt"                                                                    #Name of instruction file - default name "inst.txt"

#file_name=input("Enter name of Instruction file : ")                                   #Uncomment for option allowing manual entering of Instruction file name

tst_file=open(memck_loc+file_name,'r')
dm_file=open(dm_loc,'r')

tlines = [line.replace(' ', '').replace('\t','').strip() for line in tst_file.readlines()]
dlines = [line.replace(' ', '').replace('\t','').strip() for line in dm_file.readlines()]
slines=list(filter(None,[x.lower() for x in tlines[[line.lower() for line in tlines].index(find)+1:]]))

##Just for highlights - start
print('/' * 140)

print("\nMM          MM  EEEEEEEEEEEEEE  MM          MM  CCCCCCCCCCCCCC  HH          HH  EEEEEEEEEEEEEE  CCCCCCCCCCCCCC  KK       KKK\nMMM        MMM  EEEEEEEEEEEEEE  MMM        MMM  CCCCCCCCCCCCCC  HH          HH  EEEEEEEEEEEEEE  CCCCCCCCCCCCCC  KK     KKK\nMMMM      MMMM  EE              MMMM      MMMM  CC              HH          HH  EE              CC              KK   KKK\nMM MM    MM MM  EE              MM MM    MM MM  CC              HH          HH  EE              CC              KK KKK\nMM  MM  MM  MM  EEEEEEEEEEEEEE  MM  MM  MM  MM  CC              HHHHHHHHHHHHHH  EEEEEEEEEEEEEE  CC              KKKK\nMM   MMMM   MM  EEEEEEEEEEEEEE  MM   MMMM   MM  CC              HHHHHHHHHHHHHH  EEEEEEEEEEEEEE  CC              KKKK\nMM    MM    MM  EE              MM    MM    MM  CC              HH          HH  EE              CC              KK KKK           \nMM          MM  EE              MM          MM  CC              HH          HH  EE              CC              KK   KKK\nMM          MM  EEEEEEEEEEEEEE  MM          MM  CCCCCCCCCCCCCC  HH          HH  EEEEEEEEEEEEEE  CCCCCCCCCCCCCC  KK     KKK\nMM          MM  EEEEEEEEEEEEEE  MM          MM  CCCCCCCCCCCCCC  HH          HH  EEEEEEEEEEEEEE  CCCCCCCCCCCCCC  KK       KKK\n")

print('/' * 140)
##Just for highlights - end

print("TEST PASSED") if not len(set(slines)-set(dlines)) else None
[print("Address {}: {}".format(dl[:4], "fail")) if dl not in dlines else None for dl in slines]

time.sleep(5)

