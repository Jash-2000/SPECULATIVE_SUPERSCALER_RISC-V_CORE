
# RISC-V Singlecycle CPU Starter Code


## Guide to Run ECI ModelSim

1. Download this directory to ECI.
2. `cd` to the downloaded directory using a terminal.
3. Open a terminal and cd to your ECI directory.
4. Run `make run-gui` to compile your design and open ModelSim
5. Run simulations as normal.

Note that you may have to add this to your `"~/.bashrc"`:

```bash
# ModelSim
export MODEL_TECH=/ece/mentor/ModelSimSE-10.7d/modeltech/bin
export PATH=$PATH:$MODEL_TECH
export LM_LICENSE_FILE=1717@license.ece.ucsb.edu
```

## Implementation Hints

Use the following Verilog snippets to generate the specified hardware. You can see how the Verilog is synthesized into a netlist with this website: <https://digitaljs.tilk.eu/>.

### 2-Input Muxes

```verilog
// http://www.asic-world.com/verilog/operators2.html#Conditional_Operators
assign y = (s) ? (a) : (b);

// http://www.asic-world.com/verilog/vbehave2.html#The_Conditional_Statement_if-else
always @ * begin
    y = b;
    if (s)
        y = a;
end

// http://www.asic-world.com/verilog/vbehave2.html#The_Case_Statement
always @ * begin
    case (s)
        0: y = a;
        1: y = b;
        default: ;
    endcase
end
```

### N-Input Muxes

```verilog
assign y
    = (s==0) ? a
    : (s==1) ? b
    ....
    : (s=={n}) ? {value}
    : x;

always @ * begin
    case (s)
        0: y = a;
        1: y = b;
        ....
        {n}: y = {value};
        default: y = x;
    endcase
end
```
