FC = mpif90
LD = mpif90

INCLUDE := .

FFLAGS = -O

FPPFLAGS :=

LDFLAGS :=

LIBS :=

CPPDEFS =


RM = rm -f
SHELL = /bin/csh -f
TMPFILES = *.mod

.SUFFIXES: .f90 .o

.f90.o:
	$(FC) $(FFLAGS) -c $*.f90


.DEFAULT:

all:  dodgy_monitor  test_caller

dodgy_monitor: dodgy_monitor.o
	$(LD) -o dodgy_monitor dodgy_monitor.o $(LDFLAGS) 

test_caller: test_caller.o
	$(LD) -o test_caller test_caller.o dodgy_monitor_modules.o

test_caller.o: dodgy_monitor_modules.o test_caller.f90
	$(FC) $(FFLAGS) -c test_caller.f90 

dodgy_monitor_modules.o: dodgy_monitor_modules.f90
	$(FC) $(FFLAGS) -c dodgy_monitor_modules.f90 
