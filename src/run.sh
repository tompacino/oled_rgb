verilator -Wall --trace -cc oled_controller.sv oled_power_on.sv timer_microsecond.sv timer_microseconds.sv --exe oled_controller.cpp
make -C obj_dir -f Voled_controller.mk Voled_controller
./obj_dir/Voled_controller


