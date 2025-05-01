# Adapted from Edalize
# https://github.com/olofk/edalize/blob/4a3f3e87/edalize/modelsim.py

onerror { quit -code 1; }
vlib work
vlog +define+SIM -quiet -work work ucsbece154b_alu.v
vlog +define+SIM -quiet -work work ucsbece154b_branch.v
vlog +define+SIM -quiet -work work ucsbece154b_controller.v
vlog +define+SIM -quiet -work work ucsbece154b_datapath.v
vlog +define+SIM -quiet -work work ucsbece154_dmem.v
vlog +define+SIM -quiet -work work ucsbece154_imem.v
vlog +define+SIM -quiet -work work ucsbece154b_riscv_pipe.v
vlog +define+SIM -quiet -work work ucsbece154b_rf.v
vlog +define+SIM -quiet -work work ucsbece154b_top.v
vlog +define+SIM -sv -quiet -work work ucsbece154b_top_tb.v
