set PROJECT soc

set_option -output_base_name $PROJECT
set_option -gen_verilog_sim_netlist 1
set_device GW1NR-LV9QN88PC6/I5
add_file tangnano9k.cst
add_file $PROJECT.v
run all