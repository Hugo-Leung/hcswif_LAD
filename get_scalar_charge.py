import sys
import os
import re

def parse_scalar_file(filepath):
  current = None
  current_unit = None
  charge = None
  charge_unit = None
  with open(filepath, 'r') as f:
    for line in f:
      if line.startswith("HMS BCM4B Beam Cut Current"):
        match = re.search(r":\s*([\d\.Ee+-]+)\s*(\w+)", line)
        if match:
          current = float(match.group(1))
          current_unit = match.group(2)
      elif line.startswith("HMS BCM4B Beam Cut Charge:"):
        match = re.search(r":\s*([\d\.Ee+-]+)\s*(\w+)", line)
        if match:
          charge = float(match.group(1))
          charge_unit = match.group(2)
  return current, current_unit, charge, charge_unit

def main(input_filename):
  input_dir = os.path.dirname(input_filename)
  input_base = os.path.basename(input_filename)
  output_dir = os.path.join(input_dir, "withCharge")
  os.makedirs(output_dir, exist_ok=True)
  output_filename = os.path.join(output_dir, input_base)
  with open(output_filename, 'w') as outfile:
    outfile.write(f"{'run_num':>8}  {'current(uA)':>10}  {'charge(mC)':>10}\n")
    with open(input_filename, 'r') as infile:
      for line in infile:
        line = line.strip()
        if not line or line.startswith('#'):
          continue
        # Expecting: run_num, max_segment, min_segment, run_type
        parts = [x.strip() for x in line.split(' ')]
        if len(parts) < 4:
          print(f"Skipping malformed line: {line}")
          continue
        run_num, max_segment, min_segment, run_type = parts[:4]
        scalar_filename = f"/w/hallc-scshelf2102/c-lad/ehingerl/software/lad_replay/REPORT_OUTPUT/LAD_COIN/SCALAR/replayReport_LAD_coin_scalar_{run_num}_{min_segment}_{max_segment}_-1.report"
        if not os.path.isfile(scalar_filename):
          print(f"File not found: {scalar_filename}")
          continue
        current, current_unit, charge, charge_unit = parse_scalar_file(scalar_filename)
        if current is None or charge is None:
          current = 0
          charge = 0
        else:
          if current_unit != "uA":
            raise ValueError(f"Unexpected current unit '{current_unit}' in file {scalar_filename}, expected 'uA'")
          if charge_unit != "mC":
            raise ValueError(f"Unexpected charge unit '{charge_unit}' in file {scalar_filename}, expected 'mC'")
        outfile.write(f"{run_num:>8}  {current:>10}  {charge:>10}\n")

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print(f"Usage: python {sys.argv[0]} <input_file>")
    sys.exit(1)
  main(sys.argv[1])