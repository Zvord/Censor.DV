LIST=../list/tb.list
GENERATOR=$(PROJ_ROOT)/CensorSln/bin/Censor
INPUT?=$(PROJ_ROOT)/jsons/real_example.json
OUTPUT?=$(PROJ_ROOT)/sv/test/tb/weather_coverage.sv
TOP=testrunner

.PHONY: clean all generate comp run

generate:
	$(GENERATOR) -i $(INPUT) -o $(OUTPUT)

comp:
	vlog -f $(LIST)

clean:
	rm -rf work

run:
	vsim -c -do 'run -all; quit' $(TOP) +SVUNIT_FILTER=*

all: generate comp run