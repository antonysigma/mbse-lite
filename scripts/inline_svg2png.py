import sys
import os
from xml.etree import ElementTree as etree

import requests
from plantuml_decoder import plantuml_encode


def replace_element(parent, elem, new_elem):
    """A convenience function to replace XML tag <a> with <b> ."""
    parent_index = list(parent).index(elem)
    parent.remove(elem)
    parent.insert(parent_index, new_elem)


def inline_svg2png_files(dom, html_name, dir_name):
    """Given an XML document representing a static HTML page, 
    find all <svg>, place the content in img/[filename].svg,
    use statc/svg2png.jar to convert it into img/[filename].png,
    replace the <svg> by <img src="img/[filename].png" alt="" />"""
    parent_map = {c: p for p in dom.iter() for c in p}
    count = 0
    img_dir = os.path.join(dir_name,"img")
    os.system("mkdir -p %s" % img_dir)
    
    for svg_element in dom.findall('.//svg'):
        svg_text = etree.tostring(svg_element) \
                   .decode('UTF-8') \
                   .replace('<svg',
                   '<svg xmlns="http://www.w3.org/2000/svg" \
                    xmlns:xlink="http://www.w3.org/1999/xlink"', 1)
        svg_file_name = "_%s_%s.svg" % (html_name, str(count).zfill(5))
        png_file_name = "_%s_%s.png" % (html_name, str(count).zfill(5))
        svg_file = open(os.path.join(img_dir,svg_file_name), 'w')
        print(svg_text, file=svg_file)
        svg_file.close()
        os.system("java -jar ../static/svg2png.jar -o %s -f %s" 
                  % (img_dir, os.path.join(img_dir, svg_file_name)))
        png_element = etree.fromstring('<img src="%s" alt="" />'
                                       % os.path.join(img_dir, png_file_name))
        parent = parent_map[svg_element]        
        replace_element(parent, svg_element, png_element)
        count += 1

    return dom


if __name__ == "__main__":
    # Example usage
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} path/to/xml")
        exit()

    # Check whether the svg2png Java program exists
    if not(os.path.exists("../static/svg2png.jar")):
        print(f"Error: ../static/svg2png.jar not found")
        exit()


    # Load the XML file
    dom = etree.parse(sys.argv[1])

    dom = inline_svg2png_files(dom, 
                               os.path.splitext(
                                   os.path.basename(sys.argv[1])
                               )[0], 
                               os.path.dirname(sys.argv[1]))
    
    # Return or save the modified DOM as a string
    dom.write(os.path.join(os.path.dirname(sys.argv[1]),
                           "_"+os.path.basename(sys.argv[1])),
              encoding="utf-8",
              method="html")
