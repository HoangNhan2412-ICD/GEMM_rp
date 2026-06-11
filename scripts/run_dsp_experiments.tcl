# Vivado DSP inference experiments for individual GEMM-related tops.
# Usage: vivado -mode batch -source scripts/run_dsp_experiments.tcl
# Reports are written to reports/dsp_experiments/<top_name>/.
# This flow does not modify RTL and does not apply use_dsp attributes.

set part_name xck26-sfvc784-2LV-c
set clock_period_ns 10.000
set tops {PE PE_array MM MM_ultra GEMM_TOP}
set root_report_dir reports/dsp_experiments
file mkdir $root_report_dir

foreach top_name $tops {
    puts "INFO: Running DSP experiment synthesis for top $top_name"
    set proj_name dsp_exp_$top_name
    set proj_dir build/dsp_experiments/$top_name
    set report_dir $root_report_dir/$top_name
    file mkdir $report_dir

    create_project -force $proj_name $proj_dir -part $part_name
    add_files [glob rtl/*.v]
    set_property top $top_name [current_fileset]
    update_compile_order -fileset sources_1

    synth_design -top $top_name -part $part_name

    set clk_ports [get_ports -quiet clk]
    if {[llength $clk_ports] > 0} {
        puts "INFO: Creating 100 MHz clock on port clk for $top_name timing report"
        create_clock -period $clock_period_ns -name clk $clk_ports
    } else {
        puts "WARNING: Top $top_name has no clk port; timing report may contain no clocked paths. Needs verification."
    }

    report_utilization -file $report_dir/post_synth_utilization.rpt
    report_utilization -hierarchical -file $report_dir/post_synth_utilization_hier.rpt

    if {[catch {report_timing_summary -file $report_dir/post_synth_timing_summary.rpt} timing_err]} {
        set fh [open $report_dir/post_synth_timing_summary.rpt w]
        puts $fh "Timing report failed for $top_name: $timing_err"
        puts $fh "Needs verification."
        close $fh
    }

    set dsp_cells [get_cells -hier -quiet -filter {REF_NAME =~ DSP*}]
    set mult_named_cells [get_cells -hier -quiet -filter {NAME =~ *mult* || NAME =~ *product*}]
    set fh [open $report_dir/dsp_cell_probe.rpt w]
    puts $fh "Top: $top_name"
    puts $fh "DSP primitive cells: [llength $dsp_cells]"
    foreach cell $dsp_cells { puts $fh "DSP_CELL $cell [get_property REF_NAME $cell]" }
    puts $fh "Multiplier/product-named cells: [llength $mult_named_cells]"
    foreach cell $mult_named_cells { puts $fh "MULT_NAMED_CELL $cell [get_property REF_NAME $cell]" }
    close $fh

    write_checkpoint -force $report_dir/post_synth.dcp
    close_project
}

puts "INFO: DSP experiments complete. Run: python3 scripts/parse_dsp_experiments.py"
