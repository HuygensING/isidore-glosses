<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="xs tei hi map" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" 
    xmlns:hi="http://xmlschema.huygens.knaw.nl/ns/">

    <xsl:import href="shared.xsl"/>
    
    <xsl:output method="html"/>

    <xsl:key name="source" match="hi:source[ancestor::tei:gloss]" use="@target"/>
    <xsl:key name="glossGrp" match="hi:glossGrp" use="hi:removehash(@target)"/>
    <xsl:key name="interp" match="tei:interp[parent::tei:interpGrp[@type='clusters']]" use="@xml:id"/>
    <xsl:key name="language" match="tei:interp[parent::tei:interpGrp[@xml:id='lang']]" use="@xml:id"/>
    <xsl:key name="bibl" match="tei:bibl" use="@xml:id"/>
    <xsl:key name="seg" match="tei:seg" use="@xml:id"/>
    <xsl:key name="gloss" match="tei:gloss" use="@xml:id"/>
    <xsl:key name="glossClusterhap" match="tei:gloss" use="key('seg',hi:removehash(parent::hi:glossGrp/@target))[1]/ancestor::tei:div[@type='chapter'][1]/@n"/>
    <xsl:key name="ptr" match="tei:ptr[parent::hi:glossCluster]"
        use="hi:removehash(@target)"/>
    <xsl:key name="closscorresp" match="tei:gloss" use="hi:removehash(@corresp)"/>
    
    <xsl:variable name="comment">
        <xsl:call-template name="createcomment"/>
    </xsl:variable>
    
    <xsl:variable name="preprocess">
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="copy"/>
        </xsl:copy>
    </xsl:variable>
    
    <xsl:variable name="mslist" as="xs:string *">
        <xsl:for-each select="//tei:msDesc">
            <xsl:sequence select="@xml:id"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="/">
<!--        <xsl:result-document href="preprocess.xml" omit-xml-declaration="no" method="xml">
            <xsl:copy-of select="$preprocess"/>
        </xsl:result-document>-->
        <xsl:variable name="title"><xsl:apply-templates select="//tei:titleStmt/tei:title"/></xsl:variable>
        <html>
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <head>
                <title><xsl:value-of select="$title"/></title>
                <link rel="apple-touch-icon" sizes="180x180" href="pics/icon/apple-touch-icon.png"/>
                <link rel="icon" type="image/png" sizes="32x32" href="pics/icon/favicon-32x32.png"/>
                <link rel="icon" type="image/png" sizes="16x16" href="pics/icon/favicon-16x16.png"/>
                <link rel="manifest" href="pics/icon/site.webmanifest"/>
                <!-- cytoscape -->
                <link rel="stylesheet" href="cytoscape-context-menus.css"/>
                <script src="cytoscape.umd.js" type="text/javascript"/>
                <script src="cytoscape-context-menus.js" type="text/javascript"/>
                <script src="https://unpkg.com/layout-base/layout-base.js"></script>
                <script src="https://unpkg.com/cose-base/cose-base.js"></script>
                <script src="https://unpkg.com/cytoscape-fcose/cytoscape-fcose.js"></script>
                <script src="https://unpkg.com/@popperjs/core@2"></script>
                <script src="cytoscape-popper.js"></script>
                <script src="https://unpkg.com/tippy.js@6"></script>
                <!-- mine -->
                <link rel="stylesheet" href="isidore.css"/>
                <!-- W3 CSS -->
                <link rel="stylesheet" href="w3.css"/>
                <!-- data -->
                <script src="msslist.js" type="text/javascript"/>
                <script src="mssgroups.js" type="text/javascript"/>
                <script src="clustlistmap.js" type="text/javascript"/>
                <script src="network_ms.js" type="text/javascript"/>
                <script src="network_ms_clus.js" type="text/javascript"/>
                <script src="network_ms_div.js" type="text/javascript"/>
            </head>
            <body>
                <div id="left">
                    <div class="w3-sidebar w3-bar-block w3-card w3-black" id="leftmenu">
                        <h5 class="w3-bar-item w3-small w3-button">Menu</h5>
                        <button class="w3-bar-item w3-button lefttablink w3-red w3-small" onclick="openlefttab('home','',true)" id="tabhome">Home</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('intro','',true)" id="tabintro">Intro</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('msdesc','',true)" id="tabmsdesc">Ms desc</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('msstats','',true)" id="tabmsstats">Ms stats</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('clusters','',true)" id="tabclusters">Clusters</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('networks','',true)" id="tabnetworks">Networks</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('sources','',true)" id="tabsources">Sources</button>
                        <button class="w3-bar-item w3-button lefttablink w3-small" onclick="openlefttab('biblio','',true)" id="tabbiblio">Biblio</button>
                        <xsl:for-each select="//tei:div[@type='chapter']">
                            <button class="w3-bar-item w3-button w3-small lefttablink">
                                <xsl:attribute name="id">
                                    <xsl:text>tab</xsl:text>
                                    <xsl:value-of select="@n"/>
                                </xsl:attribute>
                                <xsl:attribute name="onclick">
                                    <xsl:text>openlefttab('</xsl:text>
                                    <xsl:value-of select="@n"/>
                                    <xsl:text>','',true)</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="@n"/>
                            </button>
                        </xsl:for-each>
                    </div>
                    <div id="home" class="w3-container lefttab w3-animate-opacity">
                        <h2><xsl:value-of select="$title"/></h2>
                        <h4>Edited by <xsl:apply-templates select="//tei:titleStmt/tei:editor"/></h4>
                        <p>
                            <xsl:apply-templates select="//tei:titleStmt/tei:respStmt/tei:resp"/>
                            <xsl:text>: </xsl:text>
                            <xsl:apply-templates select="//tei:titleStmt/tei:respStmt/tei:name"/>
                        </p>
                        <p style="color:white">-</p>
                        <p style="color:green">
                            <xsl:if test="//tei:TEI/@status = 'alpha' or //tei:TEI/@status = 'beta'">
                                <xsl:text>Edition status: </xsl:text>
                                <xsl:value-of select="//tei:TEI/@status"/>
                            </xsl:if>
                        </p>
                        <p style="color:green"><xsl:apply-templates select="//tei:publicationStmt/tei:availability/tei:p/node()"/></p>
                        <p style="color:white">-</p>
                        <p>
                            <xsl:text>Published by: </xsl:text>
                            <xsl:apply-templates select="//tei:publicationStmt/tei:publisher/tei:name"/>
                            <br/>
                            <xsl:apply-templates select="//tei:publicationStmt/tei:pubPlace"/>
                            <br/>
                            <xsl:apply-templates select="//tei:publicationStmt/tei:date"/>
                            <br/>
                            <xsl:text>Licence: </xsl:text>
                            <a href="{substring-before(//tei:publicationStmt/tei:availability/tei:licence/@target,' ')}"><xsl:apply-templates select="//tei:publicationStmt/tei:availability/tei:licence/tei:p/node()"/></a>
                            <br/>
                            <xsl:text>GitHub: </xsl:text>
                            <a href="{//tei:publicationStmt/@source}"><xsl:value-of select="//tei:publicationStmt/@source"/></a>
                            <br/>
                            <br/>
                            <xsl:text>Funded by:</xsl:text>
                            <br/>
                            <xsl:apply-templates select="//tei:titleStmt/tei:funder"/>
                        </p>
                        <p> <a href="{//tei:publicationStmt/tei:publisher/tei:name/@ref}">
                                <img src="pics/huygens-logo.gif" title="Published by Huygens ING" height="37px"/>
                            </a>
                            <seg style="color:white">---</seg>
                            <a href="{//tei:titleStmt/tei:funder/tei:name/@ref}">
                                <img src="pics/nwo-logo.jpg" title="Funded by NWO" height="37px"/>
                            </a>
                            <seg style="color:white">---</seg>
                            <a href="http://www.tei-c.org/">
                                <img src="https://www.tei-c.org/About/Badges/powered-by-TEI.png" title="Powered by TEI" height="37px"/>
                            </a>
                            <seg style="color:white">---</seg>
                            <a href="https://js.cytoscape.org/">
                                <img src="pics/cytoscape-logo.png" title="Powered by Cytoscape.js" height="37px"/>
                            </a>
                        </p>
                    </div>
                    <div id="intro" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <xsl:apply-templates select="//tei:front/tei:div[@xml:id = 'introduction']"/>
                    </div>
                    <div id="clusters" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <xsl:apply-templates select="//tei:front/tei:div[@xml:id = 'clusters']"/>
                    </div>
                    <div id="msdesc" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <xsl:call-template name="msdesc"/>
                    </div>
                    <div id="msstats" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <xsl:call-template name="msstats"/>
                    </div>
                    <div id="networks" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <xsl:apply-templates select="//tei:front/tei:div[@xml:id = 'networktext']"/>
                    </div>
                    <div id="sources" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <div>
                            <xsl:apply-templates select="//tei:front/tei:div[@xml:id = 'sources']"/>
                            <xsl:apply-templates select="$preprocess//tei:standOff//tei:bibl" mode="source"/>
                        </div>
                    </div>
                    <div id="biblio" class="w3-container lefttab w3-animate-opacity" style="display:none">
                        <xsl:apply-templates select="//tei:front/tei:div[@xml:id = 'bibliography']"/>
                    </div>
                    <div id="text" class="w3-container lefttab w3-animate-opacity" style="display:none"/>
                </div>
                <div id="right">
                    <div class="w3-bar w3-black">
                        <button class="w3-bar-item w3-button tablink" onclick="openisitab('glosses',true)" id="glossesb">Glosses (chapter)</button>
                        <button class="w3-bar-item w3-button tablink" onclick="openisitab('manuscripts',true)" id="manuscriptsb">Glosses (manuscripts)</button>
                        <button class="w3-bar-item w3-button tablink" onclick="openisitab('network',true)" id="networkb">Network</button>
                    </div>
                    <div id="glosses" class="w3-container w3-border isitab w3-animate-opacity">
                    </div>
                    <div id="manuscripts" class="w3-container w3-border isitab w3-animate-opacity">
                    </div>
                    <div id="network" class="w3-container w3-border isitab" style="display:none">
                        <div>
                            <p style="font-size:smaller">Explanations in the <span class="hyperlink" onclick="openlefttab('networks','',true)">Networks</span> tab. Change settings 
                                <span class="hyperlink" onclick="document.getElementById('modal-04').style.display = 'block';">here</span>. Filter by weight below or 
                                interact with the graph directly.</p>
                        </div>
                        <div class="w3-container">
                            <div id="rangediv" class="w3-container" style="position:relative;left:30px%">
                                    <div id="lowbound">From: <span id="lowboundval">0</span></div>
                                    <div id="range"><input type="range" min="0" max="100" value="0" class="slider" id="weightRange"/></div>
                                    <div id="uppbound">To: <span id="uppboundval"></span></div>
                                <div id="weightRangeValDiv"><span id="weightRangeVal">0</span></div>
                            </div>
                        </div>
                        <div id="cyto"/>
                    </div>
                </div>
                <script src="isidore.js" type="text/javascript"/>
                <script src="isidorenetwork.js" type="text/javascript"/>
                <div id="modal-01" class="w3-modal">
                    <div class="w3-modal-content">
                        <div class="w3-container">
                            <span onclick="document.getElementById('modal-01').style.display='none'"
                                class="w3-button w3-display-topright w3-red">Close</span>
                            <div id="modalcontent"></div>
                        </div>
                    </div>
                </div>
                <div id="modal-02" class="w3-modal">
                    <div class="w3-modal-content">
                        <div class="w3-container">
                            <span onclick="document.getElementById('modal-02').style.display='none'"
                                class="w3-button w3-display-topright w3-red">Close</span>
                            <div id="allmsslist">
                                <h4>All manuscripts</h4>
                                <p>
                                    <input type="checkbox" id="allmss3" name="allmss3" value="allmss3" checked="checked" onclick="checkallmss3()"/><label for="allmss3">  Manuscripts </label>
                                </p>
                                <xsl:for-each select="//tei:msDesc[not(@xml:id='dummy')]">
                                    <input type="checkbox" class="msscheck" id="{concat('chk',hi:nodeid(.))}" name="{hi:nodeid(.)}" value="{hi:nodeid(.)}" checked="checked">
                                        <xsl:attribute name="onclick">
                                            <xsl:text>addremovems('</xsl:text>
                                            <xsl:value-of select="hi:nodeid(.)"/>
                                            <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                    </input>
                                    <label for="{hi:nodeid(.)}"> 
                                        <a href="{concat('../#detail/',.//tei:altIdentifier/tei:idno/text())}" target="msdb">
                                            <xsl:value-of select="hi:nodeid(.)"/>
                                        </a> 
                                    </label>
                                    <br/>
                                </xsl:for-each>
                            </div>
                            <div id="otherfilters">
                                <div id="regionfilter">
                                    <h4>Manuscript regions</h4>
                                    <xsl:for-each select="//tei:interpGrp[@type='regions']/tei:interp">
                                        <xsl:value-of select="text()"/>
                                        <xsl:text> </xsl:text>
                                        <input type="checkbox" id="{concat('chk-',@xml:id)}" name="{concat('chk-',@xml:id)}" value="{concat('chk-',@xml:id)}" checked="checked">
                                            <xsl:attribute name="onclick">
                                                <xsl:text>checkmsgroup('msregion','</xsl:text>
                                                <xsl:value-of select="@xml:id"/>
                                                <xsl:text>');</xsl:text>
                                            </xsl:attribute>
                                        </input>
                                        <xsl:if test="position() &lt; last()">
                                            <br/>
                                        </xsl:if>
                                    </xsl:for-each>
                                </div>
                                <div id="typefilter">
                                    <h4>Manuscript types</h4>
                                    <xsl:for-each select="//tei:interpGrp[@xml:id='type']/tei:interp">
                                        <xsl:value-of select="text()"/>
                                        <xsl:text> </xsl:text>
                                        <input type="checkbox" id="{concat('chk-',@xml:id)}" name="{concat('chk-',@xml:id)}" value="{concat('chk-',@xml:id)}" checked="checked">
                                            <xsl:attribute name="onclick">
                                                <xsl:text>checkmsgroup('mstype','</xsl:text>
                                                <xsl:value-of select="@xml:id"/>
                                                <xsl:text>');</xsl:text>
                                            </xsl:attribute>
                                        </input>
                                        <xsl:if test="position() &lt; last()">
                                            <br/>
                                        </xsl:if>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="modal-03" class="w3-modal">
                    <div class="w3-modal-content">
                        <div class="w3-container" style="padding-right:0px">
                            <span onclick="document.getElementById('modal-03').style.display='none'"
                                class="w3-button w3-display-topright w3-red">Close</span>
                            <div id="allclustlist">
                                <h4>All clusters</h4>
                                <p>
                                    <input type="checkbox" id="allclust3" name="allclust3" value="allclust3" onclick="checkallclust3()" checked="checked"/><label for="allclust3"> Clusters </label>
                                </p>
                                <xsl:for-each select="//tei:interpGrp[@type='clusters']/tei:interp">
                                    <input type="checkbox" class="clustcheck" id="{concat('clust',hi:nodeid(.))}" name="{hi:nodeid(.)}" value="{hi:nodeid(.)}" checked="checked">
                                        <xsl:attribute name="onclick">
                                            <xsl:text>addremoveclust('</xsl:text>
                                            <xsl:value-of select="hi:nodeid(.)"/>
                                            <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                    </input>
                                    <label for="{hi:nodeid(.)}">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@xml:id"/>
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="text()"/> </label>
                                    <br/>
                                </xsl:for-each>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="modal-04" class="isi-modal">
                    <div class="isi-modal-content">
                            <span onclick="document.getElementById('modal-04').style.display='none'"
                                class="w3-button w3-display-topright w3-red">Close</span>
                        <div class="w3-container" id="static-controls">
                            <table class="graphcontrols">
                                <tr>
                                    <td>Active manuscripts:</td>
                                    <td><span id="actman"></span></td>
                                    <td><span onclick="document.getElementById('modal-02').style.display='block'"
                                        class="w3-button w3-black">Filter</span></td>
                                </tr>
                                <tr id="actclustcontrol">
                                    <td>Active clusters:</td>
                                    <td><span id="actclust"></span></td>
                                    <td><span onclick="document.getElementById('modal-03').style.display='block'"
                                        class="w3-button w3-black">Filter</span></td>
                                </tr>
                                <tr id="actweightcontrol">
                                    <td colspan="1">Nontriviality rankings to include:</td>
                                    <td>
                                        <input type="checkbox" class="weightcheck" id="w1" name="w1" value="w1" checked="checked"><label for="w1"> 1 </label></input>
                                        <input type="checkbox" class="weightcheck" id="w2" name="w2" value="w2" checked="checked"><label for="w2"> 2 </label></input>
                                        <input type="checkbox" class="weightcheck" id="w3" name="w3" value="w3" checked="checked"><label for="w3"> 3 </label></input>
                                        <input type="checkbox" class="weightcheck" id="w4" name="w4" value="w4" checked="checked"><label for="w4"> 4 </label></input>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td colspan="3" >
                                        <form id="layoutbuttons">
                                            <p>Layout algorithm:
                                                <input type="radio" name="layout" value="breadthfirst"
                                                    id="breadthfirst"> Breadthfirst </input>
                                                <input type="radio" name="layout" value="grid" id="grid"> Grid </input>
                                                <input type="radio" name="layout" value="circle" id="circle"> Circle </input>
                                                <input type="radio" name="layout" value="concentric" id="concentric"> Concentric </input>
                                                <input type="radio" name="layout" value="cose" id="cose"> Cose </input>
                                                <input type="radio" name="layout" value="fcose" id="fcose"> Fcose </input>
                                                <input type="radio" name="layout" value="random" id="random"> Random </input>
                                            </p>
                                       </form>
                                    </td>
                                </tr>
                                <tr>
                                    <td><button class="w3-button w3-black" onclick="savegraph('png')">Save png</button></td>
                                    <td><button title="Compute graph using pre-set parameters" class="w3-button w3-black" onclick="creategraph(globalThis.networktype,true,false)">Curated display</button></td>
                                    <td><button title="Compute graph using parameters set above" class="w3-button w3-black" onclick="creategraph(globalThis.networktype,false,false)">Compute graph</button></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </body>
        </html>
        <xsl:for-each select="//tei:div[@type='chapter']">
            <xsl:apply-templates select="." mode="text"/>
            <xsl:apply-templates select="." mode="gloss"/>
        </xsl:for-each>
        <xsl:apply-templates select="//tei:msDesc" mode="msgloss"/>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="copy" priority="2">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:if test="@source">
                <xsl:for-each select="tokenize(@source)">
                    <hi:source target="{.}"></hi:source>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'chapter']" mode="gloss">
        <xsl:result-document href="{concat('htmlfrag/gloss',concat(hi:nodeid(.),'.html'))}" omit-xml-declaration="yes">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <a id="{concat('gloss',@n)}"/>
            <h3>
                <xsl:text>Glosses to chapter </xsl:text>
                <xsl:value-of select="@n"/>
            </h3>
            <xsl:variable name="links">
                filtered using the 
                <span class="hyperlink" onclick="document.getElementById('modal-02').style.display = 'block';">manuscript</span>
                <!--and/or the 
                <span class="hyperlink" onclick="document.getElementById('modal-03').style.display = 'block';">cluster</span>-->
                filter.
            </xsl:variable>
            <p id="filterwarning">This display has been <xsl:copy-of select="$links"/></p>
            <p id="nofilterwarning">This display can be <xsl:copy-of select="$links"/></p>
            <p>
                <input type="checkbox" id="unclustonoffc" name="unclustonoffc" value="unclustonoffc" onclick="funclustonoff('c')"/>
                <label for="unclustonoff"> Turn off display of isolated glosses?</label>
            </p>
                <xsl:apply-templates select=".//tei:seg" mode="gloss">
                    <xsl:with-param name="mode" select="'chapmode'" tunnel="yes"/>
                </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tei:gloss" mode="gloss">
        <xsl:param name="mode" tunnel="yes"/>
        <xsl:param name="msid" tunnel="yes"/>
        <xsl:if test="$mode='chapmode' or $msid=hi:removehash(@corresp)">
            <div id="{hi:nodeid(.)}">
                <xsl:attribute name="class">
                    <xsl:text>gloss </xsl:text>
                    <xsl:value-of select="hi:removehash(@corresp)"/>
                </xsl:attribute>
                <xsl:variable name="ms" select="id(hi:removehash(@corresp))"/>
                <table width="100%">
                    <tr>
                        <td class="glossmslink">
                            <xsl:choose>
                                <xsl:when test="$mode='chapmode'">
                                    <xsl:call-template name="mslink">
                                        <xsl:with-param name="ms" select="$ms"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="invisible">-</span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="glosstext">
                            <xsl:apply-templates/>
                            <xsl:if test="@xml:lang">
                                <span>
                                    <xsl:attribute name="title">
                                        <xsl:text>Language: </xsl:text>
                                        <xsl:apply-templates select="key('language',@xml:lang)"/>
                                    </xsl:attribute>
                                    <img class="stylus" src="pics/language.svg" width="15px" heighth="15px"/></span>
                            </xsl:if>
                        </td>
                        <td class="glossnote">
                            <xsl:if test="tei:note">
                                <xsl:apply-templates select="tei:note/node()"/>
                            </xsl:if>
                            <span class="invisible">-</span>
                        </td>
                    </tr>
                </table>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="hi:glossGrp" mode="gloss">
        <xsl:param name="mode" tunnel="yes"/>
        <xsl:param name="msid" tunnel="yes"/>
        <xsl:apply-templates select="hi:glossCluster" mode="gloss"/>
        <xsl:if test="($mode = 'chapmode' and tei:gloss[not(key('ptr',@xml:id))])
            or ($mode = 'msmode' and tei:gloss[not(key('ptr',@xml:id)) and @corresp = hi:addhash($msid)])">
            <div class="simgroup unclustered w3-container">
                <div class="simgrouphead">
                    <xsl:text>Isolated glosses </xsl:text>
                </div>
                <div class="simgroupbody"><xsl:apply-templates select="tei:gloss[not(key('ptr',@xml:id))]" mode="gloss"/></div>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="hi:glossCluster" mode="gloss">
        <xsl:param name="mode" tunnel="yes"/>
        <xsl:param name="msid" tunnel="yes"/>
        <xsl:variable name="glosses">
            <glosses>
                <xsl:for-each select="tei:ptr">
                    <xsl:copy-of select="key('gloss',hi:removehash(@target))"/>
                </xsl:for-each>
            </glosses>
        </xsl:variable>
        <xsl:if test="$mode = 'chapmode' or $glosses//tei:gloss[@corresp = hi:addhash($msid)]">
            <div class="simgroup w3-container" id="{hi:nodeid(.)}">
                <div class="simgrouphead">
                    <xsl:text>Cluster </xsl:text>
                    <xsl:variable name="cl-id" select="hi:removehash(@ana)"/>
                    <xsl:variable name="cl-col" select="substring-after(key('interp',$cl-id)/@rend,'color:')"/>
                    <span class="circledletter w3-round-large" title="{key('interp',$cl-id)/text()}">
                        <xsl:attribute name="style">
                            <xsl:text>color:</xsl:text>
                            <xsl:value-of select="$cl-col"/>
                            <xsl:text>; border: solid </xsl:text>
                            <xsl:value-of select="$cl-col"/>
                            <xsl:text> 1px</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$cl-id"/>
                    </span>
                    <xsl:if test="@weight">
                        <xsl:if test="$mode='chapmode'">
                            <br/>
                        </xsl:if>
                        <span title="weight">
                            <xsl:text> w=</xsl:text>
                            <xsl:value-of select="@weight"/>
                        </span>
                    </xsl:if>
                </div>
                <div class="simgroupbody">
                    <xsl:for-each select="tei:ptr">
                        <xsl:apply-templates select="key('gloss',hi:removehash(@target))" mode="gloss"/> 
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:seg[@xml:id]" mode="gloss">
        <xsl:param name="mode" tunnel="yes"/>
        <xsl:param name="msid" tunnel="yes"/>
        <xsl:if test="$mode = 'chapmode' or key('glossGrp',@xml:id)//tei:gloss[@corresp=hi:addhash($msid)]">
            <div id="{hi:nodeid(key('glossGrp',@xml:id))}" class="lemmadiv w3-container">
                <table width="100%">
                    <tr>
                        <td class="lemmaid">id: <xsl:value-of select="@xml:id"/></td>
                        <td class="temmatext"><span class="lemma"><xsl:apply-templates/></span></td>
                    </tr>
                </table>
                <xsl:apply-templates select="key('glossGrp',@xml:id)" mode="gloss"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'chapter']" mode="msgloss">
        <h4>
            <xsl:text>Glosses to </xsl:text>
            <span class="hyperlink">
                <xsl:attribute name="onclick">
                    <xsl:text>openlefttab('</xsl:text>
                    <xsl:value-of select="@n"/>
                    <xsl:text>','',true)</xsl:text>
                </xsl:attribute>
                <xsl:text>chapter </xsl:text>
                <xsl:value-of select="@n"/>
            </span>
        </h4>
        <xsl:apply-templates select=".//tei:seg" mode="gloss">
            <xsl:with-param name="mode" select="'msmode'" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="tei:msDesc" mode="msgloss">
        <xsl:result-document href="{concat('htmlfrag/glossms',concat(hi:nodeid(.),'.html'))}" omit-xml-declaration="yes">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <h3>
                <xsl:text>All glosses in manuscript </xsl:text>
                <a href="{concat('../#detail/',.//tei:altIdentifier/tei:idno/text())}" target="msdb"><xsl:value-of select="hi:msname(.)"/></a> 
            </h3>
            <p>
                <input type="checkbox" id="unclustonoffm" name="unclustonoffm" value="unclustonoffm" onclick="funclustonoff('m')"/>
                <label for="unclustonoff"> Turn off display of isolated glosses?</label>
            </p>
            <xsl:apply-templates select="//tei:div[@type='chapter']" mode="msgloss">
                <xsl:with-param name="msid" select="@xml:id" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tei:bibl" mode="source">
        <a id="{hi:nodeid(.)}"/>
        <xsl:if test="key('source',hi:addhash(@xml:id))">
            <p>
                <xsl:apply-templates mode="source"/>
                <xsl:text> (occurs: </xsl:text>
                <xsl:for-each select="key('source',hi:addhash(@xml:id))">
                    <xsl:value-of select="hi:removehash(ancestor::hi:glossGrp/@target)"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>)</xsl:text>
            </p>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:ab" mode="text">
        <p id="{hi:nodeid(.)}" class="ab">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>] </xsl:text>
            <xsl:apply-templates mode="text"/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:app" mode="text">
        <xsl:if test=".//tei:lg"><br/></xsl:if>
        <span title="apparatus entry" class="app">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates select="tei:lem" mode="text"/>
            <xsl:for-each select="tei:rdg">
                <xsl:if test="not(position() = 1) or preceding-sibling::tei:lem">
                    <xsl:text>//</xsl:text>
                </xsl:if>
                <xsl:apply-templates select="." mode="text"/>
            </xsl:for-each>
            <xsl:text>]</xsl:text>
        </span>
        <xsl:if test=".//tei:lg"><br/></xsl:if>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'chapter']" mode="text">
        <xsl:result-document href="{concat('htmlfrag/text',concat(hi:nodeid(.),'.html'))}" omit-xml-declaration="yes">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <h2>Etymologiae, book I</h2>
            <p>
                <xsl:if test="preceding-sibling::tei:div">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>#left-</xsl:text>
                            <xsl:value-of select="preceding-sibling::tei:div[1]/@n"/>
                        </xsl:attribute>
                        <xsl:attribute name="onclick">
                            <xsl:text>openlefttab('</xsl:text>
                            <xsl:value-of select="preceding-sibling::tei:div[1]/@n"/>
                            <xsl:text>','',true)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Previous chapter </xsl:text>
                            <xsl:apply-templates select="preceding-sibling::tei:div[1]//tei:head" mode="plaintext"/>
                        </xsl:attribute>
                        <xsl:text>&#x2190;</xsl:text>
                    </a>
                </xsl:if>
                <xsl:if test="preceding-sibling::tei:div and following-sibling::tei:div">
                    <xsl:text> - </xsl:text>
                </xsl:if>
                <xsl:if test="following-sibling::tei:div">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>#left-</xsl:text>
                            <xsl:value-of select="following-sibling::tei:div[1]/@n"/>
                        </xsl:attribute>
                        <xsl:attribute name="onclick">
                            <xsl:text>openlefttab('</xsl:text>
                            <xsl:value-of select="following-sibling::tei:div[1]/@n"/>
                            <xsl:text>','',true)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Next chapter </xsl:text>
                            <xsl:apply-templates select="following-sibling::tei:div[1]//tei:head" mode="plaintext"/>
                        </xsl:attribute>
                        <xsl:text>&#x2192;</xsl:text>
                    </a>
                </xsl:if>
            </p>
            <div id="{hi:nodeid(.)}" class="div">
                <xsl:apply-templates mode="text"/>
            </div>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tei:head[count(ancestor::tei:div) = 1]" mode="text">
        <h3>
            <xsl:apply-templates mode="text"/>
        </h3>
    </xsl:template>

    <xsl:template match="tei:head[count(ancestor::tei:div) > 1]" mode="text">
        <h4>
            <xsl:value-of select="parent::tei:div/@n"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates mode="text"/>
        </h4>
    </xsl:template>

    <xsl:template match="tei:l" mode="text">
        <xsl:if test="preceding-sibling::tei:l or not(ancestor::tei:app)"><br/></xsl:if>
        <span class="l">
            <xsl:apply-templates mode="text"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:lb" mode="text">
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:lem" mode="text">
        <span class="lem">
            <xsl:attribute name="title">
                <xsl:text>Lemma</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates mode="text"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:lg" mode="text">
        <span class="lg">
            <xsl:apply-templates mode="text"/>
        </span>
        <xsl:if test="not(ancestor::tei:app)"><br/></xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:rdg" mode="text">
        <span class="rdg">
            <xsl:attribute name="title">
                <xsl:text>Reading</xsl:text>
                <xsl:if test="@wit">
                    <xsl:text> attested in witness(es): </xsl:text>
                    <xsl:value-of select="@wit"/>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates mode="text"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:seg[@rend='cardo']" mode="text">
        <span class="cardo">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[@type='lemma']" mode="text">
        <span id="{hi:nodeid(.)}" class="lemma">
            <xsl:for-each select="key('glossGrp', @xml:id)/hi:glossCluster">
                <xsl:variable name="cl-id" select="hi:removehash(@ana)"/>
                <xsl:variable name="cl-col" select="substring-after(key('interp',$cl-id)/@rend,'color:')"/>
                <span class="circledlettersuper w3-round" title="{key('interp',$cl-id)/text()}">
                    <xsl:attribute name="style">
                        <xsl:text>color:</xsl:text>
                        <xsl:value-of select="$cl-col"/>
                        <xsl:text>; border: solid </xsl:text>
                        <xsl:value-of select="$cl-col"/>
                        <xsl:text> 1px</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$cl-id"/>
                </span>
            </xsl:for-each>
            <xsl:apply-templates mode="text"/>
            <xsl:if test="key('glossGrp', @xml:id)">
                <span class="suplink">
                    <a href="{concat('#',hi:nodeid(key('glossGrp',@xml:id)))}">
                        <xsl:attribute name="onclick">
                            <xsl:text>globalThis.useraction = true; gotolemma('</xsl:text>
                            <xsl:value-of select="ancestor::tei:div[@type='chapter']/@n"/>
                            <xsl:text>',true);</xsl:text>
                        </xsl:attribute>g</a>
                </span>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="tei:cell" mode="#all">
        <td>
            <xsl:apply-templates mode="#current"/>
        </td>
    </xsl:template>
    
    <xsl:template match="tei:choice" mode="#all">
        <xsl:choose>
            <xsl:when test="not(tei:sic) or not(tei:corr)">
                <xsl:message>Don't know how to handle this choice: <xsl:apply-templates/></xsl:message>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <span class="corr">
                    <xsl:attribute name="title">
                        <xsl:text>Originally: </xsl:text>
                        <xsl:apply-templates select="tei:sic/node()" mode="#current"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="tei:corr" mode="#current"/>
                    <img class="stylus" src="pics/stylus.jpg" width="15px" heighth="15px"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:del" mode="#all">
        <span class="del">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:figure" mode="#all">
        <img src="{@source}" style="{@style}">
            <xsl:attribute name="alt">
                <xsl:apply-templates select="tei:figDesc"/>
            </xsl:attribute>
        </img>
    </xsl:template>
    
    <xsl:template match="tei:gap" mode="#all">
        <span class="gap">[...]</span>
    </xsl:template>
    
    <xsl:template match="tei:head[ancestor::tei:front]" mode="#all">
        <h3>
            <xsl:apply-templates mode="#current"/>
        </h3>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend='bold']" mode="#all">
        <span class="bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:item" mode="#all">
        <li>
            <xsl:apply-templates mode="#current"/>
        </li>
    </xsl:template>
    
    <xsl:template match="tei:list" mode="#all">
        <ul>
            <xsl:apply-templates mode="#current"/>
        </ul>
    </xsl:template>
    
    <xsl:template match="tei:mentioned" mode="#all">
        <span class="mentioned">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:name" mode="#all">
        <xsl:choose>
            <xsl:when test="@ref">
                <a href="{@ref}">
                    <xsl:apply-templates mode="#current"/>
                    <xsl:text> </xsl:text>
                    <xsl:if test="starts-with(@ref,'https://orcid.org/')">
                        <img src="pics/orcid-logo.png"/>
                    </xsl:if>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:note"/>
    
    <xsl:template match="tei:p" mode="#all">
        <p>
            <xsl:if test="@rend">
                <xsl:attribute name="class" select="@rend"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:quote" mode="#all">
        <span class="quote" title="{key('bibl',hi:removehash(@source))/text()}">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:ref" mode="#all">
        <xsl:choose>
            <xsl:when test="hi:removehash(@target)=$mslist">
                <xsl:call-template name="mslink">
                    <xsl:with-param name="ms" select="id(hi:removehash(@target))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@action">
                <a href="{@target}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{@target}" onclick="{@action}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:row" mode="#all">
        <tr>
            <xsl:apply-templates mode="#current"/>
        </tr>
    </xsl:template>
    
    <xsl:template match="tei:seg[@type='writing' and @hand='#drypoint']" mode="#all">
        <span class="drypoint" title="dry-point">
            <xsl:apply-templates mode="#current"/>
            <img class="stylus" src="pics/stylus.jpg" width="15px" heighth="15px"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:seg[@type='writing' and @hand='#tirnote']" mode="#all">
        <span class="tironiannotes" title="Tironian notes">
            <xsl:apply-templates mode="#current"/>
            <img class="stylus" src="pics/stylus.jpg" width="15px" heighth="15px"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:sic" mode="#all">
        <span class="sic" title="sic">
            <xsl:apply-templates mode="#current"/>
            <img class="stylus" src="pics/stylus.jpg" width="15px" heighth="15px"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:subst" mode="#all">
        <span class="subst">
            <xsl:attribute name="title">
                <xsl:text>ante correctionem: </xsl:text>
                <xsl:apply-templates select="tei:del/node()" mode="plaintext"/>
            </xsl:attribute>
            <xsl:apply-templates select="tei:add" mode="#current"/>
            <img class="stylus" src="pics/stylus.jpg" width="15px" heighth="15px"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:supplied" mode="#all">
        <xsl:text>&lt;</xsl:text>
        <span class="supplied" title="supplied">
            <xsl:apply-templates mode="#current"/>
        </span>
        <xsl:text>></xsl:text>
    </xsl:template>

    <xsl:template match="tei:table" mode="#all">
        <table>
            <xsl:apply-templates mode="#current"/>
        </table>
    </xsl:template>
    
    <xsl:template match="tei:title" mode="#all">
        <span class="title">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:unclear" mode="#all">
        <xsl:text>[</xsl:text>
        <span class="unclear" title="unclear">
            <xsl:apply-templates mode="#current"/>
        </span>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template name="mslink">
        <xsl:param name="ms"/>
        <span class="hyperlink">
            <xsl:attribute name="onclick">
                <xsl:text>openmsglosshash('</xsl:text>
                <xsl:value-of select="$ms/@xml:id"/>
                <xsl:text>');</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="$ms/@xml:id"/>
        </span>
        <span class="suplink">
            <a href="{concat('../#detail/',$ms/tei:msIdentifier/tei:altIdentifier/tei:idno/text())}" target="msdb" title="Link to this ms in innovating knowledge mss database">
                <xsl:text>db</xsl:text>
            </a>
        </span>
    </xsl:template>
    
    <xsl:template name="msdesc">
        <h4>Summary manuscript descriptions</h4>
        <table>
            <tr>
                <td>Id</td>
                <td>Name</td>
                <td>Origin</td>
                <td>Glossing</td>
                <td>Contents</td>
            </tr>
            <xsl:for-each select="//tei:msDesc">
                <tr id="{concat('msdesc-',@xml:id)}">
                    <td><xsl:call-template name="mslink">
                            <xsl:with-param name="ms" select="."/>
                        </xsl:call-template>
                    </td>
                    <td><xsl:value-of select="hi:msname(.)"/></td>
                    <td>
                        <xsl:if test=".//tei:origin/tei:origPlace">
                            <xsl:apply-templates select=".//tei:origin/tei:origPlace/tei:origDate"/>
                            <xsl:text>, </xsl:text>
                            <xsl:apply-templates select=".//tei:origin/tei:origPlace/*[local-name() = ('country', 'region', 'settlement')][position() = last()]"/>
                        </xsl:if>
                    </td>
                    <td>
                        <xsl:if test=".//tei:history//tei:event[tei:desc[text() = 'glossing']]">
                            <xsl:apply-templates select=".//tei:history/*[.//tei:event[tei:desc[text() = 'glossing']]]//tei:origPlace/tei:origDate"/>
                            <xsl:text>, </xsl:text>
                            <xsl:apply-templates select=".//tei:history/*[.//tei:event[tei:desc[text() = 'glossing']]]//tei:origPlace/*[local-name() = ('country', 'region', 'settlement')][position() = last()]"/>
                        </xsl:if>
                    </td>
                    <td>
                        <xsl:apply-templates select=".//tei:msContents"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    
    <xsl:template name="msstats">
        <h4>Summary manuscript statistics</h4>
        <table>
            <tr>
                <td>Id</td>
                <td>Name</td>
                <td style="text-align:right">No. of glosses</td>
                <td style="text-align:right">Shared glosses</td>
                <td style="text-align:right">Weight</td>
                <td style="text-align:right">Average weight</td>
            </tr>
            <xsl:for-each select="//tei:msDesc">
                <xsl:variable name="count">
                    <xsl:value-of select="count(key('closscorresp',@xml:id))"/>
                </xsl:variable>
                <xsl:variable name="weight">
                    <xsl:value-of select="sum(key('closscorresp',@xml:id)/hi:glossweight(.))"/>
                </xsl:variable>
                <xsl:variable name="shared">
                    <xsl:value-of select="count(key('closscorresp',@xml:id)[key('ptr',./@xml:id)])"/>
                </xsl:variable>
                <tr id="{concat('msstats-',@xml:id)}">
                    <td>
                        <xsl:call-template name="mslink">
                            <xsl:with-param name="ms" select="."/>
                        </xsl:call-template>
                    </td>
                    <td><xsl:value-of select="hi:msname(.)"/></td>
                    <td style="text-align:right">
                        <xsl:value-of select="$count"/>
                    </td>
                    <td style="text-align:right">
                        <xsl:value-of select="$shared"/>
                    </td>
                    <td style="text-align:right">
                        <xsl:if test="$shared > 0">
                            <xsl:value-of select="$weight"/>
                        </xsl:if>
                    </td>
                    <td style="text-align:right">
                        <xsl:if test="$shared> 0">
                            <xsl:value-of select="format-number($weight div $shared,'0.00')"/>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    
</xsl:stylesheet>
