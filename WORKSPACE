load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_verilator",
    strip_prefix = "rules_verilator-0.1-rc4",
    sha256 = "c0d7a13f586336ab12ea60cbfca226b660a39c6e8235ac1099e39dd2ace3166f",
    url = "https://github.com/kkiningh/rules_verilator/archive/v0.1-rc4.zip",
)

load(
    "@rules_verilator//verilator:repositories.bzl",
    "rules_verilator_dependencies",
    "rules_verilator_toolchains",
)

rules_verilator_dependencies()
rules_verilator_toolchains()

# Register toolchain dependencies
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")
flex_register_toolchains()

load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")
bison_register_toolchains()
