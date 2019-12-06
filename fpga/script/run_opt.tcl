# Gathering TCL Arg
set DESIGN [lindex $argv 0]
set XDC_FILE [lindex $argv 1]
set OUTDIR [lindex $argv 2]

open_checkpoint ${OUTDIR}/${DESIGN}_synth.dcp

# Running Logic Optimization
opt_design

# Adding Constraints
read_xdc ${XDC_FILE}

write_checkpoint -force ${OUTDIR}/${DESIGN}_opt.dcp

# Createing opt reports
#report_utilization -file ${DESIGN}_utilization_opt.rpt

exit
