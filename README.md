# CCGen v0.9.0
A compile_commands.json generator written in lua.

This script functions with default/hardcoded values. It will look for sources
inside of src/, headers in include/ and object files in build/. It will use c++ as
compiler with flags -Wall -Wextra -Werror and --std=c++98.
