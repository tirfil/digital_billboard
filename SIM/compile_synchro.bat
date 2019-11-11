set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\resynchro.vhd

