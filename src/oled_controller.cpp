#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Voled_controller.h"

#define MAX_SIM_TIME 20000
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    std::cout << "Running verilator test bench for oled_controller.sv\n";

    // Instantiate verilated module
    Voled_controller *dut = new Voled_controller;

    // Set up waveform dumping
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Run the simulation
    while (sim_time < MAX_SIM_TIME) {

        // Reset DUT at the start of the simulation
        if(sim_time > 5 && sim_time < 10)
        {
            if (sim_time < 2)
                dut->rst_n = 1;
            if (sim_time < 7)
                dut->rst_n = 0;
            if (sim_time > 7)
                dut->rst_n = 1;
        }
        else if (sim_time > 10)
        {

        }

        // Next clk tick
        dut->sclk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
