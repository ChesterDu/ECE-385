transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/register_8.sv}
vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/lab5_toplevel.sv}
vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/DFF.sv}
vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/control.sv}
vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/adder.sv}

vlog -sv -work work +incdir+C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new {C:/Users/Yangkai/Desktop/2020Spring/ECE385/lab5_new/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 6000 ns
