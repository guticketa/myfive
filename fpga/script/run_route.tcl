# Gathering TCL Arg
set DESIGN [lindex $argv 0]
set OUTDIR [lindex $argv 1]

open_checkpoint ${OUTDIR}/${DESIGN}_opt.dcp

# Placing Design
place_design

# Routing Design
route_design

# Saving Run
write_checkpoint -force ${OUTDIR}/${DESIGN}_route.dcp

# Createing opt reports
#report_timing_summary -max_paths 10 -nworst 1 -input_pins -
#report_drc -file ${DESIGN}_drc_route.rpt

exit
