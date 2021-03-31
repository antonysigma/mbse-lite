reports=out/originating_requirements.html \
	out/use_cases.html \
	out/product_requirements_specifications.html \
	out/physical_architecture.html \
	out/network.html
main=out/main.xml
copyright=Mango Inc

all:$(reports)

validate:$(main) static/schema.dtd
	xmllint --dtdvalid static/schema.dtd --noout $< &&\
		echo 'Model validates'

vis:out/network.html

################################################################################
$(reports):out/%.html:stylesheets/%.xsl $(main)
	xsltproc -o $@ $^

out/graphml.xml:stylesheets/graphml.xsl $(main)
	xsltproc -o $@ $^

$(main): $(sort $(wildcard example_model/*/*.xml))
	mkdir -p $(dir $(main))
	echo '<mbse copyright="$(copyright)">' > $@ &&\
	cat $^ >> $@ &&\
	echo '</mbse>' >> $@
