#!/bin/bash
# kullanim: tools_trials.sh MODE LEVEL N [PAR]
export PATH=$HOME/bin:$PATH
cd /workspace/riftrush
M=$1; L=$2; N=$3; P=${4:-4}
seq $N | xargs -P $P -I{} bash -c "AP_MODE=$M AP_TS=${AP_TS:-4} xvfb-run -a godot --path . -- autoplay $L 2>&1 | grep AUTOPLAY"
