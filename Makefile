reports=out/originating_requirements.html \
	out/use_cases.html \
	out/product_requirements_specifications.html \
	out/physical_architecture.html \
	out/network.html
main=out/main.xml
copyright=
plantuml_host=http://www.plantuml.com

all:$(reports)

validate:$(main) static/schema.dtd
	xmllint --dtdvalid static/schema.dtd --noout $< &&\
		echo 'Model validates'

vis:out/network.html

debug: | static/plantuml.jar
	java -jar static/plantuml.jar -picoweb:8000 & \
	while true; do \
		inotifywait -e modify,create,delete -r model/ && \
			sleep 1 && \
			$(MAKE); \
	done


################################################################################
$(reports):out/%.html:stylesheets/%.xsl $(main)
	xsltproc -o $@ $^

out/graphml.xml:stylesheets/graphml.xsl $(main)
	xsltproc -o $@ $^

$(main): $(sort $(wildcard example_model/*/*.xml))
	mkdir -p $(dir $(main))
	echo '<mbse copyright="$(copyright)" plantuml_host="$(plantuml_host)">' > $@ &&\
	cat $^ >> $@ &&\
	echo '</mbse>' >> $@
