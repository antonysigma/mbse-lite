prefix=out
model_path=example_model
reports=$(prefix)/originating_requirements.html \
	$(prefix)/use_cases.html \
	$(prefix)/product_requirements_specifications.html \
	$(prefix)/physical_architecture.html \
	$(prefix)/network.html
main=$(prefix)/main.xml
copyright=
plantuml_host=http://www.plantuml.com

all:$(reports)

validate:$(main) static/schema.dtd
	xmllint --dtdvalid static/schema.dtd --noout $< &&\
		echo 'Model validates'

vis:$(prefix)/network.html

debug: | static/plantuml.jar
	java -jar static/plantuml.jar -picoweb:8000 & \
	while true; do \
		inotifywait -e modify,create,delete -r model/ && \
			sleep 1 && \
			$(MAKE); \
	done


################################################################################
$(reports):$(prefix)/%.html:stylesheets/%.xsl $(main)
	xsltproc -o $@ $^

out/graphml.xml:stylesheets/graphml.xsl $(main)
	xsltproc -o $@ $^

$(main): $(sort $(wildcard $(model_path)/*/*.xml))
	mkdir -p $(dir $(main))
	echo '<mbse copyright="$(copyright)" plantuml_host="$(plantuml_host)">' > $@ &&\
	cat $^ >> $@ &&\
	echo '</mbse>' >> $@
