#SRCDIR = src
SCRIPTDIR = script

DESIGN = top
DEVICE = xc7s50csga324-1
XDC_FILE = ./src/constrs/constr.xdc
OUTDIR := ./output_files

all: $(OUTDIR)/$(DESIGN).bit

synth: $(OUTDIR)/$(DESIGN)_synth.dcp

$(OUTDIR)/$(DESIGN)_synth.dcp: ./$(SCRIPTDIR)/run_synth.tcl
	@if [ ! -d $(OUTDIR) ]; then \
		mkdir -p $(OUTDIR); \
	fi
	vivado -mode batch -source ./$(SCRIPTDIR)/run_synth.tcl -tclargs $(DESIGN) $(DEVICE) $(OUTDIR)

$(OUTDIR)/$(DESIGN)_opt.dcp: ./$(SCRIPTDIR)/run_opt.tcl $(OUTDIR)/$(DESIGN)_synth.dcp $(XDC_FILE)
	vivado -mode batch -source ./$(SCRIPTDIR)/run_opt.tcl -tclargs $(DESIGN) $(XDC_FILE) $(OUTDIR)

$(OUTDIR)/$(DESIGN)_route.dcp: ./$(SCRIPTDIR)/run_route.tcl $(OUTDIR)/$(DESIGN)_opt.dcp
	vivado -mode batch -source ./$(SCRIPTDIR)/run_route.tcl -tclargs $(DESIGN) $(OUTDIR)

$(OUTDIR)/$(DESIGN).bit: ./$(SCRIPTDIR)/run_bitstream.tcl $(OUTDIR)/$(DESIGN)_route.dcp
	vivado -mode batch -source ./$(SCRIPTDIR)/run_bitstream.tcl -tclargs $(DESIGN) $(OUTDIR)

.PHONY: clean
clean:    
	$(RM) *.jou *.log *.xml *.html \
		$(OUTDIR)/*.dcp \
		$(OUTDIR)/*.rpt \
		$(OUTDIR)/*.bit
	@$(RM) -r .Xil