#!/bin/bash

run_min=$1
run_max=$2
n_segs_per_file=$3
rl_name=$4

run_types=("lad_Production" "lad_Production_noGEM" "lad_LADwGEMwROC2" "lad_GEMonly" "lad_LADonly" "lad_SHMS_HMS" "lad_SHMS" "lad_HMS")

if [ -z "$rl_name" ]; then
	echo "No runlist file name given, using default runlist.dat"
	rl_name="runlist.dat"
fi

if [ -z "$n_segs_per_file" ]; then
	echo "No number of segments per file given, using default 1000"
	n_segs_per_file=-1
fi

for run in $(seq $run_min $run_max); do
	max_idx=-1
	for file in /cache/hallc/c-lad/raw/lad_*${run}.dat.*; do
		idx=$(echo "$file" | sed -n "s/.*\.dat\.\([0-9][0-9]*\)$/\1/p")
		if [ -n "$idx" ] && [ "$idx" -gt "$max_idx" ]; then
			max_idx=$idx
		fi
	done
	config_num=-1
	for i in "${!run_types[@]}"; do
		run_type="${run_types[$i]}"
		if ls /cache/hallc/c-lad/raw/${run_type}_$(printf "%0*d" ${#run} $run).dat.* 1> /dev/null 2>&1; then
			config_num=$i
			break
		fi
	done
	if [ "$max_idx" -ge 0 ]; then
		if [ "$n_segs_per_file" -le 0 ]; then
			echo "$run $max_idx 0 0"
		else
			num_segs=$(( (max_idx + $n_segs_per_file) / $n_segs_per_file ))
			for ((i=0; i<num_segs; i++)); do
				start=$(( n_segs_per_file * i ))
				end=$(( n_segs_per_file * (i + 1) - 1 ))
				if [ "$end" -gt "$max_idx" ]; then
					end=$max_idx
				fi
				echo "$run $end $start $config_num 0"
			done
		fi
	fi
done >$rl_name
