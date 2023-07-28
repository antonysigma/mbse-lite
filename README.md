# MBSE-lite

System requirement tracking and design synthesis with a simplified schema.

A simple platform to organize product design requirements. Text editor only.
Execute a single command to generate technical document for weekly design review
meetings. Inspired from [Nichole Kass's online seminar](https://youtu.be/0MjopluRTaw),
we decouple the stakeholder's needs, system design problems, and the solutions.

Inputs:

* Stakeholder's needs in plain English.

* System design constraints and performance from first principles.

* Hyperlinks to the trace study documents.

* Reused physical architecture and interfaces, if the project goal is to
  re-design a legacy system.

System design tools:

* MBSE model schema validation;
* Orphaned requirements detection;
* UML diagram generators;
* (Work in progress) functional analysis with IDEF-0 diagrams;
* Requirement traceability queries using network topology visualizations and graph algorithms;


Output documents for ad-hoc design review meetings:

* "External" requirement document;
* Use case document;
* Product requirement specifications;
* Physical architecture;

## Status

Currently the MBSE report generation process is a **very** early work in
progress. Do not use it in production.

## How to build

On linux system, install the dependencies:
```bash
sudo apt install xsltproc libxml2-utils make
```

Next, run `make all` to generate the system design documents in the output folder. They are intended
to be read only; all design revisions should be edited in the `example_model`
folder.

**Advanced usage**

```
$ make help
Available rules:

all                 Generate all system requirement reports in the `out/` folder. 
graph               Export the requirement traceability data as GraphML. 
validate            Validate the system model for broken links. 
vis                 Visualize the requirement traceability with the network mesh plot. 
watch               Watch the `example_model/` folder for new changes; regenerate reports.
```

## Approaching the documents

Writers practicing model-based system engineering (MBSE) is recommended to watch
[Nichole Kass's online seminar](https://youtu.be/0MjopluRTaw) to understand the
underlying assumption of the product design flow.

The phone charger mock-up project is provided in the folder `example_model/` as
an example. It contains the itemized stakeholder's needs, product requirements,
design constraints, and the preliminary functional architecture and physical
architecture. The design items are encoded as individual `*.xml` files.

To begin with, build the technical reports by `make all`, and then open the
generated `out/*.html` pages in the web browser.

Next, edit the `*.xml` files with your favorite editors to reflect new system
requirements and high-level architectures. Update the corresponding reports by
running either `make all` or `make watch`. Explore how your changes in the
`example_model/` folder is reflected in the generated reports.


## Contributing

I accept reasonable feature enhancement requests at
https://github.com/antonysigma/mbse-lite/issues , as well as pull requests.

**Nice to have features**

[ ] Self-documention: create a new folder `design_criteria_model/*.xml` to
clarify MBSE-lite's own design criteria (e.g. why the absence of editor apps),
as well as 

[ ] Instructions to decouple the proprietary `model/` folder with the BSD
licensed `mbse-lite` folder via the "Copyright" feature.

[ ] Instructions to host the PlantUML and the IDEF-0 diagrams services within
the company's private network.

[ ] Explore how to transcode the HTML pages to PDFs.

[ ] Visualize the requirement traceability graphs as hierarchy trees, not as a
mesh.

[ ] Implement other MBSE document templates for auditing purposes.

## Why I made my own tools

As I deal with ever more complex systems as a
giga-pixel microscopy researcher, I found the need of an end-to-end requirement
management system that traces the stakeholder's needs, through the functional
requirements & design constraints, to the physical architecture. I also need a
tool to reason about how the design solutions (e.g.
Optical/Mechanical/Electronic component specifications, software interfaces
specifications, and SOPs) can verify the requirements, and can be validated with
test plans.

The challenge stems from the so-called document-oriented approach, used by 99%
of resarch labs, startups, and OEM vendors. Traditionally, we use a collection
of Powerpoints slides, Documents, and freehand drawings for communications; all
these are labor intensive because these vendors uses incompatible document
processing tools, namely Confluence, Emails, PDFs, and Word documents. I ended
up spending more of the time copy editing system design requirements from one
vendors to another, rather than spending the time on the *design* itself.

I also came across the model-based system engineering (MBSE) approach, but I
found all existing commercial tools too bloated for medium sized projects having
less than 50 projects members, including vendors. For instance, I do not need
the code generation feature as my SW vendor will be developing their own
software and test plans. Also, one doesn't need to "allocate" a function to
multiple instance because most functions in the system are used exactly once for
giga-pixel imaging projects. One also doesn't need Zemax and Matlab integration
to the parametrics design module, as most PhDs roll out their own simulation
tools for academic publications.

After all, Those commercial tools are designed to serve the NASA scale projects
and defense contractors in 3 orders of magniture in team size. For medium-sized
projects, we don't often pay for what we don't use.

## Reference

Nichole Kass, James Kolozs (2016). Getting Started with MBSE in Product Development.
INCOSE International Symposium.
 https://doi.org/10.1002/j.2334-5837.2016.00176.x
