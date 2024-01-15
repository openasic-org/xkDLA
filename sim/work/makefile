.PHONY: vcs sim verdi clean
all:vcs sim verdi
	
OUTPUT   = simv
ALL_DEFINE = +define+DUMP_VPD
VPD_NAME = +vpdfile+${OUTPUT}.vpd
##========== code coverage command =======
CM_NAME  = -cm_name ${OUTPUT}
CM_DIR   = -cm_dir ./${OUTPUT}.vdb
CM       = -cm line+cond+fsm+branch+tgl
##======================================
vcs:
	vcs  \
              -f ../flist/filelist.f  \
              -timescale=1ns/1ns      \
              -full64 +v2k -sverilog -debug_all  \
			  -fsdb          \
			  -l vcs.log     \
			  -notimingcheck \
			  -nospecify     \
			  -o ${OUTPUT}   \
	          ${CM}          \
			  ${CM_NAME}     \
	          ${CM_DIR}      \
			  ${VPD_NAME}    \
			  ${ALL_DEFINE}  \
			  +lint=TFIPC-L  \
			  +vcs+lic+wait
sim:
	./${OUTPUT}    \
	-l sim.log     \
     ${CM}         \
	 ${CM_NAME}     \
     ${CM_DIR}      \
     ${VPD_NAME}    
#show the coverage
dve_cov:
	dve -covdir *.vdb &
urg:
	urg -dir *.vdb -report urgReport
dve:
	dve -vpd  ${OUTPUT}.vpd  &
verdi  :
	verdi -sv -f ../flist/filelist.f -ssf tb.fsdb &
clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd *.dat

