# Makefile for Piano
# Linus Yang
# Modified By Yang Zhifei

APP = piano

FLEX = flex
BISON = bison
CXX = gcc
CXXFLAGS = -O2 -g
LDFLAGS =

# Workaround for OS X
ifneq ($(wildcard /usr/lib/libl.a),)
	LDFLAGS += -ll
else
	LDFLAGS += -lfl
endif

all: run

run: $(APP)
	./$(APP) < piano.txt > output.txt
	cat output.txt

$(APP): $(APP).tab.c lex.yy.c
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

lex.yy.c: $(APP).l
	$(FLEX) $<

$(APP).tab.c: $(APP).y
	$(BISON) -d $<

clean:
	rm -f $(APP) *.o lex.yy.c 
	rm -f $(APP).tab.c $(APP).tab.c $(APP).tab.h $(APP).output
	rm -f output.txt
	rm -Rf $(APP).dSYM

.PHONY: all clean run
