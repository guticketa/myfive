## Clock Signals
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]; #IO_L13P_T2_MRCC_15 Sch=uclk
create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }];
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { CLK }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
#create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { CLK }];

## Misc. ChipKit Ports
#set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { ck_ioa }]; #IO_25_15 Sch=ck_ioa
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports { ck_rst }]; #IO_L11N_T1_SRCC_15

## UART(Pmod)
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { TXD }]; #IO_L7N_T1_D10_14 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { RXD }]; #IO_L8P_T1_D11_14 Sch=ja_p[4]

## LEDs
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L16N_T2_A27_15 Sch=led[2]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L17P_T2_A26_15 Sch=led[3]
set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_L17N_T2_A25_15 Sch=led[4]
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L18P_T2_A24_15 Sch=led[5]