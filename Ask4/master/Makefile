TARG=ex4
all:	nam

lab4.nam:	$(TARG).tcl
	ns $(TARG).tcl
nam:	lab4.nam
	nam lab4.nam

awk:
	awk -f script_1.awk < lab4.tr > awk.out
	cp script_1.awk report/files
	mv awk.out report/files


