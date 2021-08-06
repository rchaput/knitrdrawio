all: check build doc install

check:
	R -q -e "library(devtools); check()"

build:
	# We want to build in the current working dir, rather than the parent dir
	R -q -e "library(devtools); build(path='.')"

doc:
	R -q -e "library(devtools); document()"

install:
	R -q -e "library(devtools); install()"
