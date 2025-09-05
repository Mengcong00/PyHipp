#!/bin/bash
# first job - no dependencies, called from the day directory
# creates RPLParallel, Unity, and EDFSplit objects, and
# calls aligning_objects and raycast
jid1=$(sbatch /data/src/PyHipp/PyHipp/rplparallel-slurm.sh)

# second job - no dependencies, called from the day directory
# performs rplsplit for sessioneye
jid2=$(sbatch /data/src/PyHipp/PyHipp/rse-slurm.sh)

# third set of jobs - depends on second job, called from the day 
# directory
# performs rplsplit, submits slurm jobs for creating RPLLFP
# slurm jobs for creating RPLHighPass and spike sorting
jid3=$(sbatch --dependency=afterok:${jid2##* } /data/src/PyHipp/PyHipp/rs1a-slurm.sh)
jid4=$(sbatch --dependency=afterok:${jid2##* } /data/src/PyHipp/PyHipp/rs2a-slurm.sh)
jid5=$(sbatch --dependency=afterok:${jid2##* } /data/src/PyHipp/PyHipp/rs3a-slurm.sh)
jid6=$(sbatch --dependency=afterok:${jid2##* } /data/src/PyHipp/PyHipp/rs4a-slurm.sh)
# put dependency for any job that will spawn more jobs here
sbatch --dependency=afterok:${jid1##* }:${jid2##* }:${jid3##* }:${jid4##* }:${jid5##* }:${jid6##* } /data/src/PyHipp/consol_jobs.sh

