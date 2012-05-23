TARG=5
TCL=ex$(TARG).tcl
NAM=lab$(TARG).nam
TRACE=$(patsubst %.nam,%.tr,$(NAM))
all:	nam

$(NAM):	$(TCL)
	ns $<

nam:	$(NAM)
	nam $(NAM) &

awk:
	awk -f script_1.awk < $(TRACE) > awk.out
	cp script_1.awk report/files
	mv awk.out report/files


