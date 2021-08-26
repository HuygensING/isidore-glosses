<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei hi fn" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:hi="http://xmlschema.huygens.knaw.nl/ns/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    
    <xsl:import href="shared.xsl"/>

    <xsl:key name="closscorresp" match="tei:gloss[not(@type = 'glossongloss')]" use="hi:removehash(@corresp)"/>
    <xsl:key name="ptr" match="tei:ptr" use="hi:removehash(@target)"/>
    <xsl:key name="glossCluster" match="hi:glossCluster" use="hi:removehash(@ana)"/>
    <xsl:key name="interp" match="tei:interp" use="@xml:id"/>
    <xsl:key name="seg" match="tei:seg" use="@xml:id"/>
    <xsl:key name="div" match="tei:div" use="@n"/>
    
    <xsl:output method="text" omit-xml-declaration="yes"/>

    <xsl:variable name="latlongspans" as="xs:decimal *">
        <xsl:call-template name="latlongspans"/>
    </xsl:variable>

    <xsl:variable name="comment">
        <xsl:call-template name="createcomment"/>
    </xsl:variable>

    <xsl:variable name="preprocess">
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="copy"/>
        </xsl:copy>
    </xsl:variable>

    <xsl:template match="/">
        <!--<xsl:call-template name="network_div_ab"/>
        <xsl:call-template name="network_ms_gl_sim_clus"/>-->
        <xsl:call-template name="network_ms_clus"/>
        <xsl:call-template name="network_ms"/>
        <xsl:call-template name="network_ms_div"/>
    </xsl:template>
    
    <xsl:template name="network_ms">
        <xsl:variable name="prejson1">
            <xsl:call-template name="network_ms_clus_step1"/>
        </xsl:variable>
<!--        <xsl:result-document href="out0.xml" omit-xml-declaration="no" method="xml">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:copy-of select="$prejson1"/>
        </xsl:result-document>-->
        <xsl:variable name="prejson2">
            <xsl:for-each-group select="$prejson1//data[@type='ms_clus']" group-by="@target">
                <xsl:variable name="clus" select="current-grouping-key()"/>
                <xsl:variable name="cluscolor" select="current-group()[1]/@color"/>
                <xsl:variable name="clusedges" select="current-group()"/>
                <xsl:for-each select="$clusedges">
                    <xsl:variable name="x" select="@source"/>
                    <xsl:variable name="xgc" select="@glossCluster"/>
                    <xsl:for-each select="$clusedges[(@source > $x) and (@glossCluster = $xgc)]">
                        <xsl:variable name="y" select="@source"/>
                        <data source="{$x}" target="{$y}" type="ms_ms" weight="{@weight}" clus="{$clus}" color="{$cluscolor}" glossgrp="{@glossgrp}"
                            weight1="{@weight1}" weight2="{@weight2}" weight3="{@weight3}" weight4="{@weight4}">
                            <xsl:attribute name="id">
                                <xsl:value-of select="$clus"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="$x"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="$y"/>
                            </xsl:attribute>
                        </data> 
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each-group>
        </xsl:variable>
<!--        <xsl:result-document href="out1.xml" omit-xml-declaration="no" method="xml">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:copy-of select="$prejson2"/>
        </xsl:result-document>-->
        <xsl:variable name="prejson3">
            <var name="network_ms">
                <xsl:for-each select="$prejson1//data[@type='ms']">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each-group select="$prejson2//data" group-by="@id">
                    <data id="{current-grouping-key()}" source="{current-group()[1]/@source}" 
                        target="{current-group()[1]/@target}" type="ms_ms" weight="{sum(current-group()/@weight)}" 
                        clus="{current-group()[1]/@clus}" color="{current-group()[1]/@color}" count="{count(current-group())}"
                        weight1="{sum(current-group()[@weight=1]/@weight)}" weight2="{sum(current-group()[@weight=2]/@weight)}" 
                        weight3="{sum(current-group()[@weight=3]/@weight)}" weight4="{sum(current-group()[@weight=4]/@weight)}"/>
                </xsl:for-each-group>
            </var>
        </xsl:variable>
<!--        <xsl:result-document href="out2.xml" omit-xml-declaration="no" method="xml">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:copy-of select="$prejson3"/>
        </xsl:result-document>-->
        <xsl:result-document href="network_ms.js" omit-xml-declaration="yes" method="text">
            <xsl:value-of select="hi:makejson($prejson3)"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="network_ms_div">
        <xsl:variable name="prejson1">
            <xsl:for-each select="//tei:msDesc">
                <xsl:variable name="curms" select="."/>
                <data id="{hi:nodeid(.)}" type="ms" ikid="{$curms//tei:altIdentifier/tei:idno/text()}"/>
                <xsl:for-each select="key('closscorresp',@xml:id)">
                    <xsl:variable name="curgl" select="."/>
                    <xsl:if test="count(key('seg',hi:removehash(parent::hi:glossGrp/@target))) > 0">
                        <xsl:variable name="curseg" select="key('seg',hi:removehash(parent::hi:glossGrp/@target))"/>
                        <xsl:variable name="curdiv" select="$curseg/ancestor::tei:div[1]"/>
                        <data id="{hi:edgeid($curms,$curdiv)}" source="{hi:nodeid($curms)}" target="{hi:nodeid($curdiv)}" type="ms_div">
                            <xsl:attribute name="weight">
                                <xsl:choose>
                                    <xsl:when test="key('ptr',$curgl/@xml:id)">
                                        <xsl:value-of select="key('ptr',$curgl/@xml:id)[1]/ancestor::hi:glossCluster/@weight"/>
                                    </xsl:when>
                                    <xsl:otherwise>1</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </data>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <!--<xsl:result-document href="out.xml" omit-xml-declaration="no" method="xml">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:copy-of select="$prejson1"/>
        </xsl:result-document>-->
        <xsl:variable name="prejson2">
            <var name="network_ms_div">
                <xsl:for-each select="$prejson1//data[@type='ms']">
                    <xsl:copy>
                        <xsl:for-each select="@*"><xsl:copy/></xsl:for-each>
                        <xsl:attribute name="summedweight" select="sum($prejson1//data[@type='ms_div' and @source=current()/@id]/@weight)"/>
                        <xsl:attribute name="summedweight1" select="sum($prejson1//data[@type='ms_div' and @source=current()/@id and @weight=1]/@weight)"/>
                        <xsl:attribute name="summedweight2" select="sum($prejson1//data[@type='ms_div' and @source=current()/@id and @weight=2]/@weight)"/>
                        <xsl:attribute name="summedweight3" select="sum($prejson1//data[@type='ms_div' and @source=current()/@id and @weight=3]/@weight)"/>
                        <xsl:attribute name="summedweight4" select="sum($prejson1//data[@type='ms_div' and @source=current()/@id and @weight=4]/@weight)"/>
                    </xsl:copy>
                </xsl:for-each>
                <xsl:for-each select="//tei:div[@type='chapter']">
                    <data id="{hi:nodeid(.)}" type="div" pos_num="{position()}">
                        <xsl:attribute name="head">
                            <xsl:apply-templates select=".//tei:head" mode="plaintext"/>
                        </xsl:attribute>
                    </data>
                </xsl:for-each>
                <xsl:for-each-group select="$prejson1//data[@type='ms_div']" group-by="@id">
                    <data id="{current-grouping-key()}" source="{current-group()[1]/@source}" target="{current-group()[1]/@target}" type="ms_div" weight="{sum(current-group()/@weight)}"
                        weight1="{sum(current-group()[@weight=1]/@weight)}" weight2="{sum(current-group()[@weight=2]/@weight)}" 
                        weight3="{sum(current-group()[@weight=3]/@weight)}" weight4="{sum(current-group()[@weight=4]/@weight)}"/>
                </xsl:for-each-group>
            </var>
        </xsl:variable>
        <xsl:result-document href="network_ms_div.js" omit-xml-declaration="yes" method="text">
            <xsl:value-of select="hi:makejson($prejson2)"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="network_ms_clus">
        <xsl:variable name="prejson1">
            <xsl:call-template name="network_ms_clus_step1"/>
        </xsl:variable>
<!--        <xsl:result-document href="out.xml" omit-xml-declaration="no" method="xml">
            <xsl:call-template name="htmlcomment">
                <xsl:with-param name="comment" select="$comment"></xsl:with-param>
            </xsl:call-template>
            <xsl:copy-of select="$prejson1"/>
        </xsl:result-document>
-->        <xsl:variable name="prejson2">
            <var name="network_ms_clus">
                <xsl:for-each select="$prejson1//data[@type='ms']">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each-group select="$prejson1//data[@type='clus']" group-by="@id">
                    <xsl:copy-of select="current-group()[1]"/>
                </xsl:for-each-group>
                <xsl:for-each-group select="$prejson1//data[@type='ms_clus']" group-by="@id">
                    <data id="{current-grouping-key()}" source="{current-group()[1]/@source}" target="{current-group()[1]/@target}" type="ms_clus" 
                        weight="{sum(current-group()/@weight)}" count="{count(current-group())}"
                        weight1="{sum(current-group()[@weight=1]/@weight)}" weight2="{sum(current-group()[@weight=2]/@weight)}" 
                        weight3="{sum(current-group()[@weight=3]/@weight)}" weight4="{sum(current-group()[@weight=4]/@weight)}"/>
<!--                    <xsl:if test="current-grouping-key()='Orleans296_c_F1'">
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="@glossgrp"/>
                            <xsl:message><xsl:value-of select="@glossgrp"/></xsl:message>
                        </xsl:for-each>
                    </xsl:if>-->
                </xsl:for-each-group>
            </var>
        </xsl:variable>
        <xsl:result-document href="network_ms_clus.js" omit-xml-declaration="yes" method="text">
            <xsl:value-of select="hi:makejson($prejson2)"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="network_ms_clus_step1">
        <xsl:for-each select="//tei:msDesc">
            <xsl:variable name="curms" select="."/>
            <xsl:variable name="geo" select=".//tei:history//tei:geo[preceding-sibling::tei:event[tei:desc[text() = 'glossing']] or following-sibling::tei:event[tei:desc[text() = 'glossing']]]"/>
            <data id="{hi:nodeid(.)}" type="ms" mslat="{hi:relativelat($geo,$latlongspans)}" mslong="{hi:relativelong($geo,$latlongspans)}"
                ikid="{$curms//tei:altIdentifier/tei:idno/text()}"/>
            <xsl:for-each select="key('closscorresp',@xml:id)">
                <xsl:variable name="curgl" select="."/>
                <xsl:for-each select="key('ptr',@xml:id)">
                    <xsl:variable name="cursim" select="parent::hi:glossCluster"/>
                    <xsl:variable name="curclusid" select="hi:removehash($cursim/@ana)"/>
                    <xsl:variable name="curclus" select="key('interp',$curclusid)"/>
                    <xsl:variable name="apos">&apos;</xsl:variable>
                    <data id="{hi:nodeid($curclus)}" 
                        color="{substring-after($curclus/@rend,'color:')}" desc="{translate(normalize-space($curclus/text()),$apos, '')}" type="clus"/>
                    <data id="{hi:edgeid($curms,$curclus)}" source="{hi:nodeid($curms)}" target="{hi:nodeid($curclus)}" color="{substring-after($curclus/@rend,'color:')}" 
                        type="ms_clus" gloss="{$curgl/@xml:id}" weight="{$cursim/@weight}" glossCluster="{generate-id($cursim)}">
<!--                        <xsl:attribute name="weight">
                            <xsl:choose>
                                <xsl:when test="key('ptr',$curgl/@xml:id)">
                                    <xsl:value-of select="key('ptr',$curgl/@xml:id)[1]/ancestor::hi:glossCluster/@weight"/>
                                </xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="glosscluster">
                            <xsl:choose>
                                <xsl:when test="key('ptr',$curgl/@xml:id)">
                                    <xsl:value-of select="generate-id(key('ptr',$curgl/@xml:id)[1]/ancestor::hi:glossCluster)"/>
                                </xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>-->
                        <xsl:attribute name="glossgrp" select=".//ancestor::hi:glossGrp/@target"></xsl:attribute>
                    </data>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="network_ms_gl_sim_clus">
        <xsl:variable name="prejson">
            <var name="network_ms_gl_sim_clus">
                <xsl:for-each select="//tei:msDesc">
                    <xsl:variable name="curms" select="."/>
                    <data id="{hi:nodeid(.)}" type="ms"/>
                    <xsl:for-each select="key('closscorresp',@xml:id)">
                        <xsl:variable name="curgl" select="."/>
                        <data id="{hi:nodeid(.)}" type="gl"/>
                        <data id="{hi:edgeid($curms,.)}" source="{hi:nodeid($curms)}" target="{hi:nodeid(.)}" type="ms_gl"/>
                        <xsl:for-each select="key('ptr',@xml:id)">
                            <xsl:variable name="cursim" select="parent::hi:glossCluster"/>
                            <data id="{hi:nodeid($cursim)}" type="sim"/>
                            <data id="{hi:edgeid($cursim,$curgl)}" source="{hi:nodeid($cursim)}" target="{hi:nodeid($curgl)}" type="sim_gl"/>
                            <xsl:variable name="curclusid" select="hi:removehash($cursim/@ana)"/>
                            <xsl:variable name="curclus" select="key('interp',$curclusid)"/>
                            <xsl:if test="generate-id($cursim) = generate-id(key('glossCluster',$curclusid)[1])">
                                <data id="{hi:nodeid($curclus)}" type="clus"/>
                            </xsl:if>
                            <data id="{hi:edgeid($curclus,$cursim)}" source="{hi:nodeid($curclus)}" target="{hi:nodeid($cursim)}" type="cl_sim"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
            </var>
        </xsl:variable>
        <xsl:result-document href="network_ms_gl_sim_clus.js" omit-xml-declaration="yes" method="text">
            <xsl:value-of select="hi:makejson($prejson)"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="network_div_ab">
        <xsl:variable name="prejson">
            <var name="network_div_ab">
                <xsl:for-each select="//tei:div[ancestor::tei:div]">
                    <data id="{hi:nodeid(.)}" type="div"/>
                    <xsl:for-each select=".//tei:ab">
                        <data id="{hi:nodeid(.)}" type="ab"/>
                        <data id="{hi:edgeid(ancestor::tei:div[1],.)}" source="{hi:nodeid(ancestor::tei:div[1])}" target="{hi:nodeid(.)}" type="div_ab"/>
                    </xsl:for-each>
                </xsl:for-each>
            </var>
        </xsl:variable>
        <xsl:result-document href="network_div_ab.js" omit-xml-declaration="yes" method="text">
            <xsl:value-of select="hi:makejson($prejson)"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:function name="hi:edgeid">
        <xsl:param name="node1"/>
        <xsl:param name="node2"/>
        <xsl:value-of select="hi:nodeid($node1)"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="hi:nodeid($node2)"/>
    </xsl:function>
    
    <xsl:function name="hi:makejson">
        <xsl:param name="var"/>
        <xsl:call-template name="jscomment">
            <xsl:with-param name="comment" select="$comment"></xsl:with-param>
        </xsl:call-template>
        <xsl:text>var </xsl:text>
        <xsl:value-of select="$var/var/@name"/>
        <xsl:text> = [ </xsl:text>
        <xsl:for-each select="$var//data">
            <xsl:text> { data: { </xsl:text>
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="ends-with(local-name(),'_num')">
                        <xsl:value-of select="substring-before(local-name(),'_num')"/>
                        <xsl:text> : </xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="local-name()"/>
                        <xsl:text> : '</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>' </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(position() = last())">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>} </xsl:text>
            <xsl:text>}</xsl:text>
            <xsl:if test="not(position() = last())">
                <xsl:text>,
</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text> ]
</xsl:text>
    </xsl:function>
    
    <xsl:function name="hi:getlatitude" as="xs:decimal">
        <xsl:param name="geo"/>
        <!--<xsl:message><xsl:value-of select="$geo/text()"/></xsl:message>-->
        <xsl:choose>
            <xsl:when test="$geo">
                <xsl:value-of select="number(substring-before(normalize-space($geo/text()),' '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="hi:getlongitude" as="xs:decimal">
        <xsl:param name="geo"/>
        <xsl:choose>
            <xsl:when test="$geo">
                <xsl:value-of select="number(substring-after(normalize-space($geo/text()),' '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="50"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="hi:relativelat" as="xs:decimal">
        <xsl:param name="geo"/>
        <xsl:param name="latlongspans"/>
        <xsl:choose>
            <xsl:when test="local-name($geo)= 'geo'">
                <xsl:value-of select="($latlongspans[1] - hi:getlatitude($geo)) div $latlongspans[3]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="dummy"><a/></xsl:variable>
                <xsl:value-of select="random-number-generator(generate-id($dummy))?number div 20"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="hi:relativelong" as="xs:decimal">
        <xsl:param name="geo"/>
        <xsl:param name="latlongspans"/>
        <xsl:choose>
            <xsl:when test="local-name($geo)= 'geo'">
                <xsl:value-of select="(hi:getlongitude($geo) - $latlongspans[2]) div $latlongspans[3]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="dummy"><a/></xsl:variable>
                <xsl:value-of select="random-number-generator(generate-id($dummy))?number div 20"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="latlongspans">
        <xsl:variable name="lats" as="xs:decimal *">
            <xsl:for-each select="//tei:msDesc//tei:history//tei:geo[preceding-sibling::tei:event[tei:desc[text() = 'glossing']] or following-sibling::tei:event[tei:desc[text() = 'glossing']]]">
                <xsl:sequence select="hi:getlatitude(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="longs" as="xs:decimal *">
            <xsl:for-each select="//tei:msDesc//tei:origin//tei:geo">
                <xsl:sequence select="hi:getlongitude(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="maxlat" select="max($lats)" as="xs:decimal"/>
        <xsl:variable name="minlat" select="min($lats)" as="xs:decimal"/>
        <xsl:variable name="maxlong" select="max($longs)" as="xs:decimal"/>
        <xsl:variable name="minlong" select="min($longs)" as="xs:decimal"/>
        <xsl:variable name="rangelat" select="$maxlat - $minlat"/>
        <xsl:variable name="rangelong" select="$maxlong - $minlong"/>
        <xsl:sequence select="$maxlat"/>
        <xsl:sequence select="$minlong"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="$rangelat > $rangelong">
                    <xsl:value-of select="$rangelat"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$rangelong"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:template>
    
</xsl:stylesheet>
