import configparser
cnfg = configparser.ConfigParser()
cnfg.optionxform = str
cnfg['PATHS'] = {'DIR': r"C:\Users\Dell\Desktop\Arundhathy-files\Processor-design\Processor-design\Test-cases\Test Passed\Shifter-tests\shf_passed",
        'PM_LOCATE': r"C:\Users\Dell\Desktop\Arundhathy-files\Processor-design\memory_files\pm_file.txt",
        'DM_LOCATE': r"C:\Users\Dell\Desktop\Arundhathy-files\Processor-design\memory_files\dm_file.txt",
        'DMrdfl_LOCATE': r"C:\Users\Dell\Desktop\Arundhathy-files\Processor-design\Processor-design\Test-cases\DMrd_files",
        'MEMfail_LOCATE': r"C:\Users\Dell\Desktop\Arundhathy-files\Processor-design\MEMfail_files"}
cnfg['IDENTIFIER'] = {'idntfr': "_"}
cnfg['AVOID'] = {'pm_file.txt': "",
        'dm_file.txt': ""}
with open('Path.ini', 'w') as pathfl:
    cnfg.write(pathfl)
