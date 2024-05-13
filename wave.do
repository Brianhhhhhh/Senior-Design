onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IF
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iPC/clk
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iPC/pc
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iIM/instr
add wave -noupdate -divider ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/addr_cur_ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/instr
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/rf_dst_addr
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/rf_p0_addr
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/rf_p1_addr
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/rf_re0
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/rf_re1
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/rf_we
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/src0sel
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iId/src1sel
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/stall_p0
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/stall_p1
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/p0_ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/p0_ID_temp
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/p1_ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/p1_ID_temp
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iBRL/flow_change
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_we_ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_re_ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/br_cc_ID
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iRF/sram0/mem
add wave -noupdate -divider EX
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/addr_cur_EX
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/instr_EX
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_re_EX
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_we_EX
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/p1_EX
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iALU/src0
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iALU/src1
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/alu_rslt_EX
add wave -noupdate -divider dm
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iDM/clk
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/addr_cur_DM
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/instr_DM
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/p1_DM
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/alu_rslt_DM
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_re_DM
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_we_DM
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iDM/wrt_data
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iDM/rd_data
add wave -noupdate -divider wb
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/alu_rslt_WB
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dm_re_WB
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/dst_WB
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/addr_cur_WB
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iDSTMUX/alu_rslt
add wave -noupdate /Final_Demo_tb/iDUT/iCPU/iDSTMUX/mem_data
add wave -noupdate /Final_Demo_tb/iDUT/busy
add wave -noupdate /Final_Demo_tb/iDUT/add_fnt
add wave -noupdate /Final_Demo_tb/iDUT/add_img
add wave -noupdate /Final_Demo_tb/iDUT/fnt_indx
add wave -noupdate /Final_Demo_tb/iDUT/image_indx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {183765000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 371
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {119562838 ps} {406354588 ps}
