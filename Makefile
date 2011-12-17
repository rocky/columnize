# I'll admit it -- I'm an absent-minded old-timer who has trouble
# learning new tricks.
test: check

#: Default target; same as "make check"
all: check
	true

#: Same as corresponding rake task
%: 
	rake $@
