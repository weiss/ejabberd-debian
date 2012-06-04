SRC = $(wildcard *.erl)
BEAMS = $(SRC:.erl=.beam)

all: test ;

compile: $(BEAMS) ;

%.beam: %.erl
	erlc +debug_info $^

test: $(BEAMS)
	erl -noshell -pa "$(CURDIR)" -run test test -run init stop

clean:
	-rm -f $(BEAMS)

.PHONY: all compile clean test

