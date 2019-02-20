SOLDIRS = $(shell find Solidity -name *.sol | xargs dirname | sort | uniq)
LLLDIRS = $(shell find LLL -name *.lll | xargs dirname | sort | uniq)
SOLS = $(SOLDIRS:%=%.sol)
LLLS = $(LLLDIRS:%=%.lll)

all: clean allsol
allsol: $(SOLS)
%.sol: %
	solc --bin --abi -o out/$< $</$(shell basename $@)
alllll: $(LLLS)
%.lll: %
	lllc -x $</$(shell basename $@) > out/$</$(shell basename $@)

clean:
	find out -type f -delete