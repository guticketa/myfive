set DESIGN [lindex $argv 0]
set DEVICE [lindex $argv 1]
set OUTDIR [lindex $argv 2]

# read_verilog ./src/verilog/${DESIGN}.v
source ./script/srcs.tcl

# Run synthesis, report utilization and timing estimates, write design checkpoint
synth_design -top ${DESIGN} -part ${DEVICE}
write_checkpoint -force ${OUTDIR}/${DESIGN}_synth.dcp

#report_timing_summary -file ${DESIGN}_synth_timing_summary.rpt
#report_power -file ${DESIGN}_synth_power.rpt

#opt_design

exit
