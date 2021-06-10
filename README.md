# Processor-design

You may find sample test instructions in the SAMPLE INSTRUCTIONS folder.

---------------------------------------------------------------

Steps to follow -

1. In Assembler.py file, edit the following : 
        a. PM_LOCATE - provide path to pm file in your computer
        b. INST_LOCATE - provide path to folder containing instruction file

2. In test_core.v file, edit the following :
        a. core_top #( ,,,,,, .PM_LOCATE( "<path to pm_file.txt>" ), .DM_LOCATE( "<path to dm_file.txt>" ) )
        b. $system('python <filepath>');        [ Replace <filepath> with full path of the file a_test_script.py in your local machine. ]
        
3. In a_test_script.py file, edit the following :
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
