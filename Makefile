ASM=yasm
OPTS=-f elf64
BUILDCMD=${ASM} ${OPTS}
SRC=./src
OBJ=./obj

FILES= \
 ${OBJ}/main.o \
 ${OBJ}/colors.o

all: main

clean:
	rm ${OBJ}/*

main: ${FILES}
	gcc -nostartfiles -o main ${FILES} -lSDL

${FILES}: ${OBJ}/%.o: ${SRC}/%.asm
	${BUILDCMD} $< -o $@


