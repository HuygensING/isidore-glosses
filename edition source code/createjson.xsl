<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei hi fn" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:hi="http://xmlschema.huygens.knaw.nl/ns/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    
    <xsl:import href="shared.xsl"/>

    <xsl:key name="glossClusterorr" match="tei:gloss" use="hi:removehash(@corresp)"/>
    <xsl:key name="gloss" match="tei:gloss" use="@xml:id"/>
    <xsl:key name="ptr" match="tei:ptr" use="hi:removehash(@target)"/>
    <xsl:key name="linkGrp" match="hi:glossCluster" use="hi:removehash(@ana)"/>
    <xsl:key name="interp" match="tei:interp" use="@xml:id"/>
    <xsl:key name="seg" match="tei:seg" use="@xml:id"/>
    <xsl:key name="div" match="tei:div" use="@n"/>
    <xsl:key name="mstype" match="tei:msDesc" use="@type"/>
    <xsl:key name="msregion" match="tei:msDesc" use="hi:removehash(@ana)"/>
    
    <xsl:template match="/">
        <xsl:call-template name="msslist"/>
        <xsl:call-template name="mssgroups"/>
        <xsl:call-template name="clustlistmap"/>
    </xsl:template>
    
    <xsl:variable name="comment">
        <xsl:call-template name="createcomment"/>
    </xsl:variable>
    
    <xsl:template name="mssgroups">
        <xsl:variable name="mssgroups">
            <map>
                <pair name="mstype">
                    <map>
                        <pair name="string">
                            <string>Manuscript types</string>
                        </pair>
                        <pair name="values">
                            <map>
                                <xsl:for-each select="//tei:interpGrp[@xml:id = 'type']/tei:interp">
                                    <xsl:text>
</xsl:text>
                                    <pair name="{@xml:id}">
                                        <map>
                                            <pair name="string">
                                                <string><xsl:apply-templates/></string>
                                            </pair>
                                            <pair name="manuscripts">
                                                <array>
                                                    <xsl:for-each select="key('mstype', @xml:id)">
                                                        <string>
                                                            <xsl:value-of select="@xml:id"/>
                                                        </string>
                                                    </xsl:for-each>
                                                </array>
                                            </pair>
                                        </map>
                                    </pair>
                                </xsl:for-each>
                            </map>
                        </pair>
                    </map>
                </pair>
                <xsl:text>
</xsl:text>
                <pair name="msregion">
                    <map>
                        <pair name="string">
                            <string>Manuscript regions</string>
                        </pair>
                        <pair name="values">
                            <map>
                                <xsl:for-each select="//tei:interpGrp[@xml:id = 'regions']/tei:interp">
                                    <xsl:text>
</xsl:text>
                                    <pair name="{@xml:id}">
                                        <map>
                                            <pair name="name">
                                                <string><xsl:value-of select="@xml:id"/></string>
                                            </pair>
                                            <pair name="string">
                                                <string><xsl:apply-templates/></string>
                                            </pair>
                                            <pair name="manuscripts">
                                                <array>
                                                    <xsl:for-each select="key('msregion', @xml:id)">
                                                        <string>
                                                            <xsl:value-of select="@xml:id"/>
                                                        </string>
                                                    </xsl:for-each>
                                                </array>
                                            </pair>
                                        </map>
                                    </pair>
                                </xsl:for-each>
                            </map>
                        </pair>
                    </map>
                </pair>
            </map>
        </xsl:variable>
        <xsl:result-document href="mssgroups.js" omit-xml-declaration="yes" method="text">
            <xsl:call-template name="jscomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="conv2json">
                <xsl:with-param name="varname">mssgroups</xsl:with-param>
                <xsl:with-param name="struct" select="$mssgroups"></xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="msslist">
        <xsl:variable name="msslist">
            <array>
                <xsl:for-each select="//tei:msDesc[not(@xml:id='dummy')]">
                    <string>
                        <xsl:value-of select="hi:nodeid(.)"/>
                    </string>
                </xsl:for-each>
            </array>
        </xsl:variable>
        <xsl:result-document href="even.txt" omit-xml-declaration="yes" method="xml">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:copy-of select="$msslist"/>
        </xsl:result-document>
        <xsl:result-document href="msslist.js" omit-xml-declaration="yes" method="text">
            <xsl:call-template name="jscomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="conv2json">
                <xsl:with-param name="varname">msslist</xsl:with-param>
                <xsl:with-param name="struct" select="$msslist"></xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="clustlistmap">
        <xsl:variable name="clustlist">
            <array>
                <xsl:for-each select="//tei:interpGrp[@type='clusters']/tei:interp">
                    <string>
                        <xsl:value-of select="hi:nodeid(.)"/>
                    </string>
                </xsl:for-each>
            </array>
        </xsl:variable>
        <xsl:variable name="clustmap">
            <map>
                <xsl:for-each-group select="//tei:ptr" group-by="hi:removehash(parent::hi:glossCluster/@ana)">
                    <pair name="{current-grouping-key()}">
                        <xsl:variable name="mss">
                            <xsl:for-each select="current-group()">
                                <el><xsl:value-of select="hi:removehash(key('gloss',hi:removehash(@target))/@corresp)"/></el>
                            </xsl:for-each>
                        </xsl:variable>
                        <array>
                            <xsl:for-each select="distinct-values($mss//el/text())">
                                <string><xsl:value-of select="."/></string>
                            </xsl:for-each>
                        </array>
                    </pair>
                </xsl:for-each-group>
            </map>
        </xsl:variable>
<!--        <xsl:result-document href="even1.txt" omit-xml-declaration="yes" method="xml">
            <xsl:copy-of select="$clustmap"/>
        </xsl:result-document>
        <xsl:result-document href="even2.txt" omit-xml-declaration="yes" method="xml">
            <xsl:copy-of select="$clustlist"/>
        </xsl:result-document>-->
        <xsl:result-document href="clustlistmap.js" omit-xml-declaration="yes" method="text">
            <xsl:call-template name="jscomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="conv2json">
                <xsl:with-param name="varname">clustlist</xsl:with-param>
                <xsl:with-param name="struct" select="$clustlist"></xsl:with-param>
            </xsl:call-template>
            <xsl:text>
</xsl:text>
            <xsl:call-template name="conv2json">
                <xsl:with-param name="varname">clustmap</xsl:with-param>
                <xsl:with-param name="struct" select="$clustmap"></xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="array">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="node()">
            <xsl:apply-templates select="."/>
            <xsl:if test="position() &lt; last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="map">
        <xsl:text>{</xsl:text>
        <xsl:for-each select="pair">
            <xsl:apply-templates select="."/>
            <xsl:if test="position() &lt; last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="pair">
        <xsl:text>'</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>' :</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="string">
        <xsl:text>'</xsl:text>
        <xsl:value-of select="text()"/>
        <xsl:text>'</xsl:text>
    </xsl:template>
    
    <xsl:template name="conv2json">
        <xsl:param name="varname"/>
        <xsl:param name="struct"/>
        <xsl:text>var </xsl:text>
        <xsl:value-of select="$varname"/>
        <xsl:text> = </xsl:text>
        <xsl:apply-templates select="$struct/node()"/>
        <xsl:text>;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
