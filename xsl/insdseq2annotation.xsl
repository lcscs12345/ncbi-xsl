<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" indent="yes" encoding="UTF-8"/>
<xsl:template match="/">
        <xsl:for-each select="INSDSet/INSDSeq/INSDSeq_feature-table/INSDFeature">
                <xsl:value-of select="concat(INSDFeature_intervals/INSDInterval/INSDInterval_accession, '&#x9;')"/>
                <xsl:value-of select="concat(INSDFeature_location, '&#x9;')"/>
                <xsl:value-of select="concat(INSDFeature_key, '&#10;')"/>
        </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
