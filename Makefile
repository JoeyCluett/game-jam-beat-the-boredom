#
# makefile for entry to olc:btb game jam
#
# author: Joe (SevenSignBits)
# built on x86_64 system running Ubuntu 16.04 LTS
# SDL (Simple DirectMedia Layer) is used as the graphics API
# the main build command below links with the SDL dynamic library
#
# links against SDL version 1.2.15
#
# NOTE: I am aware that the general consensus is that SDL1.2 is old 
# and deprecated and we should all be using SDL2. however, most of 
# my experience is with SDL1.2 and I am already familiar with the API
#

ASM=yasm
#OPTS=-f elf64 -i ./src/
OPTS=-g dwarf2 -f elf64 -i ./src/ # with debug info
BUILDCMD=${ASM} ${OPTS}
SRC=./src
OBJ=./obj

FILES= \
 ${OBJ}/main.o \
 ${OBJ}/colors.o \
 ${OBJ}/rect.o \
 ${OBJ}/input.o \
 ${OBJ}/linearmap.o \
 ${OBJ}/font.o

all: main

clean:
	rm ${OBJ}/*

main: obj/ ${FILES}
	gcc -nostartfiles -o main ${FILES} -lSDL -lSDL_gfx

${FILES}: ${OBJ}/%.o: ${SRC}/%.asm
	${BUILDCMD} $< -o $@

obj/:
	mkdir obj
