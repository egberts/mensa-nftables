# Mensa nftables
#
#   source/  -> all templating
#   build/   -> final file directory layouts needed to reconstruct the
#               nft script file
#
# Targets:
#   help   - show this message
#   all    - generate build/ from source/ (default target)
#   build  - generate the final layouts in build/ from source/

SRC      ?= source
BUILDDIR ?= build
ZONES    ?= arca homelan loopback red

.PHONY: all build help

all: build

help:
	@echo 'Mensa nftables'
	@echo '  all    - generate build/ from source/ (default)'
	@echo '  build  - generate the final layouts in build/ from source/'
	@echo '  help   - show this message'

# ---- generate the final layouts in build/ from source/ ----

build: $(BUILDDIR)/nftables.nft $(BUILDDIR)/template-rules

$(BUILDDIR)/nft-common.nft: $(SRC)/nft-common.nft
	mkdir -p $(BUILDDIR)
	cp -a $< $@

$(BUILDDIR)/types: $(SRC)/1-types Makefile
	mkdir -p $(BUILDDIR)/types
	cp -a $(SRC)/1-types/. $(BUILDDIR)/types/
	find $(BUILDDIR)/types -type f ! -name '*.swp' \
		-exec sed -i \
		-e 's|include "\./2-hooks/|include "$(BUILDDIR)/hooks/|g' \
		-e 's|include "\./hooks/|include "$(BUILDDIR)/hooks/|g' \
		-e 's|include "zones/|include "$(BUILDDIR)/zones/|g' \
		{} +
	find $(BUILDDIR)/types -type f -name '*.swp' -delete

$(BUILDDIR)/devices: $(SRC)/3-devices Makefile
	mkdir -p $(BUILDDIR)/devices
	cp -a $(SRC)/3-devices/. $(BUILDDIR)/devices/
	find $(BUILDDIR)/devices -type f -name '*.swp' -delete
	touch $(BUILDDIR)/devices

$(BUILDDIR)/hooks: $(SRC)/2-hooks $(BUILDDIR)/devices Makefile
	mkdir -p $(BUILDDIR)/hooks
	cp -a $(SRC)/2-hooks/. $(BUILDDIR)/hooks/
	find $(BUILDDIR)/hooks -type f ! -name '*.swp' \
		-exec sed -i \
		-e 's|include "\./zones/|include "$(BUILDDIR)/zones/|g' \
		-e 's|include "zones/|include "$(BUILDDIR)/zones/|g' \
		-e 's|include "3-devices/|include "$(BUILDDIR)/devices/|g' \
		{} +
	find $(BUILDDIR)/hooks -type f -name '*.swp' -delete

$(BUILDDIR)/template-rules: $(SRC)/template-rules Makefile
	mkdir -p $(BUILDDIR)/template-rules
	cp -a $(SRC)/template-rules/. $(BUILDDIR)/template-rules/
	find $(BUILDDIR)/template-rules -type f -name '*.swp' -delete
	touch $(BUILDDIR)/template-rules

$(BUILDDIR)/zones: $(SRC)/4-zones Makefile
	mkdir -p $(BUILDDIR)/zones
	# per-zone dirs: source/4-zones/ZONE -> build/zones/<zone>/
	for z in $(ZONES); do \
		mkdir -p $(BUILDDIR)/zones/$$z; \
		cp -a $(SRC)/4-zones/ZONE/. $(BUILDDIR)/zones/$$z/; \
		find $(BUILDDIR)/zones/$$z -type f ! -name '*.swp' \
			-exec sed -i "s/ZONE/$$z/g" {} +; \
		for f in $(BUILDDIR)/zones/$$z/*ZONE*; do \
			[ -e "$$f" ] || continue; \
			new="$$(echo "$$f" | sed "s/ZONE/$$z/g")"; \
			[ "$$f" = "$$new" ] || mv "$$f" "$$new"; \
		done; \
	done
	# flat set: source/4-zones/zone-*-ZONE.chain -> build/zones/zone-*-<zone>.chain
	for z in $(ZONES); do \
		for f in $(SRC)/4-zones/zone-*-ZONE.chain; do \
			[ -e "$$f" ] || continue; \
			sed -e "s/ZONE/$$z/g" "$$f" > $(BUILDDIR)/zones/$$(basename "$$f" | sed "s/ZONE/$$z/g"); \
		done; \
	done
	find $(BUILDDIR)/zones -type f -name '*.swp' -delete
	# rewrite ./zones/ includes in the generated zone files
	find $(BUILDDIR)/zones -type f ! -name '*.swp' \
		-exec sed -i -e 's|include "\./zones/|include "$(BUILDDIR)/zones/|g' {} +

$(BUILDDIR)/nftables.nft: $(BUILDDIR)/types $(BUILDDIR)/hooks $(BUILDDIR)/zones $(BUILDDIR)/nft-common.nft $(SRC)/nftables.nft
	sed \
		-e 's|include "./nft-common.nft"|include "$(BUILDDIR)/nft-common.nft"|' \
		-e 's|include "1-types/|include "$(BUILDDIR)/types/|g' \
		-e 's|include "types/|include "$(BUILDDIR)/types/|g' \
		-e 's|include "2-hooks/|include "$(BUILDDIR)/hooks/|g' \
		-e 's|include "./hooks/|include "$(BUILDDIR)/hooks/|g' \
		$(SRC)/nftables.nft > $@
