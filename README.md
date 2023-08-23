A very simple risc-v implementation using a single Verilog file and [Sipeed Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html) FPGA (Gowin). Verilog code is taken and modified from [BrunoLevy's FemtoRV tutorial](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV). Also uses [theandrew168's bronzebeard](https://github.com/theandrew168/bronzebeard) for assembling, [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build) for simulation/upload and [Gowin EDA Education](https://www.gowinsemi.com/en/support/home/) for synthesis. Currently working in Windows, but can be trivially made to work in Linux.

Modify `env.bat` point to oss-cad-suite's `environment.bat`, and in `makefile`, change the `GW_SH` variable to point to your Gowin EDA installation. In a Windows Command Prompt, run `env.bat` to add oss-cad-suite tools to your path.

To assemble your code, (for example `count.S`), run `python3 as.py count.S`. This will generate the `count_ascii.hex` file containing the binary code written in ascii characters. Load this file by changing the relevant line in `soc.v`.

Finally, run `make test` to simulate your code (with the corresponding testbench `soc_tb.v`). Run `make build` to synthesize and generate the bitstream. Run `make load` to load it into your Tang Nano 9K's flash memory.
