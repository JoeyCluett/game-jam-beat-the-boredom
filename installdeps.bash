#!/bin/bash


DEPS=( \
 "libsdl1.2debian" \
 "libsdl1.2-dev" \
 "libsdl-gfx1.2-5" \
 "libsdl-gfx1.2-dev" )

for dep in "${DEPS[@]}"; do
    sudo apt install $dep
done



