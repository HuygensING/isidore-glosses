<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs fn"
    version="2.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:hi="http://xmlschema.huygens.knaw.nl/ns/">
    
    <xsl:template match="*" mode="#all">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:seg" mode="plaintext">
        <xsl:apply-templates select="text()" mode="plaintext"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="plaintext">
        <xsl:value-of select="fn:normalize-space(.)"/>
    </xsl:template>
    
    <xsl:function name="hi:glossweight" as="xs:integer">
        <xsl:param name="gloss"/>
        <xsl:choose>
            <xsl:when test="key('ptr',$gloss/@xml:id,$preprocess)">
<!--                <xsl:message><xsl:value-of select="$gloss/@xml:id"/></xsl:message>
                <xsl:message><xsl:value-of select="count(key('ptr',$gloss/@xml:id,$preprocess))"/></xsl:message>-->
                <xsl:value-of select="sum(key('ptr',$gloss/@xml:id,$preprocess)/ancestor::hi:glossCluster/@weight)"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="hi:nodeid" as="xs:string">
        <xsl:param name="node"/>
        <xsl:variable name="temp">
            <xsl:choose>
                <xsl:when test="local-name($node) = 'ab'">
                    <xsl:value-of select="$node/ancestor::tei:div[1]/@n"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$node/@n"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'bibl'">
                    <xsl:text>bibl_</xsl:text>
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'div'">
                    <xsl:value-of select="$node/@n"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'gloss'">
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'glossGrp'">
                    <xsl:text>gg_</xsl:text>
                    <xsl:value-of select="hi:removehash($node/@target)"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'interp' and $node/parent::tei:interpGrp[@type='clusters']">
                    <xsl:text>c_</xsl:text>
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'interp' and $node/parent::tei:interpGrp[@type='regions']">
                    <xsl:text>reg_</xsl:text>
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'glossCluster'">
                    <xsl:text>sim_</xsl:text>
                    <xsl:value-of select="hi:nodeid($node/parent::hi:glossGrp)"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="count($node/preceding-sibling::hi:glossCluster) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'msDesc'">
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:when test="local-name($node) = 'seg'">
                    <xsl:text>seg_</xsl:text>
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Cannot compute id for node with local name <xsl:value-of select="local-name($node)"/> 
                        <xsl:value-of select="$node/@xml:id"/> <xsl:value-of select="$node/@n"/>
                        <xsl:apply-templates select="$node"/> <xsl:value-of select="$node"/>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($temp)"/>
    </xsl:function>
    
    <xsl:function name="hi:removehash">
        <xsl:param name="value"/>
        <xsl:value-of select="substring-after($value,'#')"/>
    </xsl:function>
    
    <xsl:function name="hi:addhash">
        <xsl:param name="value"/>
        <xsl:value-of select="concat('#',$value)"/>
    </xsl:function>
    
    <xsl:template name="htmlcomment">
        <xsl:param name="comment"/>
        <xsl:comment>
            <xsl:value-of select="$comment"/>
        </xsl:comment>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template name="jscomment">
        <xsl:param name="comment"/>
        <xsl:text>// </xsl:text>
        <xsl:value-of select="$comment"/>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template name="createcomment">
        <xsl:text>Content generated on </xsl:text>
        <xsl:value-of select="current-dateTime()"/> 
        <xsl:text> from </xsl:text>
        <xsl:value-of select="base-uri()"/>
    </xsl:template>
    
    <xsl:function name="hi:msname">
        <xsl:param name="node"/>
        <xsl:value-of select="$node/tei:msIdentifier/tei:settlement/text()"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$node/tei:msIdentifier/tei:institution/text()"/>
        <xsl:text>, </xsl:text>
        <xsl:choose>
            <xsl:when test="$node//tei:msName">
                <xsl:value-of select="$node/tei:msIdentifier/tei:msName/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$node/tei:msIdentifier/tei:idno/text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>