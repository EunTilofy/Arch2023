#!/bin/bash
find sim core common -name "*.v" | xargs iverilog auxillary/CPUTEST.v auxillary/debug_clk.v; vvp a.out