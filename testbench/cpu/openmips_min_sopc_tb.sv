`include "defines.svh"
`timescale 1ns / 1ps

`ifdef __ICARUS__
`define PATH_PREFIX "./"
`elsif XILINX_SIMULATOR
`define PATH_PREFIX "../../../../../../"
`else
`define PATH_PREFIX "./"
`endif

module openmips_min_sopc_tb ();

`ifdef __ICARUS__
    initial begin
        $dumpfile("build/wave.vcd");
        $dumpvars(0, openmips_min_sopc_tb);
    end
`endif

    logic                clk;
    logic                rst;

    logic                rom_ce;
    logic [`InstAddrBus] inst_addr;
    logic [    `InstBus] inst;

    always #20 clk = ~clk;
    initial begin
        rst = `RstEnable;
        clk = 1'b0;
        #50 rst = `RstDisable;
        #10000 $stop;
    end

    openmips_min_sopc openmips_min_sopc0 (
        .clk(clk),
        .rst(rst),

        .rom_ce(rom_ce),
        .inst_addr(inst_addr),
        .inst(inst)
    );

    inst_rom inst_rom0 (
        .ce  (rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );

    logic post_stall;
    assign post_stall = 0;

    string path = {`PATH_PREFIX, "testbench/cpu/testcases/"};
    string summary;

    task judge(input integer fans, input integer cycle, input string out);
        string ans;
        $fscanf(fans, "%s\n", ans);
        if (out != ans && ans != "skip") begin
            $display("[%0d] %s", cycle, out);
            $display("[Error] Expected: %0s, Got: %0s", ans, out);
            $stop;
        end else begin
            $display("[%0d] %s [%s]", cycle, out, ans == "skip" ? "skip" : "pass");
        end
    endtask

    task unittest_(input string name, input integer check_fpu, input integer check_total_cycles);
        integer i, fans, fmem, cycle, path_counter, mem_counter, last_write;
        integer instr_count;
        string ans, out, info;

        begin
            fans        = $fopen({path, name, ".ans"}, "r");
            fmem        = $fopen({path, name, ".mem"}, "r");
            mem_counter = 0;
            while (!$feof(
                fmem
            )) begin
                $fscanf(fmem, "%x", inst_rom0.inst_mem[mem_counter]);
                mem_counter = mem_counter + 1;
            end
            $fclose(fmem);
            // $readmemh({ path, name, ".mem" }, ibus_inst.mem);
        end

        begin
            rst = 1'b1;
            #50 rst = 1'b0;
        end

        $display("======= unittest: %0s =======", name);

        instr_count = 0;
        cycle       = 0;
        while (!$feof(
            fans
        )) begin
            @(negedge clk);
            cycle = cycle + 1;

            if (openmips_min_sopc0.openmips0.wb_wd_i != '0) begin
                $sformat(out, "$%0d=0x%x", openmips_min_sopc0.openmips0.wb_wd_i,
                         openmips_min_sopc0.openmips0.wb_wdata_i);
                judge(fans, cycle, out);
                last_write = openmips_min_sopc0.openmips0.wb_wdata_i;
            end

            // if (openmips_min_sopc0.openmips0.mem_whilo_i) begin
            //     $sformat(out, "$hilo=0x%x", pipe_wb[0].hiloreq.wdata);
            //     judge(fans, cycle, out);
            // end
        end

        $display("[OK] %0s\n", name);
        $sformat(summary, "%0s%0s: CPI = %f\n", summary, name, $itor(cycle) / $itor (instr_count));

    endtask

    task unittest(input string name);
        unittest_(name, 0, 0);
    endtask

    initial begin
        wait (rst == 1'b0);
        summary = "";
        unittest("inst/ori");
        unittest("inst/logical");
        unittest("inst/shift");
        unittest("inst/move");
        unittest("inst/arith");
        unittest("inst/jump");
        $display(summary);
        $display("[Done]\n");
        $finish;
    end

endmodule
