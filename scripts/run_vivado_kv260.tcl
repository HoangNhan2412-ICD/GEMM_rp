# Vivado batch flow for GEMM_TOP on Kria K26/KV260-class part.
# Usage: vivado -mode batch -source scripts/run_vivado_kv260.tcl
set proj_name gemm_kv260
set part_name xck26-sfvc784-2LV-c
set top_name GEMM_TOP
set report_dir reports/kv260
file mkdir $report_dir
create_project -force $proj_name build/$proj_name -part $part_name
add_files [glob rtl/*.v]
add_files -fileset constrs_1 constraints/kv260_core.xdc
set_property top $top_name [current_fileset]
update_compile_order -fileset sources_1
synth_design -top $top_name -part $part_name
report_utilization -file $report_dir/post_synth_utilization.rpt
report_timing_summary -file $report_dir/post_synth_timing_summary.rpt
opt_design
place_design
route_design
report_utilization -file $report_dir/post_impl_utilization.rpt
report_timing_summary -file $report_dir/post_impl_timing_summary.rpt
report_power -file $report_dir/post_impl_power.rpt
report_drc -file $report_dir/post_impl_drc.rpt
write_checkpoint -force $report_dir/post_impl.dcp
