#!/bin/bash
set -euo pipefail
echo "[consol] starting at $(date)"
bash /data/src/PyHipp/ec2snapshot.sh
echo "[consol] done at $(date)"
