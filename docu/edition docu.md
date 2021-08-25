**Edition Documentation for The glosses to the first book of the Etymologiae**

Last update: August 2, 2021. Peter Boot

**Introduction**

The edition displays information about the glosses to the first book of Isidore&#39;s _Etymologiae_. The user can display and visualise, but not modify the information. Unique to this edition is the presence of interactive network diagrams. The user can save these diagrams to his workstation.

The edition displays the text of the _Etymologiae_ and hyperlinked to that the glosses made to words or phrases (lemma&#39;s) in the text. The glosses come from various manuscripts. Glosses shared between manuscripts are grouped in clusters which are used to organise the display.

**Context**

The edition is static. There is no server functionality required (beyond serving web pages). A demo edition runs at [http://peterboot.nl/isidore](http://peterboot.nl/isidore). 

**Editon Data**

All data for the edition comes from the Isidore.xml XML file. At runtime, however, this XML file is not used. The relevant information is embedded within the index.html HTML file, several HTML fragments and several javascript files. The XML is documented in [https://xml.huygens.knaw.nl](https://xml.huygens.knaw.nl/).

The edition is a Single Page App where HTML is rebuilt using Javascript.  

**Generation of the edition**

The edition is generated from the XML file using four XSLT stylesheets.

- createhtml.xsl generates index.html (main edition file), htmlfrag/glossnn.html (html fragments (by chapter) for the gloss pages), htmlfrag/textnn.html (html fragments (by chapter) for the text pages) and htmlfrag/glossmsxxxxxxxxxxxx.html (html gfragments by manuscript)
- createnetwork.xsl generates networkaaa.js (json for the various networks)
- createjson.xsl  generates msslist.js, mssgroups.js and clustlistmap.js  (json definition of the manuscripts, of groups of manuscripts and of the the clusters and their relation to the manuscripts)
- shared.xsl (Contains shared functionality)

The javascript files mentioned here only define variables, not actions. They are included in index.html.

**Other files**

Beyond the generated files the edition also uses:

- isidore.css (CSS definitions)
- isidore.js  (Functionality unrelated to the network display)
- isidorenetwork.js (Functionality related to the network display)

**External dependencies**

The edition uses a number of external javascript and CSS files:

- w3.css (CSS framework from [https://www.w3schools.com/w3css/defaulT.asp](https://www.w3schools.com/w3css/defaulT.asp))
- cytoscape.umd.js (Cytoscape.org library for network display)
- cytoscape-context-menus.js (Library for context menus in Cytoscape)
- cytoscape-context-menus.css (CSS for context menus)
- https://unpkg.com/tippy.js@6 (For tooltip display)
- cytoscape-popper.js[https://unpkg.com/@popperjs/core@2](https://unpkg.com/@popperjs/core@2) (For positioning tooltips)
- [https://unpkg.com/layout-base/layout-base.js](https://unpkg.com/layout-base/layout-base.js)https://unpkg.com/cose-base/cose-base.jshttps://unpkg.com/cytoscape-fcose/cytoscape-fcose.js (Fcose layout algorithm in Cytoscape)
