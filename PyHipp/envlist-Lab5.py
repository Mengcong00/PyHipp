#!/data/miniconda3/envs/env1/bin/python

from filelock import FileLock
import hickle
import sys

# set constants
file_path = "/data/picasso/envlist.hkl"
lock_path = "/data/picasso/envlist.hkl.lock"
time_out_secs = 60

# program modes
READ_MODE = 0
WRITE_MODE = 1
RESET_MODE = 2

# get number of arguments
nargs = len(sys.argv)
if nargs > 3:
    print('Usage: envlist; envlist env; envlist envprefix nenvs')
    exit
elif nargs > 2:
    pmode = RESET_MODE
    envprefix = sys.argv[1]
    nenvs = int(sys.argv[2])
elif nargs > 1:
    pmode = WRITE_MODE
    env = sys.argv[1]
else:
    pmode = READ_MODE

lock = FileLock(lock_path, timeout=time_out_secs)

with lock:
    if pmode == RESET_MODE:
<<<<<<<< HEAD:PyHipp/envlist.py-Lab5.py
        clist1 = [*range(0,nenvs,1)]
========
        # create a list (named clist) of nevns environments with the 
        # prefix envprefix
        clist1 = [*range(0,int(nenvs),1)]
>>>>>>>> upstream/main:envlist.py
        clist = [envprefix + str(s) for s in clist1]
    else:
        # load hickle file
        clist = hickle.load(file_path)

        if pmode == WRITE_MODE:
            # append item to end of list
            clist.append(env)
<<<<<<<< HEAD:PyHipp/envlist.py-Lab5.py
        else:    
            # pop first item off list
========
        else:
            # get and remove env from clist
>>>>>>>> upstream/main:envlist.py
            env = clist.pop(0)
            # return env name
            print(env)

    # save hickle file
    hickle.dump(clist, file_path, mode="w")


