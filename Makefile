all: check build doc install

check:
	R -q -e "devtools::check()"

build:
	# We want to build in the current working dir, rather than the parent dir
	R -q -e "devtools::build(path='.')"

doc:
	R -q -e "devtools::document()"

install:
	R -q -e "devtools::install(build_vignettes = T)"
