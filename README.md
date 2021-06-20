# Processor-design

Timeline : 8 September 2020 to 20 June 2021
=

---------------------------------------------------------------

Steps to follow -

1. Run Configure_Path.py after editing the cnfg['PATHS'] with the required paths.
        DIR : directory containing test files
        PM_LOCATE - provide path to pm file in your computer
        DM_LOCATE - provide path to dm file in your computer
        DMrdfl_LOCATE : "DMrd_files" folder path
        MEMfail_LOCATE : "MEMfail_files" folder path
   Path.ini file will be generated which can be used for subsequent runs.

2. In test_core.v file, edit the following :
        a. core_top #( ,,,,,, .PM_LOCATE( "<path to pm_file.txt>" ), .DM_LOCATE( "<path to dm_file.txt>" ) )
        b. $system('python <filepath>');        [ Replace <filepath> with full path of the file memchecker.py in your local machine. ]

Below are required only when testing individual files
=======================================
1. In Assembler.py file, edit the following : 
        a. PM_LOCATE - provide path to pm file in your computer
        b. INST_LOCATE - provide path to folder containing instruction file
        
2. In memchecker.py file, edit the following :
        a. dm_loc - path to dm file
        b. memck_loc - path to folder containing test instructions
        c. file_name - test instruction assembly language txt file (containing .memcheck function)

---------------------------------------------------------------

Main Units in the design
1. Assembler
2. Compute units
3. Register file and Crossbar
4. DAG
5. Program Sequencer
6. Memory - PM and DM
