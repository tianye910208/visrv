TARGET := visrv

CCFLAG := -I3rd/lua-5.3.3/src/ -Isrc/
LDFLAG := -L3rd/lua-5.3.3/
LDLIBS := -llua -ldl -lpthread



SRC := $(wildcard src/*.c)
OBJ := $(SRC:%.c=obj/%.o)

all:$(OBJ)
	@echo [M]Link...
	@mkdir -p bin
	g++ $(OBJ) -o bin/$(TARGET) $(LDFLAG) $(LDLIBS)


obj/%.o:%.c
	@echo [M]Compile C...
	@mkdir -p $(@D)
	gcc -c $< -o $@ $(CCFLAG)

run:
	./bin/$(TARGET) lua/main.lua

clean:
	rm -rf bin
	rm -rf obj















