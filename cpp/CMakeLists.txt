cmake_minimum_required(VERSION 3.16)
project(task_scheduler)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

qt_add_executable(task_scheduler
    main.cpp
    task_scheduler.cpp
    task_scheduler.hpp
)

target_link_libraries(task_scheduler PRIVATE Qt6::Widgets)