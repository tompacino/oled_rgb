load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@rules_verilator//verilator:defs.bzl", "sv_library", "verilator_cc_library")

sv_library(
    name = "timer_lib",
    srcs = ["timer_microsecond.sv",
            "timer_microseconds.sv"
    ],
)

sv_library(
    name = "oled_controller_lib",
    srcs = ["oled_controller.sv",
            "oled_power_on.sv",
    ],
)

verilator_cc_library(
    name = "oled_controller",
    mtop = "oled_controller",
    deps = [":oled_controller_lib",
            ":timer_lib"
    ],
)

cc_binary(
    name = "sim",
    srcs = ["oled_controller.cpp"],
    deps = [":oled_controller"],
)
