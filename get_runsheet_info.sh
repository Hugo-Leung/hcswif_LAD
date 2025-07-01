#!/bin/bash

# Usage: ./get_runsheet_info.sh file1.root file2.root ...

declare -A run_file_count
declare -A run_event_count

processed_files=0
for file in "$@"; do
  # Extract run number from filename
  # Assumes filename contains LAD_COIN_<run_number>_
  if [[ "$file" =~ LAD_COIN_([0-9]+)_ ]]; then
    run_number="${BASH_REMATCH[1]}"
    ((run_file_count[$run_number]++))
    # Get number of events using ROOT
    events=$(root -l -q -b "$file" -e 'T->GetEntries()' 2>/dev/null | tail -1 | sed 's/^(long long) //' | tr -d '()')

    # Call T->Show(0) with a 10 second timeout
    timeout 10s root -l -q -b "$file" -e 'T->Show(0)' &>/dev/null
    if [[ $? -eq 124 ]]; then
      echo "error with file $file"
      events=""
    fi

    # If events is empty or not a number, set to 0 and print error
    if ! [[ "$events" =~ ^[0-9]+$ ]]; then
      echo "error with file $file"
      events=0
    fi

    ((run_event_count[$run_number]+=$events))
  fi
  total_files=$#
  processed_files=$((processed_files + 1))
  percent=$((processed_files * 100 / total_files))
  echo -ne "Processing: $percent% complete\r"
done

# Print table header
printf "%-12s | %-20s | %-15s\n" "run_number" "number_of_files" "number_of_events"
echo "---------------------------------------------------------------"

# Print table rows
for run in $(printf "%s\n" "${!run_file_count[@]}" | sort -n); do
  printf "%-12s | %-20s | %-15s\n" "$run" "${run_file_count[$run]}" "${run_event_count[$run]}"
done
