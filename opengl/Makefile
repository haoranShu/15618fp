CC?=gcc
CXX?=g++
AR?=ar

DEFAULT_FLAGS=-O3 -g -DNDEBUG -Wall -Wextra

# First set the flags to their defaults if not supplied externally.
CFLAGS?=$(DEFAULT_FLAGS)
CXXFLAGS?=$(DEFAULT_FLAGS)
LDFLAGS?=$(DEFAULT_LDFLAGS)

# Then add those flags we can't live without, unconditionally.
CFLAGS+=-fPIC -I. -pedantic
CXXFLAGS+=-fPIC -I. -std=c++0x
LDFLAGS+=-lm

.PHONY: all clean

all: libheatmap.a libheatmap.so quad_tree.o gl_utility.o ppm.o main

clean:
	rm -f libheatmap.a
	rm -f libheatmap.so
	rm -f quad_tree.o
	rm -f gl_utility.o
	rm -f ppm.o
	rm -f main
	find . -name '*.[os]' -print0 | xargs -0 rm -f

heatmap.o: heatmap.c heatmap.h
	$(CC) -c $< $(CFLAGS) -o $@

colorschemes/%.o: colorschemes/%.c colorschemes/%.h
	$(CC) -c $< $(CFLAGS) -o $@

libheatmap.a: heatmap.o $(patsubst %.c,%.o,$(wildcard colorschemes/*.c))
	$(AR) rs $@ $^

libheatmap.so: heatmap.o $(patsubst %.c,%.o,$(wildcard colorschemes/*.c))
	$(CC) $(LDFLAGS) -shared -o $@ $^

ppm.o: ppm.cpp
	$(CXX) -c $< $(CXXFLAGS) -o $@

quad_tree.o: quad_tree.cpp
	$(CXX) -c $< $(CXXFLAGS) -o $@

gl_utility.o: gl_utility.cpp
	$(CXX) -framework OpenGL -framework GLUT -c $< $(CXXFLAGS) -o $@

main.o: main.cpp
	$(CXX) -framework OpenGL -framework GLUT -c $< $(CXXFLAGS) -o $@

main: main.o libheatmap.a quad_tree.o gl_utility.o ppm.o
	$(CXX) -framework OpenGL -framework GLUT $^ $(LDFLAGS) -o $@