# -*- Makefile -*-
TARGETS = isdm25.pdf
TARGETS_NOEXT = $(patsubst %.pdf,%,$(TARGETS))
DEPS_DIR = .deps
LATEXMK = latexmk -recorder -use-make -deps

# Detect OS to choose correct sed -i form (Linux: "sed -i", macOS/BSD: "sed -i ''")
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
SED_INPLACE = sed -i ''
else
SED_INPLACE = sed -i
endif

all: $(TARGETS)

# Ensure deps dir exists
# Use a recipe (tab-indented) so Make can create the directory as an order-only
# prerequisite; this avoids races when running `make -j` because the directory
# will be created before any recipe that lists it as an order-only prereq.
$(DEPS_DIR):
	mkdir -p $(DEPS_DIR)

define pdfrule
$(1).pdf: $(1).tex | $$(DEPS_DIR)
	$$(LATEXMK) -pdf -deps-out=$$(DEPS_DIR)/$$@P $$<
	$(SED_INPLACE) -e '/\.out\\$$//d;/^[ ]\+\/usr\//d;/^[ ]\+\/var\//d' $$(DEPS_DIR)/$$@P
endef

$(foreach file,$(TARGETS),$(eval -include $(DEPS_DIR)/$(file)P))

$(foreach file,$(TARGETS_NOEXT),$(eval $(call pdfrule,$(file))))

clean:
	-latexmk -pdf -C $(TARGETS_NOEXT)
	rm -rf *.nav *.vrb *.snm *~

distclean: clean
	rm -f $(TARGETS)
	rm -rf $(DEPS_DIR)

.PHONY: clean all distclean
