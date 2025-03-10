# compile file .sv
vlog *.sv
vsim -novopt tb_topSystolicArray.sv
add wave -r /*
run -all
