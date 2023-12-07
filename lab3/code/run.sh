#!/bin/bash
find sim core common -name "*.v" -or -name "*.sv" | xargs iverilog -g2012 auxillary/CPUTEST.v auxillary/debug_clk.v; vvp a.out