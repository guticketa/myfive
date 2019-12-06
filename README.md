# myfive

myfive is a simple RISC-V CPU core.

## Features

* RV32I instruction set only (without fence.i)
* Machine mode (M-mode) only
* not support interrupt
* harvard architecture
* 3-stage pipeline

## Generate bitstream

* Vivado 2018.3
* Board: Digilent Arty S7-50

In the Vivado HLS Command Prompt, run the following command:
```
> cd fpga
> make
```

# Memory Map

| Base | Top | Description | Notes |
| - | - | - | - |
| 0x0000_0000 | 0x0000_ffff | Program | Block-RAM 64KB |
| 0x0001_0000 | 0x0fff_ffff | *Reserverd* | *Reserved* |
| 0x1000_0000 | 0x1000_ffff | RAM | Distibuted-RAM 64KB |
| 0x1001_0000 | 0x1fff_ffff | *Reserverd* | *Reserved* |
| 0x2000_0000 | 0x2000_0fff | UART | Peripheral |
| 0x2000_1000 | 0xffff_ffff | *Reserverd* | *Reserved* |

