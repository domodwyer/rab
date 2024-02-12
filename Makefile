# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME = `sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION`
PKGVERS = `sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION`

.PHONY: all
all: readme doc lint check test

README.md: README.Rmd
	R --quiet --vanilla -e 'devtools::build_readme()'

.PHONY: readme
readme: README.md

.PHONY: build
build: doc
	R CMD build .

.PHONY: check
check: build
	R CMD check --no-manual --as-cran $(PKGNAME)_$(PKGVERS).tar.gz

.PHONY: install_deps
install_deps:
	Rscript --quiet \
		-e 'if (!requireNamespace("remotes")) install.packages("remotes")' \
		-e 'remotes::install_deps(dependencies = TRUE)'

.PHONY: install
install: build
	R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

.PHONY: clean
clean:
	@-rm $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
	@-rm -rd man

.PHONY: lint
lint: install_deps
	Rscript --quiet --vanilla  \
		-e "errors <- lintr::lint_dir(); print(errors); quit(save = 'no', status = length(errors))"

.PHONY: doc
doc:
	R --quiet --vanilla -e 'devtools::document()'

.PHONY: test
test: install_deps
	R --quiet --vanilla -e 'devtools::test()'
