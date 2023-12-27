#!/bin/bash
find sim core cache common -maxdepth 1 -name "*.v" | xargs iverilog auxillary/CPUTEST.v auxillary/debug_clk.v; vvp a.out