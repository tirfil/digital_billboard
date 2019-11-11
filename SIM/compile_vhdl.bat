set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\avalon_read.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\rgbout.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\vga_controller.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\resynchro.vhd
ghdl -a --work=RAM_LIB --workdir=ALL_LIB %FLAG% ..\VHDL\dp8x16.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\cdcfifo8.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\rdfifo8.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\wrfifo8.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\fifo_control.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\fifo_inter.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\display.vhd
ghdl -e --work=WORK --workdir=ALL_LIB %FLAG% display
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\avalon_access.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\spislave.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\spiregister.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\spiaccess.vhd
ghdl -e --work=WORK --workdir=ALL_LIB %FLAG% spiaccess
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\tim1sec.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\ledsm.vhd

