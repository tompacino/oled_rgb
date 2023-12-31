# Digilent PMOD OLED RGB Hardware Driver

This is a work-in-progress (WIP) hardware driver implementation for the [Digilent Pmod OLEDrgb Board](https://digilent.com/shop/pmod-oledrgb-96-x-64-rgb-oled-display-with-16-bit-color-resolution/).

The aim of this project is to provide a simple means of using the Pmod OLEDrgb on the Zybo Z7 platform:
- Physical layer (PL) will be responsible for power on, power of, and boot configuration of the Pmod OLEDrgb
- PL will instantiate a buffer to which processor subsytem (PS) can write SPI commands to control the display
- PS will write to buffer using AXI4/AXI-LITE

## Running as a WIP

Since the project is still a work in progress, I am yet to migrate the project to a complete build system (currently, Bazel build is still WIP).

Building and running the current WIP outputs a .vcd waveform demonstrating basic startup functionality in the controller. This can be done as follows:

1. Run verilator to create a software executable:

```
cd src
verilator -Wall --trace -cc oled_controller.sv oled_power_on.sv timer_microsecond.sv timer_microseconds.sv --exe oled_controller.cpp
```

2. Run the generated executable:

```
./obj_dir/Voled_controller
```

3. View the output waveform using GTKWave:

```
gtkwave waveform.vcd
```

## Resources

The following web pages are relevant to this project:
- [Pmod OLEDrgb reference manual](https://digilent.com/reference/pmod/pmodoledrgb/reference-manual)
  - Contains abridged configuration information and basic I/O specification
- [SSD1331 Datasheet](https://cdn-shop.adafruit.com/datasheets/SSD1331_1.2.pdf)
  - Contains detailed summary of all available SPI commands for the driver IC
