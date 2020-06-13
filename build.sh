#!/usr/bin/env bash
#
# Builds the Ice Storm tool chain test module.
# coq_makefile -Q ../Kami/ Kami -Q ../coq-record-update/src/ RecordUpdate -Q . IceStomTest IceStormTest.v > Makefile
#
# Note: you may have to manually remove the CustomExtract import from CustomExtract.hs

#make && \
echo "Compiled Coq files" && \
#cd ../Kami && ./fixHaskell.sh ../ramTest && cd ../ramTest && \
echo "Fixed imports" && \
#ghc -O2 --make -i../Kami -i../Kami/Compiler ../Kami/Compiler/CompAction.hs && \
echo "Compiled Haskell files" && \
#../Kami/Compiler/CompAction > System.sv && \
echo "Generated Verilog files (System.sv)."
yosys -p "synth_ice40 -blif System.blif" System.sv && \
arachne-pnr -d 8k -p System.pcf System.blif -o System.asc && \
icepack System.asc System.bin
