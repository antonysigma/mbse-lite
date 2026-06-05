import sys
from xml.etree import ElementTree as etree

import requests
from plantuml_decoder import plantuml_encode


def get_svg(url: str):
    """Initiate the HTTP GET request given the URL string."""
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for bad responses

        # Check if the response content type is SVG
        if "image/svg+xml" in response.headers.get("Content-Type", ""):
            svg_payload = response.text
            return svg_payload
        else:
            print("The content is not SVG.")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching URL: {e}")
        return None


def replace_element(parent, elem, new_elem):
    """A convenience function to replace XML tag <a> with <b> ."""
    parent_index = list(parent).index(elem)
    parent.remove(elem)
    parent.insert(parent_index, new_elem)


def download_svg(dom, class_name: str, port: int):
    """Given an XML document representing a static HTML page, find all `<code
    class="uml">`. Extract the contents in PlantUML language, and then invoke
    the WebAPI to render the static SVG figure. Replace the `<code>` tag with
    `<img src="" alt=""/>` embedding the SVG figure."""

    parent_map = {c: p for p in dom.iter() for c in p}

    # Get all elements with attribute class='uml'
    for element in dom.findall(f'.//*[@class="{class_name}"]'):
        # Replace the text of the element with an empty <svg> tag
        if element.text is None:
            continue

        encoded = plantuml_encode(
            f"skin rose\n{element.text}" if class_name == "uml" else element.text
        )
        url = f"http://localhost:{port}/svg/{encoded}"
        svg_payload = get_svg(url)

        svg_element = etree.fromstring(svg_payload)
        parent = parent_map[element]
        replace_element(parent, element, svg_element)

    return dom


def remove_namespace(doc, namespace):
    """Remove namespace in the passed document in place."""
    ns = "{%s}" % namespace
    nsl = len(ns)
    for elem in doc.iter():
        if elem.tag.startswith(ns):
            elem.tag = elem.tag[nsl:]


if __name__ == "__main__":
    # Example usage
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} path/to/xml")
        exit()

    # Load the XML file
    dom = etree.parse(sys.argv[1])

    dom = download_svg(dom, class_name="uml", port=8080)
    dom = download_svg(dom, class_name="idef0", port=5000)
    remove_namespace(dom, "http://www.w3.org/2000/svg")

    # Return or save the modified DOM as a string
    dom.write(sys.argv[1], encoding="utf-8", method="html")
