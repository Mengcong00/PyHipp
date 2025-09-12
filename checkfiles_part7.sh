#!/bin/bash
set -euo pipefail

# ---------- A. 计数（与 checkfiles2.sh 保持一致口径） ----------
echo "Number of hkl files"
find . -name "*.hkl" | grep -v -e spiketrain -e mountains | wc -l
echo "Number of mda files"
find mountains -name "firings.mda" | wc -l
echo

# ---------- B. 抽取 5 个作业的开始/结束/单作业耗时 ----------
outs=(rplpl-slurm.*.out rs1-slurm.*.out rs2-slurm.*.out rs3-slurm.*.out rs4-slurm.*.out)

echo "#==========================================================="
echo "Start/End times per job"

# 用来找最早开始/最晚结束
earliest_epoch=""
latest_epoch=""

sum_dur=0

parse_struct_time() {
  # 输入一行形如：time.struct_time(tm_year=2025, tm_mon=8, tm_mday=27, tm_hour=12, tm_min=56, tm_sec=23, ...)
  # 输出：epoch 秒
  local line="$1"
  local Y=$(echo "$line" | sed -n 's/.*tm_year=\([0-9]\+\).*/\1/p')
  local M=$(echo "$line" | sed -n 's/.*tm_mon=\([0-9]\+\).*/\1/p')
  local D=$(echo "$line" | sed -n 's/.*tm_mday=\([0-9]\+\).*/\1/p')
  local h=$(echo "$line" | sed -n 's/.*tm_hour=\([0-9]\+\).*/\1/p')
  local m=$(echo "$line" | sed -n 's/.*tm_min=\([0-9]\+\).*/\1/p')
  local s=$(echo "$line" | sed -n 's/.*tm_sec=\([0-9]\+\).*/\1/p')
  date -d "${Y}-${M}-${D} ${h}:${m}:${s}" +%s
}

for pat in "${outs[@]}"; do
  for f in $pat; do
    [ -f "$f" ] || continue
    echo "== $f =="

    start_line=$(grep -m1 "time.struct_time" "$f" || true)
    end_line=$(grep "time.struct_time" "$f" | tail -n1 || true)
    [ -n "$start_line" ] && echo "start: $start_line"
    [ -n "$end_line" ] && echo "end:   $end_line"

    # 单作业耗时：取该文件里“最后一个纯数字秒数”，对应 print(time.time()-t0)
    dur=$(grep -E '^[0-9]+\.[0-9]+$' "$f" | tail -n1 || true)
    if [ -n "$dur" ]; then
      echo "duration_s: $dur"
      # 只加“最后一个”持续时间，避免把中途打印的秒数累加
      sum_dur=$(python3 - <<PY
s=$sum_dur
d=float("$dur")
print(s+d)
PY
)
    fi
    echo

    # 维护最早 start / 最晚 end（计算并行 makespan）
    if [ -n "$start_line" ]; then
      se=$(parse_struct_time "$start_line")
      if [ -z "$earliest_epoch" ] || [ "$se" -lt "$earliest_epoch" ]; then
        earliest_epoch="$se"
      fi
    fi
    if [ -n "$end_line" ]; then
      ee=$(parse_struct_time "$end_line")
      if [ -z "$latest_epoch" ] || [ "$ee" -gt "$latest_epoch" ]; then
        latest_epoch="$ee"
      fi
    fi
  done
done

echo "Serial total (seconds): $(printf '%.2f' "$sum_dur")"

# ---------- C. 并行实际用时（makespan） ----------
if [ -n "${earliest_epoch:-}" ] && [ -n "${latest_epoch:-}" ]; then
  makespan=$((latest_epoch-earliest_epoch))
  echo "Parallel makespan (seconds): $makespan"
  python3 - <<PY
sec=${makespan}
h=sec//3600; m=(sec%3600)//60; s=sec%60
print(f"Parallel makespan (h:m:s): {h}:{m:02d}:{s:02d}")
PY
fi
echo "#==========================================================="
