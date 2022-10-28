add_executable(gea main.cpp)

target_link_options(gea PUBLIC -static -static-libgcc -static-libstdc++)
