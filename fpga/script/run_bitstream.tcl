# Gathering TCL Arg
set DESIGN [lindex $argv 0]
set OUTDIR [lindex $argv 1]

open_checkpoint ${OUTDIR}/${DESIGN}_route.dcp

# Create bitstream
write_bitstream -force ${OUTDIR}/${DESIGN}.bit

exit
