#!/bin/bash

run_min=$1
run_max=$2
n_segs_per_file=$3
rl_name=$4

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
	for file in /cache/hallc/c-lad/raw/lad_Production_${run}.dat.*; do
		idx=$(echo "$file" | sed -n "s/.*\.dat\.\([0-9][0-9]*\)$/\1/p")
		if [ -n "$idx" ] && [ "$idx" -gt "$max_idx" ]; then
			max_idx=$idx
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
				echo "$run $end $start 0"
			done
		fi
	fi
done >$rl_name
