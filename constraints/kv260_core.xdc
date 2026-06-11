# Baseline KV260/K26 timing constraint. Needs verification in board/Vivado project.
create_clock -period 10.000 -name clk [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports -quiet *]
