#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <input_file>"
	exit 1
fi

input_file="$1"
prev_run=""
count=0

# Generate output file name: insert _sheet_info before file extension
base="${input_file%.*}"
ext="${input_file##*.}"
if [[ "$base" == "$input_file" ]]; then
	# No extension
	output_file="${input_file}_sheet_info"
else
	output_file="${base}_sheet_info.${ext}"
fi

# Write output to the file
{
while read -r line; do
	run_num=$(echo "$line" | awk '{print $1}')
	if [ "$run_num" == "$prev_run" ]; then
		count=$((count + 1))
	else
		if [ -n "$prev_run" ]; then
			echo "$prev_run $count"
		fi
		prev_run="$run_num"
		count=1
	fi
done < "$input_file"

# Output the last run number and its count
if [ -n "$prev_run" ]; then
	echo "$prev_run $count"
fi
} > "$output_file"