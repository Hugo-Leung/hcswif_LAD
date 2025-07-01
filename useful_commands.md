# Useful swif2 commands

## General
`swif2 list`

`swif2 status <workflow_name>`

## Submitting jobs
`./hcswif.py --mode replay --spectrometer LAD_COIN --run file run-lists/some_runs.dat --name myswifjob --time 345600 --all_segs true`

`swif2 import -file myswifjob.json`

`swif2 run myswifjob`

`swif2 notify -workflow <workflow_name> -email <your_email> -when done/stalled`

## Editing jobs
`swif2 modify-jobs <workflow> -ram mult 2 -names -regexp '.*'`

`mult/add/set`

`-resurrect is required if jobs are already finished`

## Canceling jobs
`swif2 cancel <workflow_name>`

`swif2 cancel <workflow_name> -delete`

## Generating run lists
`./make_lad_runlist.sh start_run end_run n_segs_per_run`
n_segs_per_run breaks up the run into multiple different runs with 'n_segs_per_run' runs each, to prevent MultiFileRun errors

## Other
`jvolatile info c-lad`

## Links
https://scicomp.jlab.org/cli/