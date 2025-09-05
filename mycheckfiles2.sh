#!/bin/bash
set -e

# —— 1) 数量统计（与 Part A 的 checkfiles 一致）——
echo "Number of hkl files"
find . -name "*.hkl" | grep -v -e spiketrain -e mountains | wc -l
echo "Number of mda files"
find mountains -name "firings.mda" | wc -l

# —— 2) 开始/结束时间与耗时（读两份 .out）——
echo
echo "#==========================================================="
echo "Start Times"

# 这两行会打印各自 .out 里第一处出现的 time.struct_time（即开始时间）
grep -h -m1 -H "time.struct_time" rplpl-slurm.*.out
grep -h -m1 -H "time.struct_time" rplspl-slurm.*.out

echo "End Times"

# 打印各自 .out 里最后一处出现的 time.struct_time（结束时间）
grep -h "time.struct_time" rplpl-slurm.*.out | tail -n1
grep -h "time.struct_time" rplspl-slurm.*.out | tail -n1

# 打印各自 .out 里最后一处出现的“秒数”（print(time.time()-t0)）
grep -h -E '^[0-9]+\.[0-9]+$' rplpl-slurm.*.out | tail -n1
grep -h -E '^[0-9]+\.[0-9]+$' rplspl-slurm.*.out | tail -n1

# 打印各自 .out 里最后一条 SNS MessageId（可选，但和示例一致）
grep -h '"MessageId"' rplpl-slurm.*.out | tail -n1 || true
grep -h '"MessageId"' rplspl-slurm.*.out | tail -n1 || true
echo "#==========================================================="

