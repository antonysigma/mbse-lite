SHELL:=/bin/bash

prefix=out
model_path=example_model
reports=$(prefix)/originating_requirements.html \
	$(prefix)/use_cases.html \
	$(prefix)/product_requirements_specifications.html \
	$(prefix)/logical_and_physical_architecture.html \
	$(prefix)/network.html
main=$(prefix)/main.xml
copyright=
plantuml_host=http://www.plantuml.com

## Generate all system requirement reports in the `out/` folder.
all:$(reports)

## Validate the system model for broken links.
validate:$(main) static/schema.rng
#	java -jar static/jing.jar -c static/schema.rnc $<
	xmllint --noout --relaxng static/schema.rng $< &&\
		echo 'Model validates'

## Visualize the requirement traceability with the network plot.
vis:$(prefix)/network.html

## Watch the `example_model/` folder for new changes; regenerate reports.
watch: | static/plantuml.jar
	java -jar static/plantuml.jar -picoweb:8000 & \
	while true; do \
		inotifywait -e modify,create,delete -r model/ && \
			sleep 1 && \
			$(MAKE); \
	done

## Export the requirement traceability data as GraphML.
graph: $(prefix)/graphml.xml

################################################################################
$(reports):$(prefix)/%.html:stylesheets/%.xsl $(main)
	xsltproc -o $@ $^

$(prefix)/graphml.xml:stylesheets/graphml.xsl $(main)
	xsltproc -o $@ $^

$(main): $(sort $(wildcard $(model_path)/*/*.xml))
	mkdir -p $(dir $(main))
	echo '<mbse copyright="$(copyright)" plantuml_host="$(plantuml_host)" idef0svg_host="$(idef0svg_host)">' > $@ &&\
	cat $^ >> $@ &&\
	echo '</mbse>' >> $@

################################################################################
# Implementation of self-documenting help
# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.

.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=19 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'|more $(shell test $(shell uname) == Darwin && echo '-Xr')
