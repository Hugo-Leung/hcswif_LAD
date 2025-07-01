import subprocess
import sys
import os
import time

def process_runs(input_file):
  # Call 'golad' once before processing runs
  # print("Running: golad")
  # subprocess.run(["golad"])

  original_dir = os.getcwd()
  
  try:
    with open(input_file, 'r') as f:
      os.chdir("/w/hallc-scshelf2102/c-lad/ehingerl/software/lad_replay")
      print(f"Current working directory: {os.getcwd()}")
      for line in f:
        # Skip empty lines or comments
        if not line.strip() or line.strip().startswith('#'):
          continue
        parts = line.strip().split()
        if len(parts) < 4:
          print(f"Skipping malformed line: {line.strip()}")
          continue
        run_num, max_segment, min_segment, run_type = parts[:4]
        cmd = [
          "hcana", "-l", "-q",
          f"SCRIPTS/LAD_COIN/SCALAR/replay_lad_scalar.C({run_num},-1,{run_type},1,{max_segment})"
        ]
        print(f"Running: {' '.join(cmd)}")
        # Start each command in the background
        proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if 'procs' not in locals():
          procs = []
        procs.append((proc, run_num))

      # Monitor processes and print status
      finished = 0
      total = len(procs)
      while finished < total:
        for i, (proc, run_num) in enumerate(procs):
          if proc is not None and proc.poll() is not None:
            finished += 1
            print(f"Run {run_num} finished. {finished}/{total} complete.")
            procs[i] = (None, run_num)
        time.sleep(1)
        
  finally:
    # Return to the original directory at the end
    # os.chdir(original_dir)
    print(f"Returned to directory: {original_dir}")

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print("Usage: python scalar_only.py <input_file>")
    sys.exit(1)
  process_runs(sys.argv[1])